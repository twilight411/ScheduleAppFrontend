import 'package:flutter/foundation.dart';

import '../models/repeat_option.dart';
import '../models/spirit_type.dart';
import '../models/task.dart';
import '../repositories/local_task_repository.dart';
import '../repositories/remote_task_repository.dart';
import '../repositories/task_repository.dart';

/// 用于管理任务列表的状态管理类
///
/// 支持双模式：
/// - 本地模式（默认）：任务存在手机 SharedPreferences
/// - 远程模式：同步到后端 /tasks 接口
/// - 混合模式：本地优先 + 后台静默同步
class TaskProvider extends ChangeNotifier {
  /// 所有任务列表
  final List<Task> tasks = [];

  /// 本地任务数据源
  final TaskRepository _localRepository;

  /// 远程任务数据源（可选，null 时不连接后端）
  final RemoteTaskRepository? _remoteRepository;

  /// 后端任务列表（原生格式，用于协商等场景）
  final List<BackendTask> remoteTasks = [];

  /// 是否正在连接后端
  bool _syncing = false;
  bool get syncing => _syncing;

  /// 后端是否可达
  bool _remoteConnected = false;
  bool get remoteConnected => _remoteConnected;

  /// 供 UI 使用的初始化 Future
  late final Future<void> initializeFuture;

  TaskProvider({
    TaskRepository? repository,
    RemoteTaskRepository? remoteRepository,
  })  : _localRepository = repository ?? const LocalTaskRepository(),
        _remoteRepository = remoteRepository {
    initializeFuture = _loadInitialTasks();
  }

