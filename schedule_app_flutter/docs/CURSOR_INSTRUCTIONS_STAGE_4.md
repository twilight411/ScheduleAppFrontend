# 阶段 4: 植物页面 - Cursor 指令脚本

## 📌 前置条件

确保阶段 0-3 已完成：
- ✅ 基础架构搭建完成
- ✅ 任务系统完成
- ✅ 愿望瓶系统完成
- ✅ AI 聊天系统完成
- ✅ 依赖包已安装（provider, shared_preferences, intl）

---

## 🎯 阶段 4 目标

实现植物页面（PlantPage），UI界面要与 iOS 项目的 `PlantViewController.swift` **基本一致**，包括：

1. **植物状态卡片**（顶部）
   - 周标签显示（如"上周 1月15日—1月21日"）
   - 植物图片（居中显示）
   - 左右切换按钮（切换周）

2. **底部横向滚动视图**（3个页面）
   - **第0页：月果实** - 显示本月果实图片
   - **第1页：雷达图** - 显示精灵雷达图（默认显示）
   - **第2页：AI周报** - 显示本周AI生成的周报文本

3. **后端接口预留**
   - 使用 Repository 模式，预留后端接口
   - 当前使用本地数据，后续可切换为后端接口

---

## 指令 4-1: 创建 PlantStatus 模型

**复制这条给 Cursor：**

```
请参考 iOS 项目的 PlantStatus.swift，在 Flutter 项目中创建对应的模型。

在 lib/models/plant_status.dart 中：

1. 创建 PlantStatus 类：
   - weekRange: DateRange（周的开始和结束日期）
   - spiritScores: Map<SpiritType, double>（每个精灵的分数，0.0-1.0）
   - plantImageUrl: String?（植物图片URL，可选）

2. 添加 toJson/fromJson 方法（用于序列化）

3. 添加 DateRange 辅助类（包含 start 和 end 两个 DateTime）

参考 iOS 代码：
```swift
struct PlantStatus {
    var weekRange: DateInterval
    var spiritScores: [SpiritType: Float]
    var plantImage: UIImage?
}
```

注意：Flutter 使用 Map 而不是字典，使用 double 而不是 Float。
```

---

## 指令 4-2: 创建 PlantRepository 接口（预留后端）

**复制这条给 Cursor：**

```
请创建植物数据的 Repository 接口，预留后端接口。

在 lib/repositories/plant_repository.dart 中：

1. 创建抽象类 PlantRepository：
   ```dart
   abstract class PlantRepository {
     /// 获取指定周的植物状态
     Future<PlantStatus> getPlantStatus(DateTime week);
     
     /// 获取本周的AI周报
     Future<String> getWeekReport(DateTime week);
     
     /// 获取本月的果实数据
     Future<Map<String, dynamic>> getMonthFruit(DateTime month);
   }
   ```

2. 这个接口用于后续切换为后端接口，当前先用本地实现。

参考 BACKEND_INTEGRATION_PLAN.md 中的 Repository 模式设计。
```

---

## 指令 4-3: 创建 LocalPlantRepository 实现

**复制这条给 Cursor：**

```
请创建本地植物数据 Repository 实现。

在 lib/repositories/local_plant_repository.dart 中：

1. 实现 PlantRepository 接口
2. getPlantStatus 方法：
   - 根据传入的 week 日期，计算该周的开始和结束日期
   - 返回模拟数据（spiritScores 使用固定值，如 light: 0.8, water: 0.6 等）
   - plantImageUrl 暂时返回 null

3. getWeekReport 方法：
   - 返回模拟的周报文本（参考 iOS 的 setupWeekReport 中的文本）

4. getMonthFruit 方法：
   - 返回模拟的果实数据（包含图片URL等信息）

参考 iOS 的 PlantService.swift 中的 fetchPlantStatus 方法。
```

---

## 指令 4-4: 创建 PlantProvider（状态管理）

**复制这条给 Cursor：**

