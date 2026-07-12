import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/request_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../utils/json_highlighter.dart';

class RequestProvider extends ChangeNotifier {
  final _storage = StorageService();
  final _api = ApiService();

  // Request state
  String method = 'GET';
  String url = '';
  String body = '';
  String bodyType = 'raw';
  String authType = 'none';
  String authValue1 = '';
  String authValue2 = '';
  bool followRedirects = true;
  int timeoutSecs = 30;

  List<HeaderRowState> headerRows = [];
  List<BodyFieldRowState> bodyFieldRows = [];

  // Response state
  bool loading = false;
  int? statusCode;
  String responseBody = '';
  Map<String, String> responseHeaders = {};
  int responseMs = 0;
  int responseSize = 0;
  bool showRespHeaders = false;

  // Storage
  List<RequestRecord> history = [];
  List<Collection> collections = [];

  // Environment
  List<EnvironmentVariable> envVars = [];
  bool envEnabled = false;

  // Search
  bool showSearch = false;
  String searchQuery = '';

  CancelToken? _cancelToken;

  TextSpan? _cachedHighlightedBody;
  String? _lastHighlightedBody;
  String? _lastHighlightedQuery;

  TextSpan getHighlightedBody() {
    if (_cachedHighlightedBody != null &&
        _lastHighlightedBody == responseBody &&
        _lastHighlightedQuery == searchQuery) {
      return _cachedHighlightedBody!;
    }
    _lastHighlightedBody = responseBody;
    _lastHighlightedQuery = searchQuery;

    final text = responseBody;
    if (searchQuery.isEmpty) {
      _cachedHighlightedBody = JsonSyntaxHighlighter.highlight(text);
    } else {
      final children = <InlineSpan>[];
      final query = searchQuery.toLowerCase();
      int start = 0;

      while (true) {
        final idx = text.toLowerCase().indexOf(query, start);
        if (idx == -1) {
          children.add(JsonSyntaxHighlighter.highlight(text.substring(start)));
          break;
        }
        if (idx > start) {
          children.add(
              JsonSyntaxHighlighter.highlight(text.substring(start, idx)));
        }
        children.add(TextSpan(
          text: text.substring(idx, idx + query.length),
          style: const TextStyle(
              color: Colors.black, backgroundColor: Color(0xFFFFD54F)),
        ));
        start = idx + query.length;
      }
      _cachedHighlightedBody = TextSpan(children: children);
    }
    return _cachedHighlightedBody!;
  }

  int get activeHeaderCount => headerRows
      .where((r) => r.enabled && r.keyCtrl.text.trim().isNotEmpty)
      .length;

  int get activeBodyFieldCount =>
      bodyFieldRows.where((r) => r.keyCtrl.text.trim().isNotEmpty).length;

  RequestProvider() {
    _init();
  }

  Future<void> _init() async {
    await Future.wait([
      loadHistory(),
      loadCollections(),
      _loadTimeout(),
      _loadEnvironment(),
    ]);
  }

  Future<void> loadHistory() async {
    history = await _storage.getHistory();
    notifyListeners();
  }

  Future<void> loadCollections() async {
    collections = await _storage.getCollections();
    notifyListeners();
  }

  Future<void> _loadTimeout() async {
    timeoutSecs = await _storage.getTimeout();
    notifyListeners();
  }

  Future<void> _loadEnvironment() async {
    envVars = await _storage.getEnvironment();
    notifyListeners();
  }

  String _resolveEnvVars(String input) {
    if (!envEnabled) return input;
    String result = input;
    for (final v in envVars) {
      if (v.key.isNotEmpty) {
        result = result.replaceAll('{{${v.key}}}', v.value);
      }
    }
    return result;
  }

