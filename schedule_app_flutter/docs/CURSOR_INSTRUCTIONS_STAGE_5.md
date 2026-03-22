# 阶段 5: 个人主页 + 资源迁移 - Cursor 指令脚本

## 📌 前置条件

确保阶段 0-4 已完成：
- ✅ 基础架构搭建完成
- ✅ 任务系统完成
- ✅ 愿望瓶系统完成
- ✅ AI 聊天系统完成
- ✅ 植物页面完成（可以使用占位符图片）

---

## 🎯 阶段 5 目标

1. **完善个人主页（ProfilePage）**
   - 用户信息展示
   - 设置菜单项
   - UI与iOS版本一致

2. **迁移所有图片资源**
   - 从 iOS Assets.xcassets 迁移到 Flutter assets 目录
   - 创建 ResourceManager 工具类
   - 更新所有页面使用真实图片

3. **视觉优化与动画**
   - 添加过渡动画
   - 优化UI细节

---

## 指令 5-1: 创建 assets 目录结构

**复制这条给 Cursor：**

```
请在 Flutter 项目中创建图片资源目录结构。

1. 在项目根目录创建以下目录：
   ```
   assets/
   ├── images/
   │   ├── backgrounds/
   │   ├── navigation/
   │   ├── calendar/
   │   ├── spirits/
   │   ├── ai_chat/
   │   ├── plant/
   │   └── profile/
   ```

2. 在 pubspec.yaml 中添加资源声明：
   ```yaml
   flutter:
     assets:
       - assets/images/backgrounds/
       - assets/images/navigation/
       - assets/images/calendar/
       - assets/images/spirits/
       - assets/images/ai_chat/
       - assets/images/plant/
       - assets/images/profile/
   ```

3. 注意：暂时不需要复制图片文件，先创建目录结构即可。
```

---

## 指令 5-2: 迁移背景图片资源

**复制这条给 Cursor：**

```
请从 iOS 项目的 Assets.xcassets/Backgrounds 目录迁移背景图片到 Flutter。

需要迁移的图片：
1. main_background.png - 主背景图
2. plant_status_bg.png - 植物状态背景
3. plant_bottom_bg.png - 植物底部背景
4. ai_chat_bg.png - AI聊天背景

迁移步骤：
1. 从 iOS 项目的 Assets.xcassets/Backgrounds/ 目录找到对应的 .png 文件
2. 复制到 Flutter 项目的 assets/images/backgrounds/ 目录
3. 保持文件名一致

参考 iOS 路径：
- ScheduleApp/ScheduleApp/Assets.xcassets/Backgrounds/main_background.imageset/main_background.png
```

---

## 指令 5-3: 迁移导航图标资源

**复制这条给 Cursor：**

```
请从 iOS 项目的 Assets.xcassets/Navigation 目录迁移导航图标。

需要迁移的图片：
1. icon_calendar.png - 日历图标
2. icon_plant.png - 植物图标
3. icon_profile.png - 个人中心图标

迁移步骤：
1. 从 iOS 项目的 Assets.xcassets/Navigation/ 目录找到对应的 .png 文件
2. 复制到 Flutter 项目的 assets/images/navigation/ 目录
3. 保持文件名一致
```

---

## 指令 5-4: 迁移日历界面图片资源

**复制这条给 Cursor：**

```
请从 iOS 项目的 Assets.xcassets/Calendar 目录迁移日历界面图片。

需要迁移的图片：
1. wish_bottle.png - 愿望瓶图标
2. add_task.png - 添加任务图标
3. leaf_day.png - 日视图叶子图标
4. leaf_week.png - 周视图叶子图标
5. leaf_month.png - 月视图叶子图标
6. leaf_selected.png - 选中状态叶子图标
7. calendar_full.png - 完整日历图标
8. calendar_small.png - 小日历图标

迁移步骤：
1. 从 iOS 项目的 Assets.xcassets/Calendar/ 目录找到对应的 .png 文件
2. 复制到 Flutter 项目的 assets/images/calendar/ 目录
3. 保持文件名一致
```

