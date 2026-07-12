import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class HeaderEntry {
  final String id;
  final String key;
  final String value;
  final bool enabled;

  const HeaderEntry({
    required this.id,
    required this.key,
    required this.value,
    this.enabled = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'key': key,
        'value': value,
        'enabled': enabled,
      };

  factory HeaderEntry.fromJson(Map<String, dynamic> json) => HeaderEntry(
        id: json['id'] as String? ?? _uuid.v4(),
        key: json['key'] as String? ?? '',
        value: json['value'] as String? ?? '',
        enabled: json['enabled'] as bool? ?? true,
      );
}

class BodyField {
  final String id;
  final String key;
  final String value;

  const BodyField({required this.id, required this.key, required this.value});

  Map<String, dynamic> toJson() => {
        'id': id,
        'key': key,
        'value': value,
      };

  factory BodyField.fromJson(Map<String, dynamic> json) => BodyField(
        id: json['id'] as String? ?? _uuid.v4(),
        key: json['key'] as String? ?? '',
        value: json['value'] as String? ?? '',
      );
}

class EnvironmentVariable {
  final String id;
  final String key;
  final String value;

  const EnvironmentVariable({
    required this.id,
    required this.key,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'key': key,
        'value': value,
      };

  factory EnvironmentVariable.fromJson(Map<String, dynamic> json) =>
      EnvironmentVariable(
        id: json['id'] as String? ?? _uuid.v4(),
        key: json['key'] as String? ?? '',
        value: json['value'] as String? ?? '',
      );
}

class Collection {
  final String id;
  final String name;
  final DateTime timestamp;
  final List<RequestRecord> requests;

  const Collection({
    required this.id,
    required this.name,
    required this.timestamp,
    this.requests = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'timestamp': timestamp.toIso8601String(),
        'requests': requests.map((r) => r.toJson()).toList(),
      };

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
        id: json['id'] as String? ?? _uuid.v4(),
        name: json['name'] as String? ?? '',
        timestamp:
            DateTime.tryParse(json['timestamp'] as String? ?? '') ??
                DateTime.now(),
        requests: (json['requests'] as List<dynamic>?)
                ?.map((r) =>
                    RequestRecord.fromJson(r as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class RequestRecord {
  final String id;
  final String method;
  final String url;
  final String body;
  final String bodyType; // raw | form-data | x-www-form-urlencoded
  final List<HeaderEntry> headers;
  final List<BodyField> bodyFields;
  final String authType;
  final String authValue1;
  final String authValue2;
  final DateTime timestamp;
  final int? statusCode;
  final int responseMs;
  final String? name;
  final bool followRedirects;

  const RequestRecord({
    required this.id,
    required this.method,
    required this.url,
    required this.body,
    this.bodyType = 'raw',
    required this.headers,
    this.bodyFields = const [],
    this.authType = 'none',
    this.authValue1 = '',
    this.authValue2 = '',
    required this.timestamp,
    this.statusCode,
    this.responseMs = 0,
    this.name,
    this.followRedirects = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'method': method,
        'url': url,
        'body': body,
        'bodyType': bodyType,
        'headers': headers.map((h) => h.toJson()).toList(),
        'bodyFields': bodyFields.map((f) => f.toJson()).toList(),
        'authType': authType,
        'authValue1': authValue1,
        'authValue2': authValue2,
        'timestamp': timestamp.toIso8601String(),
        'statusCode': statusCode,
        'responseMs': responseMs,
        'name': name,
        'followRedirects': followRedirects,
      };

  factory RequestRecord.fromJson(Map<String, dynamic> json) => RequestRecord(
        id: json['id'] as String? ?? _uuid.v4(),
        method: json['method'] as String? ?? 'GET',
        url: json['url'] as String? ?? '',
        body: json['body'] as String? ?? '',
        bodyType: json['bodyType'] as String? ?? 'raw',
        headers: (json['headers'] as List<dynamic>?)
                ?.map((h) => HeaderEntry.fromJson(h as Map<String, dynamic>))
                .toList() ??
            [],
        bodyFields: (json['bodyFields'] as List<dynamic>?)
                ?.map((f) => BodyField.fromJson(f as Map<String, dynamic>))
                .toList() ??
            [],
        authType: json['authType'] as String? ?? 'none',
        authValue1: json['authValue1'] as String? ?? '',
        authValue2: json['authValue2'] as String? ?? '',
        timestamp:
            DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
        statusCode: json['statusCode'] as int?,
        responseMs: json['responseMs'] as int? ?? 0,
        name: json['name'] as String?,
        followRedirects: json['followRedirects'] as bool? ?? true,
      );
}
