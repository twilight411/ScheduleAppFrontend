import '../models/task.dart';

/// 抽象任务数据源，方便后续切换为远程接口或混合模式。
abstract class TaskRepository {
  /// 获取所有任务
  Future<List<Task>> getAllTasks();

  /// 持久化整个任务列表
  ///
  /// 当前实现为「整表保存」，后续可以扩展为增删改的细粒度方法。
  Future<void> saveTasks(List<Task> tasks);
}

