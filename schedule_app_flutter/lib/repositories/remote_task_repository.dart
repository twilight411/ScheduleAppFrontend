import '../services/api_service.dart';

/// 后端 Task 模型（对应 Backend TaskOut schema）
class BackendTask {
  final String id;
  final String title;
  final String? rawInput;
  final String primarySpirit;
  final List<String> secondarySpirits;
  final String? deadline;
  final double? estimatedHours;
  final String priority;
  final bool isRecurring;
  final String? recurrencePattern;
  final String status;
  final String source;
  final String? createdAt;
  final List<BackendSubTask> subtasks;

  const BackendTask({
    required this.id,
    required this.title,
    this.rawInput,
    this.primarySpirit = 'light',
    this.secondarySpirits = const [],
    this.deadline,
    this.estimatedHours,
    this.priority = 'medium',
    this.isRecurring = false,
    this.recurrencePattern,
    this.status = 'pending',
    this.source = 'manual',
    this.createdAt,
    this.subtasks = const [],
  });

  factory BackendTask.fromJson(Map<String, dynamic> json) {
    final subs = (json['subtasks'] as List?)
            ?.map((e) => BackendSubTask.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return BackendTask(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      rawInput: json['raw_input'] as String?,
      primarySpirit: json['primary_spirit'] as String? ?? 'light',
      secondarySpirits: (json['secondary_spirits'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      deadline: json['deadline'] as String?,
      estimatedHours: (json['estimated_hours'] as num?)?.toDouble(),
      priority: json['priority'] as String? ?? 'medium',
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurrencePattern: json['recurrence_pattern'] as String?,
      status: json['status'] as String? ?? 'pending',
      source: json['source'] as String? ?? 'manual',
      createdAt: json['created_at'] as String?,
      subtasks: subs,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'raw_input': rawInput,
        'primary_spirit': primarySpirit,
        'secondary_spirits': secondarySpirits,
        'deadline': deadline,
        'estimated_hours': estimatedHours,
        'priority': priority,
        'is_recurring': isRecurring,
        'recurrence_pattern': recurrencePattern,
        'status': status,
        'source': source,
        'created_at': createdAt,
        'subtasks': subtasks.map((e) => e.toJson()).toList(),
      };
}

class BackendSubTask {
  final String id;
  final String taskId;
  final String spirit;
  final String title;
  final int durationMinutes;
  final String? scheduledStart;
  final String? scheduledEnd;
  final String status;
  final String priority;
  final String? spiritTip;
  final String? suggestedTime;

  const BackendSubTask({
    required this.id,
    required this.taskId,
    this.spirit = 'light',
    required this.title,
    this.durationMinutes = 60,
    this.scheduledStart,
    this.scheduledEnd,
    this.status = 'pending',
    this.priority = 'medium',
    this.spiritTip,
    this.suggestedTime,
  });

  factory BackendSubTask.fromJson(Map<String, dynamic> json) => BackendSubTask(
        id: json['id'] as String? ?? '',
        taskId: json['task_id'] as String? ?? '',
        spirit: json['spirit'] as String? ?? 'light',
        title: json['title'] as String? ?? '',
        durationMinutes: json['duration_minutes'] as int? ?? 60,
        scheduledStart: json['scheduled_start'] as String?,
        scheduledEnd: json['scheduled_end'] as String?,
        status: json['status'] as String? ?? 'pending',
        priority: json['priority'] as String? ?? 'medium',
        spiritTip: json['spirit_tip'] as String?,
        suggestedTime: json['suggested_time'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'task_id': taskId,
        'spirit': spirit,
        'title': title,
        'duration_minutes': durationMinutes,
        'scheduled_start': scheduledStart,
        'scheduled_end': scheduledEnd,
        'status': status,
        'priority': priority,
        'spirit_tip': spiritTip,
        'suggested_time': suggestedTime,
      };
}

/// 远程任务数据源 — 对接后端全部 /tasks 端点
class RemoteTaskRepository {
  final ApiService _api;

  RemoteTaskRepository({ApiService? apiService})
      : _api = apiService ?? ApiService.instance;

  // ========================================
  //  CRUD
  // ========================================

  /// 创建任务（自然语言输入）
  Future<Map<String, dynamic>> createTask({
    required String userInput,
    String? title,
    String? primarySpirit,
    String? deadline,
    double? estimatedHours,
    String priority = 'medium',
    bool autoDecompose = false,
  }) async {
    final body = <String, dynamic>{
      'user_input': userInput,
      'priority': priority,
      'auto_decompose': autoDecompose,
    };
    if (title != null) body['title'] = title;
    if (primarySpirit != null) body['primary_spirit'] = primarySpirit;
    if (deadline != null) body['deadline'] = deadline;
    if (estimatedHours != null) body['estimated_hours'] = estimatedHours;
    return _api.post(endpoint: '/tasks', body: body);
  }

  /// 获取任务列表
  Future<({List<BackendTask> tasks, int total})> listTasks({
    String? status,
    String? spirit,
    int page = 1,
    int pageSize = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };
    if (status != null) params['status'] = status;
    if (spirit != null) params['spirit'] = spirit;

    final resp = await _api.get(
      endpoint: '/tasks',
      queryParameters: params,
    );
    final data = resp['data'] as Map<String, dynamic>? ?? {};
    final items = (data['items'] as List?)
            ?.map((e) => BackendTask.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final total = data['total'] as int? ?? items.length;
    return (tasks: items, total: total);
  }

  /// 获取单个任务
  Future<BackendTask> getTask(String taskId) async {
    final resp = await _api.get(endpoint: '/tasks/$taskId');
    final data = resp['data'] as Map<String, dynamic>? ?? {};
    return BackendTask.fromJson(data);
  }

  /// 更新任务
  Future<BackendTask> updateTask(
    String taskId, {
    String? title,
    String? primarySpirit,
    String? deadline,
    double? estimatedHours,
    String? priority,
    bool? isRecurring,
    String? recurrencePattern,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (primarySpirit != null) body['primary_spirit'] = primarySpirit;
    if (deadline != null) body['deadline'] = deadline;
    if (estimatedHours != null) body['estimated_hours'] = estimatedHours;
    if (priority != null) body['priority'] = priority;
    if (isRecurring != null) body['is_recurring'] = isRecurring;
    if (recurrencePattern != null) {
      body['recurrence_pattern'] = recurrencePattern;
    }
    final resp = await _api.patch(endpoint: '/tasks/$taskId', body: body);
    final data = resp['data'] as Map<String, dynamic>? ?? {};
    return BackendTask.fromJson(data);
  }

  /// 删除任务
  Future<void> deleteTask(String taskId) async {
    await _api.delete(endpoint: '/tasks/$taskId');
  }

  // ========================================
  //  状态流转
  // ========================================

  Future<BackendTask> startTask(String taskId) async {
    final resp = await _api.post(
      endpoint: '/tasks/$taskId/start',
      body: {},
    );
    return BackendTask.fromJson(
        (resp['data'] as Map<String, dynamic>?) ?? {});
  }

  Future<BackendTask> pauseTask(String taskId) async {
    final resp = await _api.post(
      endpoint: '/tasks/$taskId/pause',
      body: {},
    );
    return BackendTask.fromJson(
        (resp['data'] as Map<String, dynamic>?) ?? {});
  }

  Future<BackendTask> completeTask(
    String taskId, {
    String? feedback,
  }) async {
    final body = <String, dynamic>{};
    if (feedback != null) body['feedback'] = feedback;
    final resp = await _api.post(
      endpoint: '/tasks/$taskId/complete',
      body: body,
    );
    return BackendTask.fromJson(
        (resp['data'] as Map<String, dynamic>?) ?? {});
  }

  Future<BackendTask> cancelTask(
    String taskId, {
    String? reason,
  }) async {
    final body = <String, dynamic>{};
    if (reason != null) body['reason'] = reason;
    final resp = await _api.post(
      endpoint: '/tasks/$taskId/cancel',
      body: body,
    );
    return BackendTask.fromJson(
        (resp['data'] as Map<String, dynamic>?) ?? {});
  }

  Future<BackendTask> rescheduleTask(
    String taskId, {
    required String newStart,
    required String newEnd,
    String? reason,
  }) async {
    final resp = await _api.post(
      endpoint: '/tasks/$taskId/reschedule',
      body: {
        'new_start': newStart,
        'new_end': newEnd,
        if (reason != null) 'reason': reason,
      },
    );
    return BackendTask.fromJson(
        (resp['data'] as Map<String, dynamic>?) ?? {});
  }

  Future<int> batchComplete(
    List<String> taskIds, {
    String? feedback,
  }) async {
    final resp = await _api.post(
      endpoint: '/tasks/batch-complete',
      body: {
        'task_ids': taskIds,
        if (feedback != null) 'feedback': feedback,
      },
    );
    final data = resp['data'] as Map<String, dynamic>? ?? {};
    return data['completed_count'] as int? ?? 0;
  }
}