  Map<String, String> buildRequestHeaders() {
    final map = <String, String>{};

    for (final row in headerRows) {
      if (row.enabled && row.keyCtrl.text.trim().isNotEmpty) {
        map[row.keyCtrl.text.trim()] = _resolveEnvVars(row.valueCtrl.text);
      }
    }

    switch (authType) {
      case 'bearer':
        if (authValue1.isNotEmpty) {
          map['Authorization'] = 'Bearer ${_resolveEnvVars(authValue1.trim())}';
        }
      case 'basic':
        if (authValue1.isNotEmpty) {
          final creds = base64Encode(
            utf8.encode(
              '${_resolveEnvVars(authValue1)}:${_resolveEnvVars(authValue2)}',
            ),
          );
          map['Authorization'] = 'Basic $creds';
        }
      case 'apikey':
        final headerName = authValue2.trim().isEmpty
            ? 'X-API-Key'
            : authValue2.trim();
        if (authValue1.isNotEmpty) {
          map[headerName] = _resolveEnvVars(authValue1.trim());
        }
    }

    if (method != 'GET' &&
        method != 'DELETE' &&
        !map.containsKey('Content-Type') &&
        bodyType == 'raw' &&
        body.trim().isNotEmpty) {
      map['Content-Type'] = 'application/json';
    }

    return map;
  }

  Future<void> sendRequest() async {
    final rawUrl = url.trim();
    if (rawUrl.isEmpty) return;

    final resolvedUrl = _resolveEnvVars(rawUrl);
    final finalUrl = resolvedUrl.startsWith('http')
        ? resolvedUrl
        : 'https://$resolvedUrl';

    loading = true;
    responseBody = '';
    statusCode = null;
    responseHeaders = {};
    responseSize = 0;
    showRespHeaders = false;
    showSearch = false;
    searchQuery = '';
    notifyListeners();

    _cancelToken = _api.createToken();

    try {
      final result = await _api.sendRequest(
        method: method,
        url: finalUrl,
        headers: buildRequestHeaders(),
        body: body,
        bodyType: bodyType,
        bodyFields: bodyFieldRows
            .where((r) => r.keyCtrl.text.trim().isNotEmpty)
            .map(
              (r) => BodyField(
                id: r.uid,
                key: r.keyCtrl.text.trim(),
                value: r.valueCtrl.text,
              ),
            )
            .toList(),
        timeoutSecs: timeoutSecs,
        followRedirects: followRedirects,
        cancelToken: _cancelToken,
      );

      statusCode = result.statusCode;
      responseBody = result.body;
      responseHeaders = result.headers;
      responseMs = result.durationMs;
      responseSize = result.sizeBytes;
      loading = false;
      notifyListeners();

      await _storage.addToHistory(
        RequestRecord(
          id: '${DateTime.now().millisecondsSinceEpoch}',
          method: method,
          url: finalUrl,
          body: body,
          bodyType: bodyType,
          headers: headerRows.map((r) => r.toEntry()).toList(),
          bodyFields: bodyFieldRows
              .where((r) => r.keyCtrl.text.trim().isNotEmpty)
              .map(
                (r) => BodyField(
                  id: r.uid,
                  key: r.keyCtrl.text.trim(),
                  value: r.valueCtrl.text,
                ),
              )
              .toList(),
          authType: authType,
          authValue1: authValue1,
          authValue2: authValue2,
          timestamp: DateTime.now(),
          statusCode: result.statusCode,
          responseMs: result.durationMs,
          followRedirects: followRedirects,
        ),
      );

      final newEntry = await _storage.getHistory();
      history = newEntry.take(50).toList();
      notifyListeners();
    } on TimeoutException {
      loading = false;
      responseBody = '⏱ Timeout após $timeoutSecs segundos';
      notifyListeners();
    } catch (e) {
      loading = false;
      responseBody = 'Erro: $e';
      notifyListeners();
    }
  }

  void cancelRequest() {
    _api.cancelRequest();
    loading = false;
    notifyListeners();
  }

  void setMethod(String v) {
    method = v;
    notifyListeners();
  }

  void setUrl(String v) {
    url = v;
  }

  void setBody(String v) {
    body = v;
  }

  void setBodyType(String v) {
    bodyType = v;
    notifyListeners();
  }

  void setAuthType(String v) {
    authType = v;
    notifyListeners();
  }

  void setAuthValue1(String v) {
    authValue1 = v;
  }