```
请创建植物页面的状态管理类。

在 lib/providers/plant_provider.dart 中：

1. 继承 ChangeNotifier
2. 包含以下字段：
   - currentWeek: DateTime（当前显示的周）
   - plantStatus: PlantStatus?（当前周的植物状态）
   - weekReport: String?（本周的AI周报）
   - monthFruit: Map<String, dynamic>?（本月果实数据）
   - isLoading: bool（加载状态）

3. 实现以下方法：
   - Future<void> loadPlantStatus(DateTime week): 加载指定周的植物状态
   - Future<void> loadWeekReport(DateTime week): 加载周报
   - Future<void> loadMonthFruit(DateTime month): 加载月果实
   - void previousWeek(): 切换到上一周
   - void nextWeek(): 切换到下一周

4. 构造函数接收 PlantRepository（默认使用 LocalPlantRepository）

5. 在 loadPlantStatus 中调用 repository.getPlantStatus，并更新 plantStatus

参考 iOS 的 PlantViewController 中的 currentWeek 和 updatePlantDisplay 逻辑。
```

---

## 指令 4-5: 创建植物状态卡片 Widget

**复制这条给 Cursor：**

```
请创建植物状态卡片组件。

在 lib/widgets/plant_status_card.dart 中：

1. 创建一个 StatelessWidget PlantStatusCard：
   - 接收 PlantStatus 和当前周（DateTime）作为参数
   - 接收 onPreviousWeek 和 onNextWeek 回调

2. UI 布局（参考 iOS 的 setupPlantStatusView）：
   - 背景：使用 Container 或 DecorationImage（如果有背景图）
   - 顶部：周标签（如"上周 1月15日—1月21日"），字体大小14，居中
   - 中间：植物图片（180x180），居中显示
   - 左右两侧：切换按钮（使用 IconButton，图标为 Icons.chevron_left 和 Icons.chevron_right）

3. 样式要求：
   - 圆角：20
   - 背景色：白色半透明（Colors.white.withOpacity(0.3)）或使用背景图
   - 按钮：白色图标，带阴影效果
   - 整体高度：300

4. 日期格式化使用 intl 包，格式为"M月d日"

参考 iOS 代码中的约束和样式：
- plantStatusView.heightAnchor = 300
- weekLabel.topAnchor = 35
- plantImageView = 180x180
- previousButton/nextButton = 30x30
```

---

## 指令 4-6: 创建雷达图 Widget

**复制这条给 Cursor：**

```
请创建雷达图组件。

在 lib/widgets/radar_chart_widget.dart 中：

1. 创建一个 StatelessWidget RadarChartWidget：
   - 接收 PlantStatus 作为参数（用于显示精灵分数）

2. 当前阶段：显示静态图片
   - 如果有雷达图背景图片，使用 Image.asset 显示
   - 如果没有，使用占位符（Container + 文字提示）

3. 后续可以升级为动态绘制雷达图（使用 CustomPaint）

4. 样式要求：
   - 圆角：20
   - 背景：使用背景图或半透明白色
   - 图片居中显示，占容器的90%

参考 iOS 的 setupRadarChart 方法：
- 使用 ResourceManager.Plant.radarSample 图片
- 图片大小 = 容器大小 * 0.9
```

---

## 指令 4-7: 创建周报 Widget

**复制这条给 Cursor：**

```
请创建AI周报组件。

在 lib/widgets/week_report_widget.dart 中：

1. 创建一个 StatelessWidget WeekReportWidget：
   - 接收周报文本（String）作为参数

2. UI 布局（参考 iOS 的 setupWeekReport）：
   - 顶部：标题"本周AI周报"，字体大小18，粗体，居中
   - 下方：周报内容文本，字体大小13，左对齐，多行显示
   - 使用 ScrollView 支持长文本滚动

3. 样式要求：
   - 圆角：20
   - 背景：使用背景图或半透明白色
   - 标题距离顶部：45
   - 内容距离标题：20
   - 左右边距：35 和 25

4. 如果没有周报文本，显示"暂无周报数据"

参考 iOS 代码中的布局约束：
- titleLabel.topAnchor = 45
- contentLabel.topAnchor = titleLabel.bottomAnchor + 20
- contentLabel.leading = 35, trailing = -25
```

