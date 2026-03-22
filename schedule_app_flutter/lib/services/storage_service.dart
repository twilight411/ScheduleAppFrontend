import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import '../models/wish.dart';

/// 负责任务/愿望列表的本地持久化存储
///
/// 对应 iOS 中相关控制器的 save/load 逻辑，
/// 这里使用 SharedPreferences 保存 JSON 字符串。
class StorageService {
  StorageService._internal();

  static final StorageService _instance = StorageService._internal();

  /// 单例实例
  static StorageService get instance => _instance;

  static const String _tasksKey = 'saved_tasks';
  static const String _wishesKey = 'saved_wishes';

  /// 保存任务列表到本地
  ///
  /// 会将 [tasks] 转换为 List<Map>，再编码为 JSON 字符串存储。
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        tasks.map((task) => task.toJson()).toList();
    final String jsonString = jsonEncode(jsonList);
    await prefs.setString(_tasksKey, jsonString);
  }

  /// 从本地加载任务列表
  ///
  /// 若本地不存在数据或解析失败，则返回空列表。
  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_tasksKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      final tasks = decoded
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
      return tasks;
    } catch (_) {
      // 若解析失败，返回空列表，避免整个应用崩溃
      return [];
    }
  }

  /// 清空本地保存的任务列表
  Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
  }

  /// 保存愿望列表到本地
  ///
  /// 会将 [wishes] 转换为 List<Map>，再编码为 JSON 字符串存储。
  Future<void> saveWishes(List<Wish> wishes) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        wishes.map((wish) => wish.toJson()).toList();
    final String jsonString = jsonEncode(jsonList);
    await prefs.setString(_wishesKey, jsonString);
  }

  /// 从本地加载愿望列表
  ///
  /// 若本地不存在数据或解析失败，则返回空列表。
  Future<List<Wish>> loadWishes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_wishesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      final wishes = decoded
          .map((e) => Wish.fromJson(e as Map<String, dynamic>))
          .toList();
      return wishes;
    } catch (_) {
      // 若解析失败，返回空列表，避免整个应用崩溃
      return [];
    }
  }

  /// 清空本地保存的愿望列表
  Future<void> clearWishes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_wishesKey);
  }
}

