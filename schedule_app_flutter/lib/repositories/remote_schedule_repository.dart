import '../services/api_service.dart';

class ScheduleItem {
  final String? id;
  final String title;
  final String? timeStart;
  final String? timeEnd;
  final String? spirit;
  final String? note;
  final String? priority;
  final bool? isFixed;
  final String? taskId;
  final int? version;

  const ScheduleItem({
    this.id,
    required this.title,
    this.timeStart,
    this.timeEnd,
    this.spirit,
    this.note,
    this.priority,
    this.isFixed,
    this.taskId,
    this.version,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) => ScheduleItem(
        id: json['id'] as String?,
        title: json['title'] as String? ?? '',
        timeStart: json['time_start'] as String?,
        timeEnd: json['time_end'] as String?,
        spirit: json['spirit'] as String?,
        note: json['note'] as String?,
        priority: json['priority'] as String?,
        isFixed: json['is_fixed'] as bool?,
        taskId: json['task_id'] as String?,
        version: json['version'] as int?,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'title': title,
        if (timeStart != null) 'time_start': timeStart,
        if (timeEnd != null) 'time_end': timeEnd,
        if (spirit != null) 'spirit': spirit,
        if (note != null) 'note': note,
        if (priority != null) 'priority': priority,
        if (isFixed != null) 'is_fixed': isFixed,
        if (taskId != null) 'task_id': taskId,
        if (version != null) 'version': version,
      };
}

/// 远程日程数据源 — 对接后端全部 /schedule 端点
class RemoteScheduleRepository {
  final ApiService _api;

  RemoteScheduleRepository({ApiService? apiService})
      : _api = apiService ?? ApiService.instance;

  /// 获取今日日程
  Future<List<ScheduleItem>> getToday() async {
    final resp = await _api.get(endpoint: '/schedule/today');
    final data = resp['data'] as Map<String, dynamic>? ?? {};
    final items = (data['items'] as List?)
            ?.map((e) => ScheduleItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return items;
  }

  /// 获取指定日期日程
  Future<List<ScheduleItem>> getDay(String date) async {
    final resp = await _api.get(endpoint: '/schedule/$date');
    final data = resp['data'] as Map<String, dynamic>? ?? {};
    final items = (data['items'] as List?)
            ?.map((e) => ScheduleItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return items;
  }

  /// 获取周日程
  Future<Map<String, List<ScheduleItem>>> getWeek(String weekStart) async {
    final resp = await _api.get(endpoint: '/schedule/week/$weekStart');
    final data = resp['data'] as Map<String, dynamic>? ?? {};
    final result = <String, List<ScheduleItem>>{};
    data.forEach((key, value) {
      if (value is List) {
        result[key] = value
            .map((e) => ScheduleItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    });
    return result;
  }

  /// 获取日期范围日程
  Future<Map<String, List<ScheduleItem>>> getRange({
    required String start,
    required String end,
  }) async {
    final resp = await _api.get(
      endpoint: '/schedule/range',
      queryParameters: {'start': start, 'end': end},
    );
    final data = resp['data'] as Map<String, dynamic>? ?? {};
    final result = <String, List<ScheduleItem>>{};
    data.forEach((key, value) {
      if (value is List) {
        result[key] = value
            .map((e) => ScheduleItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    });
    return result;
  }

  /// 生成日程（AI 调度）
  Future<Map<String, dynamic>> generate({
    required String startDate,
    required String endDate,
    List<String>? taskIds,
    bool includeRecurring = true,
    bool regenerate = false,
  }) async {
    return _api.post(
      endpoint: '/schedule/generate',
      body: {
        'start_date': startDate,
        'end_date': endDate,
        'include_recurring': includeRecurring,
        'regenerate': regenerate,
        if (taskIds != null) 'task_ids': taskIds,
      },
    );
  }

  /// 调整单个条目时间
  Future<Map<String, dynamic>> adjust({
    required String date,
    required String itemId,
    required String newStart,
    required String newEnd,
    int version = 0,
  }) async {
    return _api.post(
      endpoint: '/schedule/adjust',
      body: {
        'date': date,
        'item_id': itemId,
        'new_start': newStart,
        'new_end': newEnd,
        'version': version,
      },
    );
  }

  /// 交换两个条目
  Future<Map<String, dynamic>> swap({
    required String date,
    required String itemId1,
    required String itemId2,
    int version = 0,
  }) async {
    return _api.post(
      endpoint: '/schedule/swap',
      body: {
        'date': date,
        'item_id_1': itemId1,
        'item_id_2': itemId2,
        'version': version,
      },
    );
  }

  /// 检查冲突
  Future<Map<String, dynamic>> checkConflicts({
    required String startDate,
    required String endDate,
  }) async {
    return _api.post(
      endpoint: '/schedule/check-conflicts',
      body: {'start_date': startDate, 'end_date': endDate},
    );
  }

  /// 添加日程条目
  Future<Map<String, dynamic>> addItem({
    required String date,
    required String title,
    String? timeStart,
    String? timeEnd,
    String? spirit,
    String? note,
    bool? isFixed,
  }) async {
    return _api.post(
      endpoint: '/schedule/items',
      body: {
        'date': date,
        'title': title,
        if (timeStart != null) 'time_start': timeStart,
        if (timeEnd != null) 'time_end': timeEnd,
        if (spirit != null) 'spirit': spirit,
        if (note != null) 'note': note,
        if (isFixed != null) 'is_fixed': isFixed,
      },
    );
  }

  /// 更新日程条目
  Future<Map<String, dynamic>> updateItem(
    String itemId, {
    String? date,
    String? title,
    String? timeStart,
    String? timeEnd,
    String? spirit,
    String? note,
    String? priority,
    bool? isFixed,
    int? version,
  }) async {
    return _api.patch(
      endpoint: '/schedule/items/$itemId',
      body: {
        if (date != null) 'date': date,
        if (title != null) 'title': title,
        if (timeStart != null) 'time_start': timeStart,
        if (timeEnd != null) 'time_end': timeEnd,
        if (spirit != null) 'spirit': spirit,
        if (note != null) 'note': note,
        if (priority != null) 'priority': priority,
        if (isFixed != null) 'is_fixed': isFixed,
        if (version != null) 'version': version,
      },
    );
  }

  /// 删除日程条目
  Future<void> deleteItem(
    String itemId, {
    String? date,
    int? version,
  }) async {
    await _api.delete(endpoint: '/schedule/items/$itemId');
  }

  /// 建议空闲 slot（AI）
  Future<Map<String, dynamic>> suggestSlot({
    int durationMinutes = 60,
    String spirit = 'light',
    String? date,
    String priority = 'medium',
  }) async {
    return _api.post(
      endpoint: '/ai/suggest-slot',
      body: {
        'duration_minutes': durationMinutes,
        'spirit': spirit,
        if (date != null) 'date': date,
        'priority': priority,
      },
    );
  }
}