---

## 指令 4-8: 创建月果实 Widget

**复制这条给 Cursor：**

```
请创建月果实组件。

在 lib/widgets/month_fruit_widget.dart 中：

1. 创建一个 StatelessWidget MonthFruitWidget：
   - 接收果实数据（Map<String, dynamic>）作为参数

2. UI 布局（参考 iOS 的 setupMonthFruit）：
   - 顶部：标题"本月果实"，字体大小18，粗体，居中
   - 中间：果实图片，180x180，居中显示
   - 标题距离顶部：45

3. 样式要求：
   - 圆角：20
   - 背景：使用背景图或半透明白色
   - 如果没有图片，显示占位图标（Icons.star，橙色）

参考 iOS 代码：
- titleLabel.topAnchor = 45
- fruitImageView = 180x180
- 使用 ResourceManager.Plant.monthFruit 图片
```

---

## 指令 4-9: 实现 PlantPage 主页面

**复制这条给 Cursor：**

```
请实现植物页面主界面。

在 lib/pages/plant_page.dart 中：

1. 改为 StatefulWidget
2. 使用 Provider 获取 PlantProvider
3. 布局结构（参考 iOS 的 PlantViewController）：
   - 外层：SingleChildScrollView（垂直滚动）
   - 顶部：PlantStatusCard（植物状态卡片）
   - 底部：PageView（横向滚动，3个页面）
     - 第0页：MonthFruitWidget（月果实）
     - 第1页：RadarChartWidget（雷达图，默认显示）
     - 第2页：WeekReportWidget（AI周报）

4. 初始化：
   - 在 initState 中调用 PlantProvider.loadPlantStatus、loadWeekReport、loadMonthFruit
   - 默认显示当前周

5. 页面切换：
   - PageView 默认显示第1页（雷达图）
   - 支持左右滑动切换

6. 样式要求：
   - 背景：透明（与 MainContainerView 的背景一致）
   - 植物状态卡片：距离顶部20，左右边距20
   - PageView：距离植物状态卡片20，高度280
   - 每个页面：左右边距20，圆角20

7. 加载状态：
   - 如果 isLoading 为 true，显示 CircularProgressIndicator

参考 iOS 代码的完整布局和约束：
- scrollView（垂直滚动）
- plantStatusView（顶部，高度300）
- bottomScrollView（横向滚动，高度280）
- 三个子视图：monthFruitView, radarChartView, weekReportView
```

---

## 指令 4-10: 在 main.dart 中注册 PlantProvider

**复制这条给 Cursor：**

```
请修改 lib/main.dart，在 MultiProvider 中添加 PlantProvider。

要求：
1. 导入 plant_provider.dart 和 local_plant_repository.dart
2. 在 providers 列表中添加：
   ```dart
   ChangeNotifierProvider<PlantProvider>(
     create: (_) => PlantProvider(
       repository: LocalPlantRepository(),
     ),
   ),
   ```

3. 确保 PlantPage 可以通过 Provider.of<PlantProvider>(context) 访问
```

---

## 指令 4-11: 图片资源说明（阶段4可用占位符）

**重要说明：**

阶段4需要以下图片资源，但**可以先使用占位符**（颜色或系统图标），完整的图片资源迁移将在阶段5完成。

### 阶段4需要的图片资源清单：

1. **植物状态卡片相关：**
   - `plant_status_bg.png` - 植物状态背景图
   - `tree_sample.png` - 植物图片（180x180）
   - `arrow_left.png` - 左箭头图标
   - `arrow_right.png` - 右箭头图标

