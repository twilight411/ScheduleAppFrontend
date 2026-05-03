import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ai_chat_result.dart';

/// API 服务类
///
/// 统一处理 HTTP 请求，提供统一的错误处理和响应解析。
class ApiService {
  ApiService._internal();

  static final ApiService _instance = ApiService._internal();

  /// 单例实例
  static ApiService get instance => _instance;

  /// 后端基础 URL。
  /// 隧道域名可能会变，只需修改此处即可切换后端地址。
  /// 也可在运行前通过 overrideBaseUrl 覆盖。
  static const String _defaultBaseUrl =
      'http://192.168.43.132:8001/api/v1';

  /// 覆盖后端地址（优先级最高），例如 dart-define 或 main 中设置。
  static String? overrideBaseUrl;

  String get baseUrl => overrideBaseUrl ?? _defaultBaseUrl;

  /// 健康检查，返回 true 表示后端可达。
  Future<bool> healthCheck() async {
    try {
      final resp = await get(endpoint: '/health');
      return resp['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }

  /// 读取本地持久化的 access_token
  Future<String?> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_access_token');
  }

  /// 合并请求头，自动注入 Authorization（如果本地有 token）
  Future<Map<String, String>> _buildHeaders(
    Map<String, String>? extra,
  ) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      ...?extra,
    };
    final token = await _getStoredToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// 发送 POST 请求
  ///
  /// [endpoint] API 端点路径（如 '/ai/chat'）
  /// [body] 请求体（Map 会自动转换为 JSON）
  /// [headers] 额外的请求头
  ///
  /// 返回解析后的响应数据（Map<String, dynamic>）
  Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      // 构建完整的 URL
      final url = Uri.parse('$baseUrl$endpoint');

      final requestHeaders = await _buildHeaders(headers);

      final response = await http.post(
        url,
        headers: requestHeaders,
        body: jsonEncode(body),
      );

      // 检查响应状态
      if (response.statusCode == 200) {
        // 解析 JSON 响应
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return jsonResponse;
      } else {
        // 处理错误响应
        final errorBody = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>?
            : null;
        final errorMessage = errorBody?['detail'] ??
            errorBody?['message'] ??
            errorBody?['error'] ??
            '请求失败：${response.statusCode}';
        throw ApiException(
          statusCode: response.statusCode,
          message: errorMessage.toString(),
        );
      }
    } on http.ClientException catch (e) {
      // 处理网络连接错误
      throw ApiException(
        statusCode: 0,
        message: '网络连接失败：${e.message}',
      );
    } on FormatException catch (e) {
      // 处理 JSON 解析错误
      throw ApiException(
        statusCode: 0,
        message: '响应解析失败：${e.message}',
      );
    } catch (e) {
      // 处理其他异常
      throw ApiException(
        statusCode: 0,
        message: '请求异常：$e',
      );
    }
  }

  /// 发送 PATCH 请求
  Future<Map<String, dynamic>> patch({
    required String endpoint,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final requestHeaders = await _buildHeaders(headers);
      final response = await http.patch(
        url,
        headers: requestHeaders,
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorBody = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>?
            : null;
        throw ApiException(
          statusCode: response.statusCode,
          message: errorBody?['detail']?.toString() ??
              errorBody?['message']?.toString() ??
              '请求失败：${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      throw ApiException(statusCode: 0, message: '网络连接失败：${e.message}');
    } on FormatException catch (e) {
      throw ApiException(statusCode: 0, message: '响应解析失败：${e.message}');
    } catch (e) {
      throw ApiException(statusCode: 0, message: '请求异常：$e');
    }
  }

  /// 发送 DELETE 请求
  Future<Map<String, dynamic>> delete({
    required String endpoint,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final requestHeaders = await _buildHeaders(headers);
      final response = await http.delete(url, headers: requestHeaders);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorBody = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>?
            : null;
        throw ApiException(
          statusCode: response.statusCode,
          message: errorBody?['detail']?.toString() ??
              errorBody?['message']?.toString() ??
              '请求失败：${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      throw ApiException(statusCode: 0, message: '网络连接失败：${e.message}');
    } on FormatException catch (e) {
      throw ApiException(statusCode: 0, message: '响应解析失败：${e.message}');
    } catch (e) {
      throw ApiException(statusCode: 0, message: '请求异常：$e');
    }
  }

  /// 发送 GET 请求
  ///
  /// [endpoint] API 端点路径
  /// [queryParameters] 查询参数
  /// [headers] 额外的请求头
  ///
  /// 返回解析后的响应数据（Map<String, dynamic>）
  Future<Map<String, dynamic>> get({
    required String endpoint,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      // 构建 URL
      var url = Uri.parse('$baseUrl$endpoint');
      if (queryParameters != null && queryParameters.isNotEmpty) {
        url = url.replace(queryParameters: queryParameters);
      }

      final requestHeaders = await _buildHeaders(headers);

      final response = await http.get(url, headers: requestHeaders);

      // 检查响应状态
      if (response.statusCode == 200) {
        // 解析 JSON 响应
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return jsonResponse;
      } else {
        // 处理错误响应
        final errorBody = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>?
            : null;
        final errorMessage = errorBody?['detail'] ??
            errorBody?['message'] ??
            errorBody?['error'] ??
            '请求失败：${response.statusCode}';
        throw ApiException(
          statusCode: response.statusCode,
          message: errorMessage.toString(),
        );
      }
    } on http.ClientException catch (e) {
      // 处理网络连接错误
      throw ApiException(
        statusCode: 0,
        message: '网络连接失败：${e.message}',
      );
    } on FormatException catch (e) {
      // 处理 JSON 解析错误
      throw ApiException(
        statusCode: 0,
        message: '响应解析失败：${e.message}',
      );
    } catch (e) {
      // 处理其他异常
      throw ApiException(
        statusCode: 0,
        message: '请求异常：$e',
      );
    }
  }

  /// 发送 POST 请求并返回 SSE 事件流（用于协商引擎）
  ///
  /// 使用 dart:io HttpClient 做真正的流式读取，
  /// 避免 http 包在 Android 上缓冲整个响应体的问题。
  Stream<NegotiationEvent> postStream({
    required String endpoint,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async* {
    final url = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = await _buildHeaders(headers);
    final bodyStr = jsonEncode(body);

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    try {
      print('[SSE] Connecting to $url...');
      final request = await client.postUrl(url);
      requestHeaders.forEach((key, value) {
        request.headers.set(key, value);
      });
      final bodyBytes = utf8.encode(bodyStr);
      request.headers.set('Content-Length', bodyBytes.length.toString());
      request.add(bodyBytes);

      print('[SSE] Awaiting response...');
      final response = await request.close();
      print('[SSE] Got response: ${response.statusCode}');

      if (response.statusCode != 200) {
        final errorBody = await response.transform(utf8.decoder).join();
        Map<String, dynamic>? parsed;
        try {
          parsed = jsonDecode(errorBody) as Map<String, dynamic>?;
        } catch (_) {}
        final errorMessage = parsed?['detail'] ??
            parsed?['message'] ??
            parsed?['error'] ??
            '请求失败：${response.statusCode}';
        throw ApiException(
          statusCode: response.statusCode,
          message: errorMessage.toString(),
        );
      }

      // 逐行读取 SSE 流，用 LineSplitter 保证不会截断行
      String eventType = '';
      String dataLine = '';
      bool done = false;
      bool anyEventYielded = false;
      String firstLine = ''; // 用于兜底：后端返回非 SSE 时提取错误信息

      print('[SSE] Reading stream...');
      final lines = response.transform(utf8.decoder).transform(const LineSplitter());
      await for (final line in lines) {
        print('[SSE] Line: $line');
        if (done) break;
        if (firstLine.isEmpty && line.isNotEmpty) firstLine = line;
        if (line.startsWith('event: ')) {
          eventType = line.substring(7).trim();
        } else if (line.startsWith('data: ')) {
          dataLine = line.substring(6).trim();
        } else if (line.isEmpty && eventType.isNotEmpty && dataLine.isNotEmpty) {
          // 空行 = 一条 SSE 消息结束
          try {
            final data = jsonDecode(dataLine) as Map<String, dynamic>;
            final event = NegotiationEvent.fromSse(eventType, data);
            anyEventYielded = true;
            yield event;
            if (event is NegotiationDone) {
              done = true;
              break;
            }
          } catch (_) {
            anyEventYielded = true;
            yield NegotiationError(message: '解析失败: $dataLine');
          }
          eventType = '';
          dataLine = '';
        }
      }

      // 处理未以空行结尾的最后一条消息
      if (!done && eventType.isNotEmpty && dataLine.isNotEmpty) {
        try {
          final data = jsonDecode(dataLine) as Map<String, dynamic>;
          anyEventYielded = true;
          yield NegotiationEvent.fromSse(eventType, data);
        } catch (_) {}
      }

      // 后端返回了非 SSE 格式（如普通 JSON），没有解析出任何事件
      if (!anyEventYielded) {
        String hint = '';
        try {
          final j = jsonDecode(firstLine) as Map<String, dynamic>;
          hint = j['data']?['message'] as String? ??
              j['message'] as String? ??
              '';
        } catch (_) {}
        yield NegotiationError(
          message: hint.isNotEmpty ? hint : '服务器返回了非预期的响应格式',
        );
      }
    } finally {
      client.close();
    }
  }

  /// 解析单条 SSE 消息文本 → NegotiationEvent
  NegotiationEvent? _parseSseMessage(String message) {
    String? eventType;
    String? dataLine;

    for (final line in message.split('\n')) {
      if (line.startsWith('event: ')) {
        eventType = line.substring(7).trim();
      } else if (line.startsWith('data: ')) {
        dataLine = line.substring(6).trim();
      }
    }

    if (eventType == null || dataLine == null) return null;

    try {
      final data = jsonDecode(dataLine) as Map<String, dynamic>;
      return NegotiationEvent.fromSse(eventType, data);
    } catch (_) {
      return NegotiationError(message: '解析失败: $dataLine');
    }
  }
}

/// API 异常类
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}