---

## 指令 5-5: 迁移精灵图标资源

**复制这条给 Cursor：**

```
请从 iOS 项目的 Assets.xcassets/Spirits 目录迁移精灵图标。

需要迁移的图片：
1. spirit_light.png - 光精灵图标
2. spirit_water.png - 水精灵图标
3. spirit_soil.png - 土壤精灵图标
4. spirit_air.png - 空气精灵图标
5. spirit_nutrition.png - 营养精灵图标
6. spirit_card_0.png 到 spirit_card_4.png - 精灵卡片图片（5张）

迁移步骤：
1. 从 iOS 项目的 Assets.xcassets/Spirits/ 目录找到对应的 .png 文件
2. 复制到 Flutter 项目的 assets/images/spirits/ 目录
3. 保持文件名一致
```

---

## 指令 5-6: 迁移AI聊天图片资源

**复制这条给 Cursor：**

```
请从 iOS 项目的 Assets.xcassets/AIChat 目录迁移AI聊天图片。

需要迁移的图片：
1. chat_group.png - 群聊图标
2. chat_private.png - 私聊图标
3. arrow_up.png - 向上箭头
4. arrow_down.png - 向下箭头
5. input_box_bg.png - 输入框背景

迁移步骤：
1. 从 iOS 项目的 Assets.xcassets/AIChat/ 目录找到对应的 .png 文件
2. 复制到 Flutter 项目的 assets/images/ai_chat/ 目录
3. 保持文件名一致
```

---

## 指令 5-7: 迁移植物界面图片资源

**复制这条给 Cursor：**

```
请从 iOS 项目的 Assets.xcassets/Plant 目录迁移植物界面图片。

需要迁移的图片：
1. tree_sample.png - 植物树图片
2. arrow_left.png - 左箭头
3. arrow_right.png - 右箭头
4. radar_sample.png - 雷达图背景
5. month_fruit_sample.png - 月果实图片
6. share_tag.png - 分享标签
7. shelf_background.png - 果实架子背景（在 Plant/fruits/ 目录下）
8. fruit_sample_1.png 到 fruit_sample_5.png - 果实样本图片（5张，在 Plant/fruits/ 目录下）

迁移步骤：
1. 从 iOS 项目的 Assets.xcassets/Plant/ 目录找到对应的 .png 文件
2. 复制到 Flutter 项目的 assets/images/plant/ 目录
3. 果实相关图片（shelf_background, fruit_sample_*）也放在 plant/ 目录下
4. 保持文件名一致
```

---

## 指令 5-8: 迁移个人中心图片资源

**复制这条给 Cursor：**

```
请从 iOS 项目的 Assets.xcassets/Profile 目录迁移个人中心图片。

需要迁移的图片：
1. icon_share.png - 分享图标
2. icon_subscription.png - 订阅图标
3. icon_personality.png - 性格图标
4. icon_decoration.png - 装饰图标
5. icon_widget.png - 小组件图标
6. icon_contact.png - 联系图标
7. icon_settings.png - 设置图标
8. icon_logout.png - 退出图标
9. subscription_item_bg.png - 订阅项背景
10. 最大矩形.png - 个人中心背景矩形

迁移步骤：
1. 从 iOS 项目的 Assets.xcassets/Profile/ 目录找到对应的 .png 文件
2. 复制到 Flutter 项目的 assets/images/profile/ 目录
3. 保持文件名一致
```

---

## 指令 5-9: 创建 ResourceManager 工具类

**复制这条给 Cursor：**

