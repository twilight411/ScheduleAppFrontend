import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/plant_provider.dart';
import '../widgets/plant_status_card.dart';
import '../widgets/radar_chart_widget.dart';
import '../widgets/week_report_widget.dart';
import '../widgets/month_fruit_widget.dart';
import '../utils/resource_manager.dart';

/// 植物页面
///
/// 对应 iOS 的 PlantViewController，显示植物状态、雷达图、周报和月果实。
class PlantPage extends StatefulWidget {
  const PlantPage({super.key});

  @override
  State<PlantPage> createState() => _PlantPageState();
}

class _PlantPageState extends State<PlantPage> {
  final PageController _pageController = PageController(
    initialPage: 1,
  ); // 默认显示第1页（雷达图）

  @override
  void initState() {
    super.initState();
    // 初始化时加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PlantProvider>(context, listen: false);
      // 数据已经在 PlantProvider 构造函数中自动加载，这里不需要再次调用
      // 但如果需要手动刷新，可以调用 provider.refresh()
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 透明背景，与 MainContainerView 的背景一致
      body: Consumer<PlantProvider>(
        builder: (context, provider, child) {
          // 如果正在加载且没有数据，显示加载指示器
          if (provider.isLoading && provider.plantStatus == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // 如果有数据，显示内容
          if (provider.plantStatus != null) {
            return _buildContent(provider);
          }

          // 如果没有数据，显示加载指示器
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContent(PlantProvider provider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 植物状态卡片（距离顶部20，左右边距20）
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: PlantStatusCard(
              plantStatus: provider.plantStatus!,
              currentWeek: provider.currentWeek,
              onPreviousWeek: () {
                provider.previousWeek();
              },
              onNextWeek: () {
                provider.nextWeek();
              },
            ),
          ),

          // PageView（距离植物状态卡片20，高度280）
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SizedBox(
              height: 280,
              child: PageView(
                controller: _pageController,
                children: [
                  // 第0页：月果实
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: MonthFruitWidget(
                      fruitData: provider.monthFruit ?? {},
                    ),
                  ),

                  // 第1页：雷达图（默认显示）
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: RadarChartWidget(
                      plantStatus: provider.plantStatus!,
                      // 背景贴图：参考 iOS 的 bottomBg
                      backgroundImagePath:
                          ResourceManager.backgrounds.plantBottom,
                    ),
                  ),

                  // 第2页：AI周报
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: WeekReportWidget(
                      reportText: provider.weekReport,
                      // 背景贴图：参考 iOS 的 bottomBg
                      backgroundImagePath:
                          ResourceManager.backgrounds.plantBottom,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 底部间距
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
