import 'package:shared_preferences/shared_preferences.dart';

/// 本地用户标识，用于后端用量统计（与 `usage_logs.user_id` 对应）
///
/// - 调试/跳过登录：固定为 [defaultDevUserId]（与后端 seed 的 `user_001` 一致，管理后台可看到用量）
/// - 登录成功：写入 `user_{手机号}` 等
class UserIdentityService {
  UserIdentityService._();

  static final UserIdentityService instance = UserIdentityService._();

  static const String _prefsKey = 'schedule_user_id';

  /// 未设置过、或调试直接进主流程时的默认 ID（与 schedule_backend seed 中小明一致）
  static const String defaultDevUserId = 'user_001';

  /// 当前用户 ID（异步读本地；首次会落库默认 ID）
  Future<String> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_prefsKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    await prefs.setString(_prefsKey, defaultDevUserId);
    return defaultDevUserId;
  }

  /// 登录成功后调用，例如 `setLoggedInUserIdFromPhone('13312240306')`
  Future<void> setLoggedInUserIdFromPhone(String phone) async {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, 'user_$digits');
  }

  /// 手动设置（测试用）
  Future<void> setUserId(String id) async {
    if (id.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, id);
  }
}