2. **底部页面相关：**
   - `radar_sample.png` - 雷达图背景
   - `month_fruit_sample.png` - 月果实图片（180x180）
   - `plant_bottom_bg.png` - 底部页面背景图

### 当前阶段4的处理方式：

- **可以使用占位符**：使用 `Container` + 颜色或 `Icon` 图标
- **示例**：
  ```dart
  // 植物图片占位符
  Icon(Icons.eco, size: 180, color: Colors.green)
  
  // 背景占位符
  Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.3),
      borderRadius: BorderRadius.circular(20),
    ),
  )
  ```

### 完整图片资源迁移：

将在**阶段5**完成，包括：
- 迁移所有 iOS Assets 图片到 Flutter assets 目录
- 创建 ResourceManager 工具类
- 更新所有 Widget 使用真实图片

**详细步骤请参考阶段5文档。**

---

## 📋 完成检查清单

完成阶段 4 后，请检查：

- [ ] PlantStatus 模型已创建
- [ ] PlantRepository 接口已定义（预留后端）
- [ ] LocalPlantRepository 已实现（使用模拟数据）
- [ ] PlantProvider 已创建并注册
- [ ] PlantStatusCard Widget 已创建（UI与iOS一致）
- [ ] RadarChartWidget 已创建（显示静态图片）
- [ ] WeekReportWidget 已创建（显示周报文本）
- [ ] MonthFruitWidget 已创建（显示果实图片）
- [ ] PlantPage 已实现（布局与iOS一致）
- [ ] 可以切换周（上一周/下一周）
- [ ] 底部横向滚动正常（3个页面）
- [ ] 默认显示雷达图页面

---

## 🎨 UI 对齐要求

**重要：UI界面要与 iOS 项目的 PlantViewController 基本一致**

### 布局结构
```
┌─────────────────────────┐
│   PlantStatusCard       │ ← 顶部，高度300
│   (周标签 + 植物图)     │
└─────────────────────────┘
         ↓ 间距20
┌─────────────────────────┐
│   PageView (横向滚动)   │ ← 高度280
│   ┌─────┬─────┬─────┐   │
│   │月果 │雷达 │周报 │   │ ← 3个页面，默认显示雷达图
│   │实   │图   │     │   │
│   └─────┴─────┴─────┘   │
└─────────────────────────┘
```

### 尺寸要求
- 植物状态卡片：高度300，左右边距20
- 植物图片：180x180
- 切换按钮：30x30
- PageView：高度280
- 每个页面：左右边距20，圆角20

### 样式要求
- 圆角：20
- 背景：半透明白色或背景图
- 字体：标题18粗体，内容13常规
- 颜色：参考 iOS 项目的颜色方案

---

## 🔌 后端接口预留

### 当前实现（阶段4）
- 使用 `LocalPlantRepository`（模拟数据）
- 数据存储在本地或使用假数据

### 后续切换（后端准备好后）
1. 创建 `RemotePlantRepository` 实现 `PlantRepository` 接口
2. 在 `main.dart` 中切换：
   ```dart
   PlantProvider(
     repository: RemotePlantRepository(), // 切换为远程
   )
   ```

### 后端接口设计（参考）

**获取植物状态：**
```
GET /api/plant/status?week=2024-01-15
Response: {
  "weekRange": {
    "start": "2024-01-15",
    "end": "2024-01-21"
  },
  "spiritScores": {
    "light": 0.8,
    "water": 0.6,
    "soil": 0.7,
    "air": 0.5,
    "nutrition": 0.9
  },
  "plantImageUrl": "https://..."
}
```

**获取周报：**
```
GET /api/plant/week-report?week=2024-01-15
Response: {
  "report": "本周你的表现非常出色！\n\n学习进度：完成了85%的计划任务..."
}
```

**获取月果实：**
```
GET /api/plant/month-fruit?month=2024-01
Response: {
  "fruitImageUrl": "https://...",
  "description": "..."
}
```

---

## 🚀 下一步

完成阶段 4 后，继续阶段 5：个人主页 + 资源迁移