```
请创建 ResourceManager 工具类，对应 iOS 的 ResourceManager.swift。

在 lib/utils/resource_manager.dart 中：

1. 创建 ResourceManager 类，包含以下静态结构：
   - Backgrounds - 背景图片路径
   - Navigation - 导航图标路径
   - Calendar - 日历界面图片路径
   - Spirits - 精灵图标路径
   - AIChat - AI聊天图片路径
   - Plant - 植物界面图片路径
   - Profile - 个人中心图片路径

2. 每个结构包含静态 getter 方法，返回图片路径字符串：
   ```dart
   class ResourceManager {
     static class Backgrounds {
       static String get main => 'assets/images/backgrounds/main_background.png';
       static String get plantStatus => 'assets/images/backgrounds/plant_status_bg.png';
       static String get plantBottom => 'assets/images/backgrounds/plant_bottom_bg.png';
       static String get aiChat => 'assets/images/backgrounds/ai_chat_bg.png';
     }
     
     static class Navigation {
       static String get calendar => 'assets/images/navigation/icon_calendar.png';
       static String get plant => 'assets/images/navigation/icon_plant.png';
       static String get profile => 'assets/images/navigation/icon_profile.png';
     }
     
     // ... 其他结构
   }
   ```

3. 参考 iOS 的 ResourceManager.swift 结构，确保路径对应正确。

4. 添加辅助方法：
   ```dart
   /// 根据 SpiritType 获取精灵图标路径
   static String getSpiritIcon(SpiritType type) {
     switch (type) {
       case SpiritType.light:
         return Spirits.light;
       case SpiritType.water:
         return Spirits.water;
       // ... 其他类型
     }
   }
   ```

参考 iOS 代码：ScheduleApp/ScheduleApp/Utills/ResourceManager.swift
```

---

## 指令 5-10: 更新植物页面使用真实图片

**复制这条给 Cursor：**

```
请更新植物页面的所有 Widget，使用 ResourceManager 加载真实图片。

需要更新的文件：
1. lib/widgets/plant_status_card.dart
   - 使用 ResourceManager.Backgrounds.plantStatus 作为背景
   - 使用 ResourceManager.Plant.treeSample 作为植物图片
   - 使用 ResourceManager.Plant.arrowLeft 和 arrowRight 作为箭头图标

2. lib/widgets/radar_chart_widget.dart
   - 使用 ResourceManager.Plant.radarSample 作为雷达图

3. lib/widgets/month_fruit_widget.dart
   - 使用 ResourceManager.Backgrounds.plantBottom 作为背景
   - 使用 ResourceManager.Plant.monthFruit 作为果实图片

更新方式：
- 将占位符（Icon 或 Container）替换为 Image.asset()
- 使用 ResourceManager 获取图片路径
- 添加错误处理：如果图片加载失败，显示占位符

示例：
```dart
Image.asset(
  ResourceManager.Backgrounds.plantStatus,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return Container(
      color: Colors.white.withOpacity(0.3),
      child: Icon(Icons.image_not_supported),
    );
  },
)
```
```

---

## 指令 5-11: 更新其他页面使用真实图片

**复制这条给 Cursor：**

```
请更新其他页面使用真实图片资源。

需要更新的页面：
1. lib/pages/main_container_view.dart
   - 使用 ResourceManager.Backgrounds.main 作为主背景
   - 使用 ResourceManager.Navigation 的图标作为底部导航栏图标

2. lib/pages/calendar_page.dart
   - 使用 ResourceManager.Calendar 的图标

3. lib/pages/chat_page.dart
   - 使用 ResourceManager.Backgrounds.aiChat 作为背景
   - 使用 ResourceManager.AIChat 的图标

4. lib/widgets/task_item.dart 和 lib/widgets/wish_item.dart
   - 使用 ResourceManager.Spirits 的图标显示精灵类型

更新方式：
- 查找所有使用占位符或系统图标的地方
- 替换为 ResourceManager 对应的图片路径
- 添加错误处理
```

---

## 指令 5-12: 完善 ProfilePage 页面

**复制这条给 Cursor：**

