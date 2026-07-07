import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/request_model.dart';

class ApiResponse {
  final int statusCode;
  final String body;
  final Map<String, String> headers;
  final int durationMs;
  final int sizeBytes;

  const ApiResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
    required this.durationMs,
    required this.sizeBytes,
  });
}

class ApiService {
  http.Client? _pendingClient;
  CancelToken? _cancelToken;

  CancelToken createToken() {
    _cancelToken?.cancel();
    _cancelToken = CancelToken();
    return _cancelToken!;
  }

  void cancelRequest() {
    _pendingClient?.close();
    _pendingClient = null;
    _cancelToken?.cancel();
  }

  Future<ApiResponse> sendRequest({
    required String method,
    required String url,
    required Map<String, String> headers,
    required String body,
    required String bodyType,
    required List<BodyField> bodyFields,
    required int timeoutSecs,
    required bool followRedirects,
    CancelToken? cancelToken,
  }) async {
    final client = http.Client();
    _pendingClient = client;

    final uri = Uri.parse(url);
    final req = http.Request(method, uri);
    req.headers.addAll(headers);

    if (bodyType == 'form-data' || bodyType == 'x-www-form-urlencoded') {
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded';
      req.body = bodyFields
          .where((f) => f.key.isNotEmpty)
          .map((f) =>
              '${Uri.encodeQueryComponent(f.key)}=${Uri.encodeQueryComponent(f.value)}')
          .join('&');
    } else if (body.isNotEmpty && method != 'GET' && method != 'DELETE') {
      req.body = body;
    }

    if (!followRedirects) {
      req.followRedirects = false;
    }

    cancelToken?.addListener(() {
      client.close();
    });

    final sw = Stopwatch()..start();

    try {
      final streamed = await client
          .send(req)
          .timeout(Duration(seconds: timeoutSecs));
      final res = await http.Response.fromStream(streamed);
      sw.stop();

      String pretty = res.body;
      try {
        pretty =
            const JsonEncoder.withIndent('  ').convert(json.decode(res.body));
      } catch (_) {}

      return ApiResponse(
        statusCode: res.statusCode,
        body: pretty,
        headers: Map.fromEntries(res.headers.entries),
        durationMs: sw.elapsedMilliseconds,
        sizeBytes: res.bodyBytes.length,
      );
    } finally {
      client.close();
      if (_pendingClient == client) _pendingClient = null;
    }
  }
}

class CancelToken {
  bool _cancelled = false;
  void Function()? _listener;

  bool get isCancelled => _cancelled;

  void addListener(void Function() listener) {
    _listener = listener;
    if (_cancelled) listener();
  }

  void cancel() {
    _cancelled = true;
    _listener?.call();
  }
}
