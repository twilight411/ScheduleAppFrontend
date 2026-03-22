# 阶段 2: 愿望瓶系统 - Cursor 指令脚本

## 📌 前置条件

确保阶段 1 已完成：
- ✅ TaskProvider 和任务列表正常工作
- ✅ AddTaskPage 可以创建任务并返回
- ✅ 本地存储功能正常

## 📸 图片资源迁移说明

**阶段 2 会用到的图片资源：**
- 愿望瓶图标（iOS: `Assets.xcassets/Calendar/wish_bottle.imageset/`）
- 精灵卡片图（iOS: `Assets.xcassets/Spirits/spirit_card_0~4.imageset/`）

**建议：** 
- 先用 Material Icons 占位（如 `Icons.auto_awesome` 代替愿望瓶图标）
- 到阶段 4-5 统一迁移所有图片资源更高效
- 如果想先看到视觉效果，可以在阶段 2 执行完后单独迁移这几张图

---

## 指令 2-1: 创建 WishProvider（状态管理）

**复制这条给 Cursor：**

```
请创建一个状态管理类 WishProvider，用于管理愿望列表。

在 lib/providers/wish_provider.dart 中：

1. 继承 ChangeNotifier
2. 包含一个 List<Wish> wishes 字段
3. 包含一个 int? selectedWishIndex 字段（记录当前选中的愿望索引，null 表示未选中）
4. 实现以下方法：
   - addWish(Wish wish): 添加愿望到列表末尾，然后 notifyListeners()
   - removeWish(int index): 删除指定索引的愿望，如果删除的是选中项则清空选中状态
   - toggleWishSelection(int index): 切换愿望的选中状态（单选模式，选中一个时自动取消其他选中）
   - clearSelection(): 清空选中状态
   - getSelectedWish(): Wish?: 返回当前选中的愿望，如果没有则返回 null
   - clearAll(): 清空所有愿望

5. 在构造函数中，可以初始化几条假数据用于测试（参考 iOS 的默认愿望数据）

参考 iOS 代码中 WishBottleViewController 的 wishes 和 selectedWishIndex 逻辑。
```

---

## 指令 2-2: 创建愿望列表项 Widget

**复制这条给 Cursor：**

```
请创建一个可复用的愿望列表项组件。

在 lib/widgets/wish_item.dart 中创建一个 WishItem widget：

要求：
1. 接收 Wish 对象、isSelected、onCheckboxTapped 作为参数
2. 使用 Card 包裹，有圆角和阴影
3. 布局包含：
   - 左侧：复选框（Checkbox，选中状态对应 isSelected）
   - 中间：标题、内容、创建日期
   - 右侧：精灵卡片图（先用 Material Icons 或彩色 Container 占位，显示 spirit 的图标）
   - 右下角：精灵名称标签（用 Chip，颜色对应 spirit.color）

4. 选中时，Card 边框变粗，背景色略微变化（类似 iOS 的选中效果）

5. 点击复选框区域时，调用 onCheckboxTapped 回调

参考 iOS 代码中 WishTableViewCell 的布局和交互。
```

---

## 指令 2-3: 创建 WishBottlePage（愿望瓶主页面）

**复制这条给 Cursor：**

```
请创建 lib/pages/wish_bottle_page.dart，实现愿望瓶主界面。

要求：
1. 使用 StatefulWidget
2. 使用 Provider 获取 WishProvider
3. 布局结构：
   - 顶部 AppBar：左侧"取消"按钮，中间标题"愿望瓶"，右侧"新增"按钮
   - 中间操作按钮区域：
     - "发送给AI"按钮（只有当选中愿望时才可用，颜色根据选中愿望的精灵类型变化）
     - "手动转换为日程"按钮（同样只有当选中愿望时才可用）
   - 中间愿望列表：
     - 标题："暂存待办" + 数量标签（如 "3条"）
     - ListView.builder 显示愿望列表，使用 WishItem widget
   - 底部："+ 新增愿望"按钮
   - 空状态：如果没有愿望，显示空状态提示（"暂无愿望\n点击下方按钮添加你的第一个愿望"）

4. 按钮交互：
   - "发送给AI"：跳转到 ChatPage（阶段 3 实现，这里先留 TODO）
   - "手动转换为日程"：跳转到 AddTaskPage，预填标题、描述、类别（使用 AddTaskPage 的 prefilledTitle, prefilledDescription, prefilledCategory 参数）
   - "新增"或"+ 新增愿望"：跳转到 AddWishPage
   - "取消"：Navigator.pop()

5. 按钮状态管理：
   - 根据 selectedWishIndex 是否为 null 来决定按钮是否可用
   - 按钮颜色根据选中愿望的 spirit.color 动态变化（参考 iOS 的 updateButtonsForSpirit 逻辑）

参考 iOS 代码中 WishBottleViewController 的完整功能和布局。
```

---

## 指令 2-4: 创建 AddWishPage（新增愿望页面）

**复制这条给 Cursor：**

