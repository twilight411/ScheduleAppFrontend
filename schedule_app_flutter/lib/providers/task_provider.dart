import 'package:flutter/foundation.dart';

import '../models/repeat_option.dart';
import '../models/spirit_type.dart';
import '../models/task.dart';
import '../repositories/local_task_repository.dart';
import '../repositories/task_repository.dart';

/// 用于管理任务列表的状态管理类
///
/// 对标 iOS 中 `CalendarViewController` 里的 `allTasks` / `filteredTasks` 逻辑：
/// - `tasks` 相当于 `allTasks`
/// - 通过 `getTasksByDate` / `getTasksBySpirit` 做筛选，相当于 `filteredTasks`
class TaskProvider extends ChangeNotifier {
  /// 所有任务列表
  final List<Task> tasks = [];

  /// 任务数据源（当前使用本地实现，后续可替换为远程或混合实现）
  final TaskRepository _repository;

  /// 供 UI 使用的初始化 Future（可用于 FutureBuilder）
  late final Future<void> initializeFuture;

  TaskProvider({TaskRepository? repository})
      : _repository = repository ?? const LocalTaskRepository() {
    initializeFuture = _loadInitialTasks();
  }

  /// 添加任务（如果已存在相同任务则忽略）
  ///
  /// 利用了 `Task` 继承 `Equatable` 的特性，
  /// 去重依据为 `task.dart` 中 `props` 定义的字段
  void addTask(Task task) {
    if (tasks.contains(task)) {
      return;
    }
    tasks.add(task);
    _persistTasks();
    notifyListeners();
  }

  /// 删除任务
  void removeTask(Task task) {
    tasks.remove(task);
    _persistTasks();
    notifyListeners();
  }

  /// 更新任务（按 Equatable 相等找到原任务并替换为 newTask）
  void updateTask(Task oldTask, Task newTask) {
    final index = tasks.indexWhere((t) => t == oldTask);
    if (index >= 0) {
      tasks[index] = newTask;
      _persistTasks();
      notifyListeners();
    }
  }

  /// 根据具体日期筛选任务
  ///
  /// 这里按「同一天」判断，即 `year/month/day` 相同即可。
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
    final loadedTasks = await _repository.getAllTasks();
    if (loadedTasks.isNotEmpty) {
      tasks
        ..clear()
        ..addAll(loadedTasks);
      notifyListeners();
    } else {
      _initMockData();
      await _repository.saveTasks(tasks);
    }
  }

  /// 将当前任务列表持久化到本地
  Future<void> _persistTasks() async {
    // 不阻塞 UI，忽略等待结果
    await _repository.saveTasks(List<Task>.from(tasks));
  }

  /// 初始化一些假数据，方便界面测试
  void _initMockData() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day, 9, 0);
    final todayEnd = todayStart.add(const Duration(hours: 1));

    final todayEveningStart = DateTime(now.year, now.month, now.day, 20, 0);
    final todayEveningEnd = todayEveningStart.add(const Duration(hours: 1));

    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowStart = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 8, 30);
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

