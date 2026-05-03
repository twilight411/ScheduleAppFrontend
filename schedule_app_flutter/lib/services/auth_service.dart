import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

/// 认证服务：注册、登录、token 持久化、密码管理、登出
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';

  String? _accessToken;
  String? _refreshToken;

  /// 当前有效的 access_token（内存缓存 + 本地持久化）
  Future<String?> getAccessToken() async {
    if (_accessToken != null) return _accessToken;
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
    return _accessToken;
  }

  /// 是否已登录
  Future<bool> get isLoggedIn async => await getAccessToken() != null;

  /// 注册
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final resp = await ApiService.instance.post(
      endpoint: '/auth/register',
      body: {'name': name, 'email': email, 'password': password},
    );
    _extractAndSaveTokens(resp);
  }

  /// 登录
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final resp = await ApiService.instance.post(
      endpoint: '/auth/login',
      body: {'email': email, 'password': password},
    );
    _extractAndSaveTokens(resp);
  }

  /// 刷新 token
  Future<void> refreshToken() async {
    if (_refreshToken == null) {
      throw Exception('没有 refresh_token，无法刷新');
    }
    final resp = await ApiService.instance.post(
      endpoint: '/auth/refresh',
      body: {'refresh_token': _refreshToken},
    );
    _extractAndSaveTokens(resp);
  }

  /// 退出登录（同时通知服务端使 token 失效）
  Future<void> logout() async {
    try {
      if (_refreshToken != null) {
        await ApiService.instance.post(
          endpoint: '/auth/logout',
          body: {'refresh_token': _refreshToken},
        );
      }
    } catch (_) {
      // 服务端登出不阻塞本地清理
    }
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  /// 忘记密码 — 发送重置邮件
  Future<void> forgotPassword(String email) async {
    await ApiService.instance.post(
      endpoint: '/auth/forgot-password',
      body: {'email': email},
    );
  }

  /// 重置密码
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await ApiService.instance.post(
      endpoint: '/auth/reset-password',
      body: {'token': token, 'new_password': newPassword},
    );
  }

  void _extractAndSaveTokens(Map<String, dynamic> resp) {
    // 后端响应: {"success":true, "data":{"access_token":"...", "refresh_token":"..."}}
    final data = resp['data'] as Map<String, dynamic>?;
    final access = data?['access_token'] as String?;
    final refresh = data?['refresh_token'] as String?;
    if (access == null) {
      throw Exception('登录响应中未找到 access_token');
    }
    _accessToken = access;
    _refreshToken = refresh;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_accessTokenKey, access);
      if (refresh != null) prefs.setString(_refreshTokenKey, refresh);
    });
  }
}
