import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  final _startTimeMap = <int, DateTime>{};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final requestTime = DateTime.now();
      _startTimeMap[options.hashCode] = requestTime;

      debugPrint(
        '\n🌐 [API REQUEST] ──────────────────────────────────────────',
      );
      debugPrint('▶️ Method: ${options.method}');
      debugPrint('▶️ URL: ${options.uri}');
      if (options.queryParameters.isNotEmpty) {
        debugPrint('▶️ QueryParams: ${_prettyJson(options.queryParameters)}');
      }
      final headersCopy = Map<String, dynamic>.from(options.headers);
      if (headersCopy.containsKey('Authorization')) {
        final authVal = headersCopy['Authorization']?.toString() ?? '';
        if (authVal.startsWith('Bearer ') && authVal.length > 15) {
          headersCopy['Authorization'] =
              '${authVal.substring(0, 15)}...[SECURE]';
        }
      }
      debugPrint('▶️ Headers: ${_prettyJson(headersCopy)}');
      if (options.data != null) {
        if (options.data is FormData) {
          final formData = options.data as FormData;
          final fields = formData.fields
              .map((f) => '${f.key}: ${f.value}')
              .toList();
          final files = formData.files
              .map((f) => '${f.key}: ${f.value.filename ?? 'File'}')
              .toList();
          debugPrint('▶️ Body (FormData Fields): $fields');
          debugPrint('▶️ Body (FormData Files): $files');
        } else {
          debugPrint('▶️ Body: ${_prettyJson(options.data)}');
        }
      }
      debugPrint('──────────────────────────────────────────────────────────');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final responseTime = DateTime.now();
      final startTime = _startTimeMap.remove(response.requestOptions.hashCode);
      final duration = startTime != null
          ? '${responseTime.difference(startTime).inMilliseconds}ms'
          : 'unknown';

      debugPrint(
        '\n🟢 [API RESPONSE] [${response.statusCode} ${response.statusMessage ?? ''}] [Took $duration] ────────────────────',
      );
      debugPrint('◀️ URL: ${response.requestOptions.uri}');
      if (response.data != null) {
        debugPrint('◀️ Body: ${_prettyJson(response.data)}');
      }
      debugPrint('──────────────────────────────────────────────────────────');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final responseTime = DateTime.now();
      final startTime = _startTimeMap.remove(err.requestOptions.hashCode);
      final duration = startTime != null
          ? '${responseTime.difference(startTime).inMilliseconds}ms'
          : 'unknown';

      debugPrint(
        '\n🔴 [API ERROR] [Took $duration] ───────────────────────────',
      );
      debugPrint('xxx URL: ${err.requestOptions.uri}');
      debugPrint('xxx Error Type: ${err.type}');
      debugPrint('xxx Message: ${err.message}');
      if (err.response != null) {
        debugPrint('xxx Status Code: ${err.response?.statusCode}');
        debugPrint('xxx Response Body: ${_prettyJson(err.response?.data)}');
      }
      debugPrint('──────────────────────────────────────────────────────────');
    }
    super.onError(err, handler);
  }

  dynamic _sanitizeData(dynamic data) {
    if (data is Map) {
      return data.map((key, value) => MapEntry(key, _sanitizeData(value)));
    } else if (data is List) {
      return data.map((item) => _sanitizeData(item)).toList();
    } else if (data is String) {
      if (data.length > 200) {
        return '${data.substring(0, 200)}...[TRUNCATED ${data.length} CHARS]';
      }
      return data;
    }
    return data;
  }

  String _prettyJson(dynamic data) {
    try {
      if (data == null) return 'null';
      const encoder = JsonEncoder.withIndent('  ');
      if (data is String) {
        final decoded = json.decode(data);
        return encoder.convert(_sanitizeData(decoded));
      }
      return encoder.convert(_sanitizeData(data));
    } catch (_) {
      final str = data.toString();
      if (str.length > 500) {
        return '${str.substring(0, 500)}...[TRUNCATED]';
      }
      return str;
    }
  }
}
