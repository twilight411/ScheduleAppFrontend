import '../models/plant_status.dart';

/// 抽象植物数据源，方便后续切换为远程接口或混合模式。
/// 
/// 对应 iOS 中的 PlantService，用于获取植物状态、周报和月度果实数据。
abstract class PlantRepository {
  /// 获取指定周的植物状态
  /// 
  /// [week] 表示该周内的任意一天，通常使用该周的第一天
  /// 返回该周的植物状态，包括精灵分数和植物图片
  Future<PlantStatus> getPlantStatus(DateTime week);

  /// 获取本周的AI周报
  /// 
  /// [week] 表示该周内的任意一天
  /// 返回该周的AI生成的周报文本（Markdown 或纯文本格式）
  Future<String> getWeekReport(DateTime week);

  /// 获取本月的果实数据
  /// 
  /// [month] 表示该月内的任意一天，通常使用该月的第一天
  /// 返回该月的果实数据，格式为 Map，包含果实类型、数量等信息
  Future<Map<String, dynamic>> getMonthFruit(DateTime month);
}