  /// 创建远程任务（自然语言）并同步到本地
  Future<BackendTask?> createRemoteTask({
    required String userInput,
  }) async {
    if (_remoteRepository == null) return null;
    try {
      _syncing = true;
      notifyListeners();
      final resp = await _remoteRepository!.createTask(
        userInput: userInput,
        autoDecompose: true,
      );
      final data = resp['data'] as Map<String, dynamic>? ?? {};
      final createdTasks = data['tasks'] as List? ?? [];
      if (createdTasks.isNotEmpty) {
        final bt = BackendTask.fromJson(
            createdTasks.first as Map<String, dynamic>);
        remoteTasks.add(bt);
        return bt;
      }
      return null;
    } catch (e) {
      debugPrint('[TaskProvider] createRemoteTask failed: $e');
      return null;
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  /// 刷新远程任务列表
  Future<void> fetchRemoteTasks({
    String? status,
    String? spirit,
  }) async {
    if (_remoteRepository == null) return;
    try {
      _syncing = true;
      notifyListeners();
      final result = await _remoteRepository!.listTasks(
        status: status,
        spirit: spirit,
        pageSize: 50,
      );
      remoteTasks
        ..clear()
        ..addAll(result.tasks);
      _remoteConnected = true;
    } catch (e) {
      _remoteConnected = false;
      debugPrint('[TaskProvider] fetchRemoteTasks failed: $e');
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  // ========================================
  //  本地任务管理（保持原有接口不变）
  // ========================================

  /// 添加任务（如果已存在相同任务则忽略）。
  /// 如果有远程仓库，同时尝试同步到后端。
  void addTask(Task task) {
    if (tasks.contains(task)) return;
    tasks.add(task);
    _persistTasks();
    notifyListeners();

    // 后台同步到后端（不阻塞）
    _syncTaskToRemote(task);
  }

  Future<void> _syncTaskToRemote(Task task) async {
    final remote = _remoteRepository;
    if (remote == null) return;
    try {
      final dateStr =
          '${task.startDate.year}-${task.startDate.month.toString().padLeft(2, '0')}-${task.startDate.day.toString().padLeft(2, '0')}';
      final timeStart =
          '${task.startDate.hour.toString().padLeft(2, '0')}:${task.startDate.minute.toString().padLeft(2, '0')}';
      final timeEnd =
          '${task.endDate.hour.toString().padLeft(2, '0')}:${task.endDate.minute.toString().padLeft(2, '0')}';
      final hours = task.endDate.difference(task.startDate).inMinutes / 60;

      await remote.createTask(
        userInput: task.title,
        title: task.title,
        primarySpirit: task.category.name,
        deadline: dateStr,
        estimatedHours: hours,
        autoDecompose: false,
      );
      _remoteConnected = true;
    } catch (e) {
      debugPrint('[TaskProvider] sync to remote failed: $e');
    }
  }

  /// 删除任务
  void removeTask(Task task) {
    tasks.remove(task);
    _persistTasks();
    notifyListeners();
  }

  /// 更新任务
  void updateTask(Task oldTask, Task newTask) {
    final index = tasks.indexWhere((t) => t == oldTask);
    if (index >= 0) {
      tasks[index] = newTask;
      _persistTasks();
      notifyListeners();
    }
  }

  /// 根据具体日期筛选任务
  List<Task> getTasksByDate(DateTime date) {
    return tasks.where((task) {
      final d = task.startDate;
      return d.year == date.year && d.month == date.month && d.day == date.day;
    }).toList();
  }

  /// 根据精灵类型筛选任务
  List<Task> getTasksBySpirit(SpiritType spirit) {
    return tasks.where((task) => task.category == spirit).toList();
  }

  /// 清空所有任务
  void clearAll() {
    tasks.clear();
    notifyListeners();
    _persistTasks();
  }

  /// 首次启动时加载本地任务；若无数据则初始化假数据并保存
  Future<void> _loadInitialTasks() async {
    final loadedTasks = await _localRepository.getAllTasks();
    if (loadedTasks.isNotEmpty) {
      tasks
        ..clear()
        ..addAll(loadedTasks);
      notifyListeners();
      // 后台同步本地任务到后端（初始加载时）
      _syncLocalToRemote();
    } else {
      _initMockData();
      await _localRepository.saveTasks(tasks);
    }
    // 后台尝试拉取远程任务
    fetchRemoteTasks();
  }

  /// 将本地所有任务同步到后端（幂等）
  Future<void> _syncLocalToRemote() async {
    final remote = _remoteRepository;
    if (remote == null) return;
    // 先看后端是否已有任务，如果有则不重复同步
    try {
      final result = await remote.listTasks(pageSize: 1);
      if (result.total > 0) {
        _remoteConnected = true;
        return;
      }
    } catch (_) {
      return;
    }
    // 后端为空，同步本地任务
    for (final task in tasks) {
      await _syncTaskToRemote(task);
    }
  }

  /// 将当前任务列表持久化到本地
  Future<void> _persistTasks() async {
    await _localRepository.saveTasks(List<Task>.from(tasks));
  }

  /// 初始化一些假数据，方便界面测试
  void _initMockData() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day, 9, 0);
    final todayEnd = todayStart.add(const Duration(hours: 1));

    final todayEveningStart = DateTime(now.year, now.month, now.day, 20, 0);
    final todayEveningEnd = todayEveningStart.add(const Duration(hours: 1));

    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowStart =
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 8, 30);
    final tomorrowEnd = tomorrowStart.add(const Duration(hours: 2));

    addTask(Task(
      title: '晨间专注学习',
      description: '专注学习 1 小时',
      startDate: todayStart,
      endDate: todayEnd,
      category: SpiritType.light,
      repeatOption: RepeatOption.never,
      isAllDay: false,
    ));

    addTask(Task(
      title: '晚间散步',
      description: '放松心情，顺便听播客',
      startDate: todayEveningStart,
      endDate: todayEveningEnd,
      category: SpiritType.soil,
      repeatOption: RepeatOption.never,
      isAllDay: false,
    ));

    addTask(Task(
      title: '和朋友聚餐',
      description: '尝试新餐厅',
      startDate: tomorrowStart,
      endDate: tomorrowEnd,
      category: SpiritType.air,
      repeatOption: RepeatOption.never,
      isAllDay: false,
    ));
  }
}
