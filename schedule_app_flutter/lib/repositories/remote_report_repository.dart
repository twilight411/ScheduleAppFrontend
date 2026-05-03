import '../services/api_service.dart';

/// 远程报表/生命树/果实数据源
class RemoteReportRepository {
  final ApiService _api;

  RemoteReportRepository({ApiService? apiService})
      : _api = apiService ?? ApiService.instance;

  // ========================================
  //  周报
  // ========================================

  Future<Map<String, dynamic>> getWeeklyReport(String weekStart) async {
    final resp = await _api.get(
      endpoint: '/reports/weekly',
      queryParameters: {'week_start': weekStart},
    );
    return (resp['data'] as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> getLatestWeeklyReport() async {
    final resp = await _api.get(endpoint: '/reports/weekly/latest');
    return (resp['data'] as Map<String, dynamic>?) ?? {};
  }

  Future<void> regenerateWeeklyReport() async {
    await _api.post(endpoint: '/reports/weekly/regenerate', body: {});
  }

  // ========================================
  //  月报
  // ========================================

  Future<Map<String, dynamic>> getMonthlyReport(String month) async {
    final resp = await _api.get(
      endpoint: '/reports/monthly',
      queryParameters: {'month': month},
    );
    return (resp['data'] as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> getLatestMonthlyReport() async {
    final resp = await _api.get(endpoint: '/reports/monthly/latest');
    return (resp['data'] as Map<String, dynamic>?) ?? {};
  }

  // ========================================
  //  生命树
  // ========================================

  Future<Map<String, dynamic>> getTreeData(String weekStart) async {
    final resp = await _api.get(
      endpoint: '/tree/weekly',
      queryParameters: {'week_start': weekStart},
    );
    return (resp['data'] as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> getTreeHistory(int months) async {
    final resp = await _api.get(
      endpoint: '/tree/history',
      queryParameters: {'months': months.toString()},
    );
    return (resp['data'] as Map<String, dynamic>?) ?? {};
  }

  // ========================================
  //  月度果实
  // ========================================

  Future<List<Map<String, dynamic>>> getFruitCollection() async {
    final resp = await _api.get(endpoint: '/fruits/collection');
    final data = resp['data'] as List<dynamic>? ?? [];
    return data.map((e) => e as Map<String, dynamic>).toList();
  }
}
