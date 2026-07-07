import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/request_model.dart';

class StorageService {
  static const _historyKey = 'api_history_v1';
  static const _collectionsKey = 'api_collections_v1';
  static const _envKey = 'api_environment_v1';
  static const _maxHistory = 50;

  Future<List<RequestRecord>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_historyKey) ?? [])
        .map((s) => RequestRecord.fromJson(
            jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> addToHistory(RequestRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_historyKey) ?? [];
    list.insert(0, jsonEncode(record.toJson()));
    if (list.length > _maxHistory) list.removeRange(_maxHistory, list.length);
    await prefs.setStringList(_historyKey, list);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<List<RequestRecord>> getCollections() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_collectionsKey) ?? [])
        .map((s) => RequestRecord.fromJson(
            jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCollection(RequestRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_collectionsKey) ?? [];
    final idx = list.indexWhere((s) {
      try {
        return (jsonDecode(s) as Map<String, dynamic>)['id'] == record.id;
      } catch (_) {
        return false;
      }
    });
    final encoded = jsonEncode(record.toJson());
    if (idx >= 0) {
      list[idx] = encoded;
    } else {
      list.add(encoded);
    }
    await prefs.setStringList(_collectionsKey, list);
  }

  Future<void> deleteCollection(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_collectionsKey) ?? [];
    list.removeWhere((s) {
      try {
        return (jsonDecode(s) as Map<String, dynamic>)['id'] == id;
      } catch (_) {
        return false;
      }
    });
    await prefs.setStringList(_collectionsKey, list);
  }

  Future<List<EnvironmentVariable>> getEnvironment() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_envKey) ?? [];
    return raw
        .map((s) => EnvironmentVariable.fromJson(
            jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveEnvironment(List<EnvironmentVariable> vars) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _envKey, vars.map((v) => jsonEncode(v.toJson())).toList());
  }

  static const _timeoutKey = 'api_timeout_v1';

  Future<int> getTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_timeoutKey) ?? 30;
  }

  Future<void> saveTimeout(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timeoutKey, seconds);
  }
}
