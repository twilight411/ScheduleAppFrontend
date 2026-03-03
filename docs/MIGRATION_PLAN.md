# ScheduleApp Flutter 迁移规划

## 📋 项目概述

将 iOS ScheduleApp（UIKit + Swift）迁移到 Flutter，实现跨平台（Android + iOS）统一代码库。

## 🏗️ 技术栈选择

- **UI 框架**: Flutter 3.x + Material Design 3
- **状态管理**: Provider（初期简单，后期可升级 Riverpod/BLoC）
- **路由导航**: Navigator 2.0（先用简单 Navigator.push，后期可升级 GoRouter）
- **网络请求**: `http` 包（调用 DeepSeek API）
- **本地存储**: `shared_preferences`（任务/愿望列表），后期可升级 `sqflite`
- **日期处理**: `intl` 包
- **JSON 序列化**: `json_serializable` 或手动 `toJson/fromJson`

## 📁 项目目录结构

```
lib/
├── main.dart                    # 应用入口
├── models/                      # 数据模型
│   ├── task.dart
│   ├── wish.dart
│   ├── spirit_type.dart
│   └── plant_status.dart
├── pages/                       # 页面
│   ├── calendar_page.dart
│   ├── plant_page.dart
│   ├── profile_page.dart
│   ├── add_task_page.dart
│   ├── wish_bottle_page.dart
│   ├── add_wish_page.dart
│   └── chat_page.dart
├── widgets/                     # 可复用组件
│   ├── task_item.dart
│   ├── wish_item.dart
│   ├── spirit_chip.dart
│   └── chat_bubble.dart
├── services/                    # 业务逻辑层
│   ├── ai_service.dart          # DeepSeek API
│   ├── storage_service.dart     # 本地存储
│   └── plant_service.dart       # 植物状态计算
└── providers/                   # 状态管理
    ├── task_provider.dart
    ├── wish_provider.dart
    └── chat_provider.dart
```

## 🎯 迁移阶段规划

### 阶段 0: 基础架构搭建（1 天）
- ✅ 创建目录结构
- ✅ 定义基础模型（Task, Wish, SpiritType, RepeatOption）
- ✅ 搭建主导航（BottomNavigationBar + 三个主页面）
- ✅ 配置主题和基础样式

### 阶段 1: 日历 + 任务系统（2-3 天）
- ✅ CalendarPage：任务列表展示
- ✅ AddTaskPage：新建任务表单
- ✅ 任务本地存储（SharedPreferences）
- ✅ 任务筛选（按日期、按精灵类型）

### 阶段 2: 愿望瓶系统（2 天）
- ✅ WishBottlePage：愿望列表
- ✅ AddWishPage：新增愿望
- ✅ 愿望转换为任务功能
- ✅ 愿望本地存储

### 阶段 3: AI 聊天精灵（2-3 天）
- ✅ ChatPage：聊天界面
- ✅ 接入 DeepSeek API（迁移 iOS 的 AIAPIManager）
- ✅ 精灵选择与群聊/私聊切换
- ✅ 从愿望瓶发送到 AI

### 阶段 4: 植物页面（2 天）
- ⏳ PlantPage：植物状态卡片（待实现）
- ⏳ 周报展示（待实现）
- ⏳ 本月果实展示（待实现）
- ⏳ 雷达图（静态图片）（待实现）
- ⏳ Repository 模式预留后端接口（待实现）

**详细指令：** 参考 `docs/CURSOR_INSTRUCTIONS_STAGE_4.md`

### 阶段 5: 个人主页 + 资源迁移（1-2 天）
- ⏳ ProfilePage：用户信息与设置（待实现）
- ⏳ 迁移 iOS Assets 图片资源（待实现）
- ⏳ 创建 ResourceManager 工具类（待实现）
- ⏳ 更新所有页面使用真实图片（待实现）
- ⏳ 视觉优化与动画（待实现）

**详细指令：** 参考 `docs/CURSOR_INSTRUCTIONS_STAGE_5.md`

## 📝 关键模型对照

### SpiritType (iOS → Flutter)
```swift
// iOS
enum SpiritType: Int {
    case light = 0
    case water = 1
    // ...
}
```

```dart
// Flutter
enum SpiritType {
  light,    // 光精灵（工作学习）
  water,    // 水精灵（娱乐休闲）
  soil,     // 土壤精灵（健康）
  air,      // 空气精灵（社交）
  nutrition // 营养精灵（爱好）
}
```

### Task (iOS → Flutter)
```swift
// iOS
struct Task: Hashable {
    let title: String
    let description: String
    let startDate: Date
    let endDate: Date
    let category: SpiritType
    let repeatOption: RepeatOption
    let isAllDay: Bool
}
```

```dart
// Flutter
class Task {
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final SpiritType category;
  final RepeatOption repeatOption;
  final bool isAllDay;
  
  // toJson/fromJson for storage
}
```

## 🔄 迁移策略

1. **模型优先**: 先定义好所有数据模型，确保与 iOS 版本一致
2. **页面逐个迁移**: 按阶段顺序，每个页面独立完成
3. **功能对齐**: 每个功能都参考 iOS 版本的交互逻辑
4. **资源复用**: iOS Assets 中的图片资源可以直接迁移到 Flutter `assets/` 目录

## 📦 依赖包清单

需要在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1          # 状态管理
  http: ^1.1.0              # 网络请求
  shared_preferences: ^2.2.2  # 本地存储
  intl: ^0.19.0             # 日期格式化
  table_calendar: ^3.0.9    # 日历组件（可选）
```

## 🚀 下一步

请按照阶段 0 的指令脚本开始迁移。