```
请完善个人主页（ProfilePage），参考 iOS 的 ProfileViewController.swift。

在 lib/pages/profile_page.dart 中：

1. UI 布局（参考 iOS 的 setupUI）：
   - 顶部：用户信息卡片（头像、昵称、ID）
   - 中间：菜单列表（使用 ListView）
   - 背景：使用 ResourceManager.Backgrounds.main

2. 菜单项（参考 iOS 的 setupMenuItems）：
   - 分享（使用 ResourceManager.Profile.iconShare）
   - 订阅（使用 ResourceManager.Profile.iconSubscription）
   - 性格分析（使用 ResourceManager.Profile.iconPersonality）
   - 装饰（使用 ResourceManager.Profile.iconDecoration）
   - 小组件（使用 ResourceManager.Profile.iconWidget）
   - 联系（使用 ResourceManager.Profile.iconContact）
   - 设置（使用 ResourceManager.Profile.iconSettings）
   - 退出登录（使用 ResourceManager.Profile.iconLogout）

3. 样式要求：
   - 菜单项使用 Card 包裹，圆角16
   - 每个菜单项包含图标和文字
   - 点击时有高亮效果
   - 使用 ResourceManager.Profile.subscriptionItemBg 作为订阅项背景

4. 功能要求：
   - 菜单项点击暂时显示 SnackBar 提示（后续实现具体功能）
   - 退出登录显示确认对话框

参考 iOS 代码：
- ScheduleApp/ScheduleApp/Controllers/ProfileViewController.swift
- 布局约束和样式保持一致
```

---

## 指令 5-13: 添加视觉优化和动画

**复制这条给 Cursor：**

```
请为应用添加视觉优化和过渡动画。

1. 页面切换动画：
   - 在 main_container_view.dart 中，底部导航切换时添加淡入淡出动画
   - 使用 AnimatedSwitcher 或 PageView 实现平滑过渡

2. 列表项动画：
   - 在任务列表和愿望列表中，添加列表项出现动画
   - 使用 AnimatedList 或 ListView.builder 配合动画

3. 按钮点击反馈：
   - 为所有按钮添加点击缩放动画
   - 使用 GestureDetector 的 onTapDown/onTapUp 实现

4. 加载状态优化：
   - 使用 CircularProgressIndicator 或自定义加载动画
   - 添加骨架屏（Skeleton）效果（可选）

5. 图片加载优化：
   - 使用 FadeInImage 实现图片淡入效果
   - 添加图片缓存（使用 cached_network_image 包，如果后续使用网络图片）

示例代码：
```dart
// 页面切换动画
AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  transitionBuilder: (child, animation) {
    return FadeTransition(opacity: animation, child: child);
  },
  child: _currentPage,
)

// 按钮点击动画
GestureDetector(
  onTapDown: (_) => setState(() => _isPressed = true),
  onTapUp: (_) => setState(() => _isPressed = false),
  onTapCancel: () => setState(() => _isPressed = false),
  child: Transform.scale(
    scale: _isPressed ? 0.95 : 1.0,
    child: YourButton(),
  ),
)
```
```

---

## 指令 5-14: 验证图片资源完整性

**复制这条给 Cursor：**

```
请验证所有图片资源是否已正确迁移和使用。

检查清单：
1. 检查 pubspec.yaml 中的 assets 声明是否完整
2. 检查所有图片文件是否已复制到对应目录
3. 检查 ResourceManager 中的路径是否正确
4. 运行应用，检查所有页面是否正常显示图片
5. 检查是否有图片加载失败的情况（查看控制台错误）

如果发现缺失的图片：
- 从 iOS 项目找到对应文件
- 复制到 Flutter 项目的对应目录
- 更新 ResourceManager（如果需要）

如果图片加载失败：
- 检查文件路径是否正确
- 检查文件名是否匹配（注意大小写）
- 检查 pubspec.yaml 是否正确声明
- 运行 `flutter pub get` 重新加载资源
```

---

## 📋 完成检查清单

完成阶段 5 后，请检查：

