# 阶段 1: 日历 + 任务系统 - Cursor 指令脚本

## 📌 前置条件

确保阶段 0 已完成：
- ✅ 三个主页面可以切换
- ✅ Task、Wish、SpiritType 模型已定义
- ✅ 依赖包已安装（provider, shared_preferences, intl）

---

## 指令 1-1: 创建 TaskProvider（状态管理）

**复制这条给 Cursor：**

```
请创建一个状态管理类 TaskProvider，用于管理任务列表。

在 lib/providers/task_provider.dart 中：

1. 继承 ChangeNotifier
2. 包含一个 List<Task> tasks 字段
3. 实现以下方法：
   - addTask(Task task): 添加任务（如果已存在相同任务则忽略），然后 notifyListeners()
   - removeTask(Task task): 删除任务
   - getTasksByDate(DateTime date): 返回指定日期的所有任务
   - getTasksBySpirit(SpiritType spirit): 返回指定精灵类型的任务
   - clearAll(): 清空所有任务

4. 在构造函数中，可以初始化几条假数据用于测试

参考 iOS 代码中 CalendarViewController 的 allTasks 和 filteredTasks 逻辑。
```

---

## 指令 1-2: 创建任务列表项 Widget

**复制这条给 Cursor：**

```
请创建一个可复用的任务列表项组件。

在 lib/widgets/task_item.dart 中创建一个 TaskItem widget：

要求：
1. 接收一个 Task 对象作为参数
2. 显示任务标题、开始时间、结束时间（格式化显示，如 "2024年1月15日 14:00"）
3. 显示精灵类型的小标签（用 Chip 或 Container，颜色对应 SpiritType.color）
4. 整体使用 Card 包裹，有圆角和阴影
5. 点击时可以高亮（可选功能）

样式参考 iOS 的 Task 列表展示方式。
```

---

## 指令 1-3: 实现 CalendarPage 的任务列表

**复制这条给 Cursor：**

```
请完善 lib/pages/calendar_page.dart，实现任务列表展示。

要求：
1. 改为 StatefulWidget
2. 使用 Provider 获取 TaskProvider
3. 顶部显示一个简单的日期选择器（可以用 showDatePicker，或者先显示当前日期）
4. 中间使用 ListView.builder 显示当前日期的任务列表
5. 使用刚才创建的 TaskItem widget 渲染每个任务
6. 右下角添加一个 FloatingActionButton，图标为 Icons.add，点击后跳转到 AddTaskPage
7. 如果当前日期没有任务，显示一个空状态（"今天还没有任务"）

参考 iOS 的 CalendarViewController 的布局和功能。
```

---

## 指令 1-4: 创建 AddTaskPage（新建任务页面）

**复制这条给 Cursor：**

```
请创建 lib/pages/add_task_page.dart，实现新建任务表单。

要求：
1. 使用 StatefulWidget
2. 表单字段包括：
   - 标题（TextField，必填）
   - 简介（TextField，可选）
   - 开始时间（显示当前选中的日期时间，点击弹出 DatePicker + TimePicker）
   - 结束时间（同上）
   - 是否全天（Switch）
   - 重复选项（DropdownButton，显示 RepeatOption.displayName）
   - 类别（水平排列的 ChoiceChip，显示所有 SpiritType，默认选中 light）

3. 顶部 AppBar：
   - 左侧"取消"按钮
   - 中间标题"新项目"
   - 右侧"添加"按钮

4. 点击"添加"时：
   - 校验标题不为空，否则显示 SnackBar 提示
   - 创建 Task 对象
   - 使用 Provider 调用 TaskProvider.addTask()
   - Navigator.pop() 返回上一页

5. 支持从外部传入预填充数据（可选参数 prefilledTitle, prefilledDescription, prefilledCategory），用于从愿望瓶转换

参考 iOS 的 AddTaskViewController 的完整功能。
```

---

## 指令 1-5: 实现任务本地存储（StorageService）

**复制这条给 Cursor：**

```
请创建 lib/services/storage_service.dart，实现任务的本地持久化。

要求：
1. 创建一个单例类 StorageService
2. 使用 shared_preferences 存储任务列表
3. 实现以下方法：
   - Future<void> saveTasks(List<Task> tasks): 将任务列表序列化为 JSON 字符串保存
   - Future<List<Task>> loadTasks(): 从 SharedPreferences 读取并反序列化为 Task 列表
   - Future<void> clearTasks(): 清空存储

4. JSON 序列化使用 Task 的 toJson/fromJson 方法
5. 存储的 key 为 "saved_tasks"

参考 iOS 代码中 WishBottleViewController 的 saveWishes/loadWishes 逻辑。
```

---

## 指令 1-6: 在 TaskProvider 中集成存储

**复制这条给 Cursor：**

```
请修改 lib/providers/task_provider.dart，集成 StorageService。

要求：
1. 在构造函数中，异步调用 StorageService.loadTasks() 加载已保存的任务
2. 每次调用 addTask 或 removeTask 后，自动调用 StorageService.saveTasks() 保存
3. 使用 FutureBuilder 或 initState 的方式处理异步加载

确保应用重启后任务列表能够恢复。
```

---

## 指令 1-7: 在 main.dart 中注册 Provider

**复制这条给 Cursor：**

```
请修改 lib/main.dart，在 MaterialApp 外层包裹 ChangeNotifierProvider。

要求：
1. 导入 provider 包
2. 使用 MultiProvider 或 ChangeNotifierProvider 注册 TaskProvider
3. 确保所有页面都能通过 Provider.of<TaskProvider>(context) 访问

示例结构：
```dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: MyApp(),
    ),
  );
}
```
```

---

## 指令 1-8: 添加任务筛选功能（按精灵类型）

**复制这条给 Cursor：**

```
请在 CalendarPage 中添加任务筛选功能。

要求：
1. 在页面顶部（日期选择器下方）添加一个水平滚动的精灵选择器
2. 显示所有 SpiritType，用 ChoiceChip 展示
3. 可以选中某个精灵，也可以选择"全部"（显示所有任务）
4. 根据选中的精灵类型，调用 TaskProvider.getTasksBySpirit() 过滤任务列表
5. 筛选状态可以保存在 CalendarPage 的 State 中

参考 iOS 代码中 CalendarViewController 的 selectedSpirit 和 filterTasksBySpirit 逻辑。
```

---

## ✅ 阶段 1 完成检查清单

完成以上所有指令后，你应该能够：

- [ ] 在日历页看到任务列表（可以先用假数据测试）
- [ ] 点击右下角 + 按钮，能打开 AddTaskPage
- [ ] 在 AddTaskPage 中填写任务信息，点击"添加"后能保存并返回
- [ ] 任务列表能正确显示新添加的任务
- [ ] 应用重启后，任务列表能够恢复（持久化存储正常）
- [ ] 可以通过精灵类型筛选任务

如果以上都完成了，就可以进入 **阶段 2：愿望瓶系统** 了！