  void setAuthValue2(String v) {
    authValue2 = v;
  }

  void setFollowRedirects(bool v) {
    followRedirects = v;
    notifyListeners();
  }

  void addHeaderRow() {
    headerRows.add(HeaderRowState());
    notifyListeners();
  }

  void removeHeaderRow(int index) {
    headerRows[index].dispose();
    headerRows.removeAt(index);
    notifyListeners();
  }

  void addBodyFieldRow() {
    bodyFieldRows.add(BodyFieldRowState());
    notifyListeners();
  }

  void removeBodyFieldRow(int index) {
    bodyFieldRows[index].dispose();
    bodyFieldRows.removeAt(index);
    notifyListeners();
  }

  void loadRecord(RequestRecord rec) {
    for (final r in headerRows) {
      r.dispose();
    }
    for (final r in bodyFieldRows) {
      r.dispose();
    }
    headerRows.clear();
    bodyFieldRows.clear();

    method = rec.method;
    url = rec.url;
    body = rec.body;
    bodyType = rec.bodyType;
    authValue1 = rec.authValue1;
    authValue2 = rec.authValue2;
    authType = rec.authType;
    followRedirects = rec.followRedirects;
    headerRows.addAll(
      rec.headers.map(
        (h) => HeaderRowState(key: h.key, value: h.value, enabled: h.enabled),
      ),
    );
    bodyFieldRows.addAll(
      rec.bodyFields.map((f) => BodyFieldRowState(key: f.key, value: f.value)),
    );
    responseBody = '';
    statusCode = null;
    notifyListeners();
  }

  void clearAll() {
    for (final r in headerRows) {
      r.dispose();
    }
    for (final r in bodyFieldRows) {
      r.dispose();
    }
    headerRows.clear();
    bodyFieldRows.clear();
    method = 'GET';
    url = '';
    body = '';
    bodyType = 'raw';
    authValue1 = '';
    authValue2 = '';
    authType = 'none';
    followRedirects = true;
    responseBody = '';
    statusCode = null;
    notifyListeners();
  }

  Future<void> createCollection(String name) async {
    try {
      final collection = Collection(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        timestamp: DateTime.now(),
        requests: [],
      );
      await _storage.saveCollection(collection);
      await loadCollections();
    } catch (e) {
      debugPrint('Erro ao criar coleção: $e');
    }
  }

  Future<void> addRequestToCollection(String collectionId) async {
    try {
      final idx = collections.indexWhere((c) => c.id == collectionId);
      if (idx < 0) return;

      final record = RequestRecord(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        method: method,
        url: url.trim(),
        body: body.trim(),
        bodyType: bodyType,
        headers: headerRows.map((r) => r.toEntry()).toList(),
        bodyFields: bodyFieldRows
            .where((r) => r.keyCtrl.text.trim().isNotEmpty)
            .map(
              (r) => BodyField(
                id: r.uid,
                key: r.keyCtrl.text.trim(),
                value: r.valueCtrl.text,
              ),
            )
            .toList(),
        authType: authType,
        authValue1: authValue1,
        authValue2: authValue2,
        timestamp: DateTime.now(),
        followRedirects: followRedirects,
      );

      final old = collections[idx];
      final updated = Collection(
        id: old.id,
        name: old.name,
        timestamp: old.timestamp,
        requests: [...old.requests, record],
      );
      await _storage.saveCollection(updated);
      await loadCollections();
    } catch (e) {
      debugPrint('Erro ao adicionar request à coleção: $e');
    }
  }

  Future<void> deleteCollection(String id) async {
    await _storage.deleteCollection(id);
    await loadCollections();
  }

  Future<void> deleteRequestFromCollection(
      String collectionId, String requestId) async {
    try {
      final idx = collections.indexWhere((c) => c.id == collectionId);
      if (idx < 0) return;

      final old = collections[idx];
      final updated = Collection(
        id: old.id,
        name: old.name,
        timestamp: old.timestamp,
        requests: old.requests.where((r) => r.id != requestId).toList(),
      );
      await _storage.saveCollection(updated);
      await loadCollections();
    } catch (e) {
      debugPrint('Erro ao remover request da coleção: $e');
    }
  }

