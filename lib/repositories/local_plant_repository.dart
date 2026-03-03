import 'package:intl/intl.dart';
import '../models/plant_status.dart';
import '../models/spirit_type.dart';
import 'plant_repository.dart';

/// 使用本地模拟数据作为植物数据源的实现。
/// 
/// 对应 iOS 中的 PlantService，提供模拟的植物状态、周报和月度果实数据。
class LocalPlantRepository implements PlantRepository {
  const LocalPlantRepository();

  @override
  Future<PlantStatus> getPlantStatus(DateTime week) async {
    // 模拟网络请求延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 计算该周的开始和结束日期
    final weekRange = _getWeekRange(week);

    // 模拟精灵分数（固定值，参考 iOS PlantService）
    final spiritScores = <SpiritType, double>{
      SpiritType.light: 0.8,
      SpiritType.water: 0.6,
      SpiritType.soil: 0.7,
      SpiritType.air: 0.5,
      SpiritType.nutrition: 0.9,
    };

    return PlantStatus(
      weekRange: weekRange,
      spiritScores: spiritScores,
      plantImageUrl: null, // 暂时返回 null，后续阶段5会添加图片URL
    );
  }

  @override
  Future<String> getWeekReport(DateTime week) async {
    // 模拟网络请求延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 返回模拟的周报文本（参考 iOS 的 setupWeekReport）
    return '''
本周你的表现非常出色！

学习进度：完成了85%的计划任务
运动健康：保持了每日运动习惯
社交活动：与朋友保持良好互动

建议：继续保持当前的良好状态，
适当增加阅读时间，让生活更充实。
''';
  }

  @override
  Future<Map<String, dynamic>> getMonthFruit(DateTime month) async {
    // 模拟网络请求延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 返回模拟的果实数据
    return {
      'fruitImageUrl': null, // 暂时返回 null，后续阶段5会添加图片URL
      'fruitName': '地球苹果',
      'description': '本月你完成了所有任务，获得了地球苹果！',
      'month': DateFormat('yyyy-MM').format(month),
      'earnedDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
    };
  }

  /// 计算指定日期所在周的开始和结束日期
  /// 
  /// [date] 表示该周内的任意一天
  /// 返回该周的开始日期（周一）和结束日期（周日）
  /// 
  /// 参考 iOS 的 PlantService.getWeekRange 方法
  DateRange _getWeekRange(DateTime date) {
    // 获取该日期是星期几（1=Monday, 7=Sunday）
    // Dart 的 weekday: 1=Monday, 7=Sunday
    final weekday = date.weekday;
    
    // 计算该周的开始日期（周一）
    final startOfWeek = date.subtract(Duration(days: weekday - 1));
    
    // 计算该周的结束日期（周日）
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    // 将时间设置为当天的开始（00:00:00）和结束（23:59:59）
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final end = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59);
    
    return DateRange(start: start, end: end);
  }
}
