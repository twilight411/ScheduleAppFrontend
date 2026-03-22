import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// API 服务类
///
/// 统一处理 HTTP 请求，提供统一的错误处理和响应解析。
class ApiService {
  ApiService._internal();

  static final ApiService _instance = ApiService._internal();

  /// 单例实例
  static ApiService get instance => _instance;

  /// 真机调试时设置此项为电脑局域网 IP，如 'http://192.168.1.100:8000/api'
  static String? overrideBaseUrl;

  /// 模拟器自动选择；真机需在 main 中设置 overrideBaseUrl
  String get baseUrl {
    if (overrideBaseUrl != null) return overrideBaseUrl!;
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    if (Platform.isIOS) return 'http://127.0.0.1:8000/api';
    return 'http://127.0.0.1:8000/api';
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

      // 合并请求头
      final requestHeaders = {
        'Content-Type': 'application/json',
        ...?headers,
      };

      // 发送 POST 请求
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

      // 合并请求头
      final requestHeaders = {
        'Content-Type': 'application/json',
        ...?headers,
      };

      // 发送 GET 请求
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
