# 阶段 0: Flutter 基础架构搭建 - Cursor 指令脚本

## 📌 使用说明

这些指令是专门给 **Cursor AI** 用的，你只需要：
1. 在 Cursor 中打开 `schedule_app_flutter` 项目
2. 按顺序复制每条指令，发给 Cursor
3. 等 Cursor 生成代码后，检查并运行测试

---

## 指令 0-1: 创建项目目录结构

**复制这条给 Cursor：**

```
在这个 Flutter 项目中，请帮我创建以下目录结构：

lib/
├── models/
├── pages/
├── widgets/
├── services/
└── providers/

所有目录都应该是空的，暂时不需要创建文件。只需要确保这些文件夹存在即可。
```

---

## 指令 0-2: 定义 SpiritType 枚举

**复制这条给 Cursor：**

```
请参考 iOS 项目中的 SpiritType.swift，在 Flutter 项目中创建对应的模型。

在 lib/models/spirit_type.dart 中创建一个枚举：

enum SpiritType {
  light,      // 光精灵（工作学习）
  water,      // 水精灵（娱乐休闲）
  soil,       // 土壤精灵（健康）
  air,        // 空气精灵（社交）
  nutrition   // 营养精灵（爱好）
}

要求：
1. 添加一个扩展方法 `displayName` 返回中文名称（如 "光精灵"）
2. 添加一个扩展方法 `color` 返回对应的 Color（light=黄色，water=蓝色，soil=棕色，air=灰色，nutrition=绿色）
3. 添加一个扩展方法 `icon` 返回 Material Icons 的图标名称（light=sunny, water=water_drop, soil=eco, air=air, nutrition=star）

参考 iOS 代码：
- light.name = "光精灵", color = systemYellow
- water.name = "水精灵", color = systemBlue
- soil.name = "土壤精灵", color = systemBrown
- air.name = "空气精灵", color = systemGray
- nutrition.name = "营养精灵", color = systemGreen
```

---

## 指令 0-3: 定义 RepeatOption 枚举

**复制这条给 Cursor：**

```
在 lib/models/repeat_option.dart 中创建一个枚举：

enum RepeatOption {
  never,    // 永不
  daily,    // 每日重复
  weekly,   // 每周重复
  monthly   // 每月重复
}

要求：
1. 添加扩展方法 `displayName` 返回中文名称
2. 实现 `values` 静态方法返回所有枚举值（Dart 的 enum 自带，但可以显式列出）
```

---

## 指令 0-4: 定义 Task 数据模型

**复制这条给 Cursor：**

```
在 lib/models/task.dart 中创建一个 Task 类，对应 iOS 的 Task struct。

要求：
1. Task 类包含以下字段：
   - title: String
   - description: String
   - startDate: DateTime
   - endDate: DateTime
   - category: SpiritType
   - repeatOption: RepeatOption
   - isAllDay: bool

2. 实现构造函数和 copyWith 方法

3. 实现 toJson 和 fromJson 方法（用于 SharedPreferences 存储）：
   - startDate 和 endDate 存储为时间戳（毫秒）
   - category 和 repeatOption 存储为字符串

4. 实现 equals 和 hashCode（基于 title + startDate + endDate + category），用于去重

参考 iOS 代码中的 Task 结构：
```swift
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
```

---

## 指令 0-5: 定义 Wish 数据模型

**复制这条给 Cursor：**

```
在 lib/models/wish.dart 中创建一个 Wish 类，对应 iOS 的 Wish struct。

要求：
1. Wish 类包含以下字段：
   - id: String (UUID，用于唯一标识)
   - title: String
   - content: String
   - spirit: SpiritType
   - isChecked: bool (是否被选中)
   - createdDate: DateTime

2. 实现构造函数和 copyWith 方法

3. 实现 toJson 和 fromJson 方法（用于 SharedPreferences 存储）

参考 iOS 代码：
```swift
struct Wish {
    let id: UUID = UUID()
    let title: String
    let content: String
    let spirit: SpiritType
    var isChecked: Bool = false
    let createdDate: Date = Date()
}
```
```

---

## 指令 0-6: 创建三个主页面（占位版）

**复制这条给 Cursor：**

```
请创建三个主页面，目前只需要简单的占位界面：

1. lib/pages/calendar_page.dart
   - 一个 StatelessWidget，显示 "日历页" 文字（居中）

2. lib/pages/plant_page.dart
   - 一个 StatelessWidget，显示 "植物页" 文字（居中）

3. lib/pages/profile_page.dart
   - 一个 StatelessWidget，显示 "我的页" 文字（居中）

每个页面都使用 Scaffold，背景色为白色，文字使用大号字体。
```

---

## 指令 0-7: 修改 main.dart 实现底部导航

**复制这条给 Cursor：**

```
请修改 lib/main.dart，实现一个底部导航栏（BottomNavigationBar），包含三个页面：
- 日历（CalendarPage）
- 植物（PlantPage）
- 我的（ProfilePage）

要求：
1. 使用 StatefulWidget 管理当前选中的页面索引
2. BottomNavigationBar 有三个 item：
   - 图标：calendar_today，文字："日历"
   - 图标：local_florist，文字："植物"
   - 图标：person，文字："我的"
3. 根据选中的索引切换显示对应的页面
4. 默认选中第一个（日历页）
5. 顶部 AppBar 标题根据当前页面动态变化：
   - 日历/植物页：显示 "我的安排"
   - 我的页：显示 "我的"

请给出完整的 main.dart 代码。
```

---

## 指令 0-8: 更新 pubspec.yaml 添加必要依赖

**复制这条给 Cursor：**

```
请在 pubspec.yaml 的 dependencies 部分添加以下依赖包：

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.1.1          # 状态管理
  http: ^1.1.0              # 网络请求
  shared_preferences: ^2.2.2  # 本地存储
  intl: ^0.19.0             # 日期格式化
```

然后告诉我需要运行什么命令来安装这些依赖。
```

---

## ✅ 阶段 0 完成检查清单

完成以上所有指令后，你应该能够：

- [ ] 运行 `flutter pub get` 安装依赖
- [ ] 运行 `flutter run` 看到底部导航栏和三个页面可以切换
- [ ] 在 `lib/models/` 下有完整的 `spirit_type.dart`, `repeat_option.dart`, `task.dart`, `wish.dart`
- [ ] 顶部 AppBar 标题会根据页面切换变化

如果以上都完成了，就可以进入 **阶段 1：日历 + 任务系统** 了！