  Future<void> clearHistory() async {
    await _storage.clearHistory();
    await loadHistory();
  }

  Future<void> saveTimeout(int secs) async {
    timeoutSecs = secs;
    await _storage.saveTimeout(secs);
    notifyListeners();
  }

  void copyResponse() {
    Clipboard.setData(ClipboardData(text: responseBody));
  }

  void toggleRespHeaders() {
    showRespHeaders = !showRespHeaders;
    notifyListeners();
  }

  String exportAsJson() {
    final data = {
      'method': method,
      'url': url,
      'headers': buildRequestHeaders(),
      'body': body,
      'bodyType': bodyType,
      'authType': authType,
      'response': {
        'statusCode': statusCode,
        'headers': responseHeaders,
        'body': responseBody,
        'durationMs': responseMs,
        'sizeBytes': responseSize,
      },
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  String toCurl() {
    final rawUrl = url.trim();
    final finalUrl = rawUrl.startsWith('http') ? rawUrl : 'https://$rawUrl';
    final buffer = StringBuffer('curl -X $method "$finalUrl"');

    final requestHeaders = buildRequestHeaders();
    requestHeaders.forEach((key, val) {
      final escapedVal = val.replaceAll('"', '\\"');
      buffer.write(' -H "$key: $escapedVal"');
    });

    final bodyText = body.trim();
    if (bodyText.isNotEmpty && method != 'GET' && method != 'DELETE') {
      final escapedBody = bodyText.replaceAll('"', '\\"').replaceAll('\n', ' ');
      buffer.write(' -d "$escapedBody"');
    }

    return buffer.toString();
  }

  void setSearchQuery(String v) {
    searchQuery = v;
    notifyListeners();
  }

  void refresh() => notifyListeners();

  void toggleSearch() {
    showSearch = !showSearch;
    if (!showSearch) searchQuery = '';
    notifyListeners();
  }

  void addEnvVar() {
    envVars.add(
      EnvironmentVariable(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        key: '',
        value: '',
      ),
    );
    notifyListeners();
  }

  void removeEnvVar(int index) {
    envVars.removeAt(index);
    notifyListeners();
  }

  void updateEnvVar(int index, String key, String value) {
    envVars[index] = EnvironmentVariable(
      id: envVars[index].id,
      key: key,
      value: value,
    );
    notifyListeners();
  }

  Future<void> saveEnvironment() async {
    await _storage.saveEnvironment(envVars);
  }

  void toggleEnvEnabled() {
    envEnabled = !envEnabled;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final r in headerRows) {
      r.dispose();
    }
    for (final r in bodyFieldRows) {
      r.dispose();
    }
    super.dispose();
  }
}

class HeaderRowState {
  static int _counter = 0;
  final String uid;
  final TextEditingController keyCtrl;
  final TextEditingController valueCtrl;
  bool enabled;

  HeaderRowState({String key = '', String value = '', this.enabled = true})
    : uid = 'hdr_${++_counter}_${DateTime.now().millisecondsSinceEpoch}',
      keyCtrl = TextEditingController(text: key),
      valueCtrl = TextEditingController(text: value);

  void dispose() {
    keyCtrl.dispose();
    valueCtrl.dispose();
  }

  HeaderEntry toEntry() => HeaderEntry(
    id: uid,
    key: keyCtrl.text.trim(),
    value: valueCtrl.text,
    enabled: enabled,
  );
}

class BodyFieldRowState {
  static int _counter = 0;
  final String uid;
  final TextEditingController keyCtrl;
  final TextEditingController valueCtrl;

  BodyFieldRowState({String key = '', String value = ''})
    : uid = 'bf_${++_counter}_${DateTime.now().millisecondsSinceEpoch}',
      keyCtrl = TextEditingController(text: key),
      valueCtrl = TextEditingController(text: value);

  void dispose() {
    keyCtrl.dispose();
    valueCtrl.dispose();
  }
}