- [ ] assets 目录结构已创建
- [ ] 所有背景图片已迁移（main_background, plant_status_bg, plant_bottom_bg, ai_chat_bg）
- [ ] 所有导航图标已迁移（calendar, plant, profile）
- [ ] 所有日历界面图片已迁移（wish_bottle, add_task, leaf_*, calendar_*）
- [ ] 所有精灵图标已迁移（spirit_*, spirit_card_*）
- [ ] 所有AI聊天图片已迁移（chat_*, arrow_*, input_box_bg）
- [ ] 所有植物界面图片已迁移（tree_sample, arrow_*, radar_sample, month_fruit_sample, fruit_sample_*）
- [ ] 所有个人中心图片已迁移（icon_*, subscription_item_bg, 最大矩形）
- [ ] ResourceManager 工具类已创建
- [ ] 植物页面已更新使用真实图片
- [ ] 其他页面已更新使用真实图片
- [ ] ProfilePage 已完善（用户信息、菜单列表）
- [ ] 视觉优化和动画已添加
- [ ] 所有图片资源验证通过

---

## 🎨 图片资源对照表

### 背景图片（Backgrounds）
| iOS 路径 | Flutter 路径 | 用途 |
|---------|-------------|------|
| Backgrounds/main_background | assets/images/backgrounds/main_background.png | 主背景 |
| Backgrounds/plant_status_bg | assets/images/backgrounds/plant_status_bg.png | 植物状态背景 |
| Backgrounds/plant_bottom_bg | assets/images/backgrounds/plant_bottom_bg.png | 植物底部背景 |
| Backgrounds/ai_chat_bg | assets/images/backgrounds/ai_chat_bg.png | AI聊天背景 |

### 导航图标（Navigation）
| iOS 路径 | Flutter 路径 | 用途 |
|---------|-------------|------|
| Navigation/icon_calendar | assets/images/navigation/icon_calendar.png | 日历图标 |
| Navigation/icon_plant | assets/images/navigation/icon_plant.png | 植物图标 |
| Navigation/icon_profile | assets/images/navigation/icon_profile.png | 个人中心图标 |

### 植物界面（Plant）
| iOS 路径 | Flutter 路径 | 用途 |
|---------|-------------|------|
| Plant/tree_sample | assets/images/plant/tree_sample.png | 植物树图片 |
| Plant/arrow_left | assets/images/plant/arrow_left.png | 左箭头 |
| Plant/arrow_right | assets/images/plant/arrow_right.png | 右箭头 |
| Plant/radar_sample | assets/images/plant/radar_sample.png | 雷达图 |
| Plant/month_fruit_sample | assets/images/plant/month_fruit_sample.png | 月果实 |
| Plant/fruits/fruit_sample_* | assets/images/plant/fruit_sample_*.png | 果实样本（5张） |
| Plant/fruits/shelf_background | assets/images/plant/shelf_background.png | 果实架子背景 |

### 个人中心（Profile）
| iOS 路径 | Flutter 路径 | 用途 |
|---------|-------------|------|
| Profile/icon_share | assets/images/profile/icon_share.png | 分享图标 |
| Profile/icon_subscription | assets/images/profile/icon_subscription.png | 订阅图标 |
| Profile/icon_personality | assets/images/profile/icon_personality.png | 性格图标 |
| Profile/icon_decoration | assets/images/profile/icon_decoration.png | 装饰图标 |
| Profile/icon_widget | assets/images/profile/icon_widget.png | 小组件图标 |
| Profile/icon_contact | assets/images/profile/icon_contact.png | 联系图标 |
| Profile/icon_settings | assets/images/profile/icon_settings.png | 设置图标 |
| Profile/icon_logout | assets/images/profile/icon_logout.png | 退出图标 |
| Profile/subscription_item_bg | assets/images/profile/subscription_item_bg.png | 订阅项背景 |
| Profile/最大矩形 | assets/images/profile/最大矩形.png | 个人中心背景 |

---

## 🚀 下一步

完成阶段 5 后，Flutter 迁移基本完成！

后续可以：
- 优化性能和用户体验
- 添加更多动画效果
- 准备后端接口集成（参考 BACKEND_INTEGRATION_PLAN.md）
- 进行跨平台测试（Android + iOS）