```
请创建 lib/pages/add_wish_page.dart，实现新增愿望表单。

要求：
1. 使用 StatefulWidget
2. 表单字段：
   - 标题输入框（TextField，必填）
   - 内容输入框（TextField 或 TextField multiline，必填）
   - 精灵选择区域：
     - 标题："选择负责精灵"
     - 水平排列的 ChoiceChip，显示所有 SpiritType
     - 每个 Chip 显示精灵图标（Material Icons）+ 中文名称
     - 选中时边框和背景色变化（对应精灵的颜色）
   - 精灵预览卡片（显示当前选中精灵的说明文字）

3. 顶部 AppBar：
   - 左侧"取消"按钮
   - 中间标题"新增心愿"
   - 右侧"确定"按钮

4. 点击"确定"时：
   - 校验标题和内容不为空，否则显示 SnackBar 提示
   - 创建 Wish 对象
   - 使用 Provider 调用 WishProvider.addWish()
   - Navigator.pop() 返回上一页

5. 精灵预览卡片显示不同精灵的描述：
   - 光精灵：负责工作学习相关的愿望
   - 水精灵：负责娱乐休闲相关的愿望
   - 土壤精灵：负责健康运动相关的愿望
   - 空气精灵：负责社交活动相关的愿望
   - 营养精灵：负责兴趣爱好相关的愿望

参考 iOS 代码中 AddWishViewController 的完整功能。
```

---

## 指令 2-5: 实现愿望本地存储

**复制这条给 Cursor：**

```
请修改 lib/services/storage_service.dart，添加愿望列表的存储功能。

要求：
1. 在 StorageService 中添加以下方法：
   - Future<void> saveWishes(List<Wish> wishes): 将愿望列表序列化为 JSON 字符串保存
   - Future<List<Wish>> loadWishes(): 从 SharedPreferences 读取并反序列化为 Wish 列表
   - Future<void> clearWishes(): 清空愿望存储

2. JSON 序列化使用 Wish 的 toJson/fromJson 方法
3. 存储的 key 为 "saved_wishes"

4. 参考 Task 存储的实现方式，保持代码风格一致

参考 iOS 代码中 WishBottleViewController 的 saveWishes/loadWishes 逻辑。
```

---

## 指令 2-6: 在 WishProvider 中集成存储

**复制这条给 Cursor：**

```
请修改 lib/providers/wish_provider.dart，集成 StorageService。

要求：
1. 在构造函数中，异步调用 StorageService.loadWishes() 加载已保存的愿望
2. 每次调用 addWish 或 removeWish 后，自动调用 StorageService.saveWishes() 保存
3. 使用 FutureBuilder 或 initState 的方式处理异步加载

确保应用重启后愿望列表能够恢复。
```

---

## 指令 2-7: 实现愿望转换为日程功能

**复制这条给 Cursor：**

```
请完善 WishBottlePage 中的"手动转换为日程"功能。

要求：
1. 在"手动转换为日程"按钮的 onPressed 中：
   - 获取当前选中的愿望（通过 WishProvider.getSelectedWish()）
   - 如果选中愿望，跳转到 AddTaskPage，传入：
     - prefilledTitle: wish.title
     - prefilledDescription: wish.content
     - prefilledCategory: wish.spirit
   - 使用 await 等待 AddTaskPage 返回结果

2. 当 AddTaskPage 成功创建任务并返回时：
   - 从 WishProvider 中删除该愿望（removeWish）
   - 显示 SnackBar 提示："愿望「xxx」已成功转换为日程"
   - 清空选中状态

3. 参考 iOS 代码中 WishBottleViewController 的 manualConvertTapped 和 AddTaskViewControllerDelegate 逻辑。
```

---

## 指令 2-8: 在 main.dart 中注册 WishProvider

**复制这条给 Cursor：**

```
请修改 lib/main.dart，添加 WishProvider 到 MultiProvider。

要求：
1. 在 MultiProvider 的 providers 列表中添加：
   ChangeNotifierProvider<WishProvider>(
     create: (_) => WishProvider(),
   ),

2. 确保所有页面都能通过 Provider.of<WishProvider>(context) 访问

3. 更新导入语句，引入 wish_provider.dart
```

---

## 指令 2-9: 在 CalendarPage 中添加愿望瓶入口

**复制这条给 Cursor：**

```
请修改 lib/pages/calendar_page.dart，添加愿望瓶入口按钮。

要求：
1. 在日历页面的某个位置（建议左上角或右上角）添加一个图标按钮
2. 图标使用 Material Icons.auto_awesome 或 Icons.workspace_premium（代表愿望瓶）
3. 点击后打开 WishBottlePage（Navigator.push）
4. 可以使用 AppBar 的 actions 或者在页面顶部添加自定义按钮

参考 iOS 代码中 CalendarViewController 的 wishBottleButton。
```

---

## ✅ 阶段 2 完成检查清单

完成以上所有指令后，你应该能够：

- [ ] 在主页面看到愿望瓶入口按钮
- [ ] 点击愿望瓶入口，能打开 WishBottlePage
- [ ] 在 WishBottlePage 中能看到愿望列表（可以先用假数据测试）
- [ ] 点击"新增愿望"能打开 AddWishPage
- [ ] 在 AddWishPage 中填写信息，能成功创建愿望并返回
- [ ] 愿望列表能正确显示新添加的愿望
- [ ] 点击愿望的复选框，能选中/取消选中（单选模式）
- [ ] 选中愿望后，"发送给AI"和"转换为日程"按钮变为可用
- [ ] 点击"转换为日程"，能跳转到 AddTaskPage 并预填信息
- [ ] 成功创建任务后，对应愿望被删除
- [ ] 应用重启后，愿望列表能够恢复（持久化存储正常）

如果以上都完成了，就可以进入 **阶段 3：AI 聊天精灵系统** 了！
