import '../services/api_service.dart';

/// 远程通知数据源 — 对接后端 /notifications 端点
class RemoteNotificationRepository {
  final ApiService _api;

  RemoteNotificationRepository({ApiService? apiService})
      : _api = apiService ?? ApiService.instance;

  /// 注册设备推送 token
  Future<void> registerDevice({
    required String deviceToken,
    required String platform,
  }) async {
    await _api.post(
      endpoint: '/notifications/register-device',
      body: {'device_token': deviceToken, 'platform': platform},
    );
  }

  /// 获取通知设置
  Future<Map<String, dynamic>> getSettings() async {
    final resp = await _api.get(endpoint: '/notifications/settings');
    return (resp['data'] as Map<String, dynamic>?) ?? {};
  }

  /// 更新通知设置
  Future<void> updateSettings(Map<String, dynamic> settings) async {
    await _api.patch(endpoint: '/notifications/settings', body: settings);
  }

  /// 获取通知历史
  Future<Map<String, dynamic>> getHistory({
    int page = 1,
    int pageSize = 20,
    String? type,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };
    if (type != null) params['type'] = type;
    final resp = await _api.get(
      endpoint: '/notifications/history',
      queryParameters: params,
    );
    return resp;
  }

  /// 标记通知已读
  Future<void> markRead(List<String> notificationIds) async {
    await _api.post(
      endpoint: '/notifications/mark-read',
      body: {'notification_ids': notificationIds},
    );
  }
}
