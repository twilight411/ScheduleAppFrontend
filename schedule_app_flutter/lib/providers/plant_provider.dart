import 'package:flutter/foundation.dart';
import '../models/plant_status.dart';
import '../repositories/local_plant_repository.dart';
import '../repositories/plant_repository.dart';

/// 植物页面的状态管理类
/// 
/// 对应 iOS 中的 PlantViewController，管理植物状态、周报和月度果实数据。
class PlantProvider extends ChangeNotifier {
  /// 当前显示的周（该周内的任意一天）
  DateTime currentWeek;

  /// 当前周的植物状态
  PlantStatus? plantStatus;

  /// 本周的AI周报
  String? weekReport;

  /// 本月果实数据
  Map<String, dynamic>? monthFruit;

  /// 加载状态
  bool isLoading = false;

  /// 植物数据源（当前使用本地实现，后续可替换为远程或混合实现）
  final PlantRepository _repository;

  PlantProvider({
    PlantRepository? repository,
    DateTime? initialWeek,
  })  : _repository = repository ?? const LocalPlantRepository(),
        currentWeek = initialWeek ?? DateTime.now() {
    // 初始化时加载当前周的数据
    _loadAllData();
  }

  /// 加载指定周的植物状态
  Future<void> loadPlantStatus(DateTime week) async {
    try {
      isLoading = true;
      notifyListeners();

      final status = await _repository.getPlantStatus(week);
      plantStatus = status;
    } catch (e) {
      debugPrint('加载植物状态失败: $e');
      // 发生错误时保持原有状态
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 加载指定周的AI周报
  Future<void> loadWeekReport(DateTime week) async {
    try {
      final report = await _repository.getWeekReport(week);
      weekReport = report;
      notifyListeners();
    } catch (e) {
      debugPrint('加载周报失败: $e');
      // 发生错误时保持原有状态
    }
  }

  /// 加载指定月的果实数据
  Future<void> loadMonthFruit(DateTime month) async {
    try {
      final fruit = await _repository.getMonthFruit(month);
      monthFruit = fruit;
      notifyListeners();
    } catch (e) {
      debugPrint('加载月果实失败: $e');
      // 发生错误时保持原有状态
    }
  }

  /// 切换到上一周
  /// 
  /// 参考 iOS 的 previousWeekTapped 方法
  void previousWeek() {
    currentWeek = currentWeek.subtract(const Duration(days: 7));
    _loadAllData();
  }

  /// 切换到下一周
  /// 
  /// 参考 iOS 的 nextWeekTapped 方法
  void nextWeek() {
    currentWeek = currentWeek.add(const Duration(days: 7));
    _loadAllData();
  }

  /// 加载所有数据（植物状态、周报、月果实）
  /// 
  /// 在切换周时调用，同时加载当前周的所有相关数据
  Future<void> _loadAllData() async {
    // 并行加载所有数据，提高性能
    await Future.wait([
      loadPlantStatus(currentWeek),
      loadWeekReport(currentWeek),
      loadMonthFruit(currentWeek),
    ]);
  }

  /// 刷新当前数据
  /// 
  /// 手动刷新当前周的所有数据
  Future<void> refresh() async {
    await _loadAllData();
  }
}
