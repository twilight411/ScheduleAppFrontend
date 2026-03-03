import '../models/task.dart';
import '../services/storage_service.dart';
import 'task_repository.dart';

/// 使用本地 StorageService 作为任务数据源的实现。
class LocalTaskRepository implements TaskRepository {
  const LocalTaskRepository();

  @override
  Future<List<Task>> getAllTasks() async {
    return StorageService.instance.loadTasks();
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    await StorageService.instance.saveTasks(List<Task>.from(tasks));
  }
}

