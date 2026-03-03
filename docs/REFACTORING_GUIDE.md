# 架构重构指南：Repository Pattern

## 📌 为什么要改？

**当前问题：**
- TaskProvider 和 WishProvider 直接调用 StorageService
- 无法轻松切换为后端接口
- 测试困难

**改进目标：**
- Provider 依赖抽象接口（Repository）
- 可以先用本地存储，后端准备好了再切换
- 方便测试和扩展

---

## 🔧 重构步骤

### 步骤 1: 创建 Repository 接口

**复制这条给 Cursor：**

```
请在 lib/repositories/ 目录下创建接口定义：

1. lib/repositories/task_repository.dart
   - 定义抽象类 TaskRepository
   - 包含方法：
     - Future<List<Task>> getAllTasks()
     - Future<List<Task>> getTasksByDate(DateTime date)
     - Future<List<Task>> getTasksBySpirit(SpiritType spirit)
     - Future<void> saveTask(Task task)
     - Future<void> updateTask(Task task)
     - Future<void> deleteTask(Task task)
     - Future<void> syncTasks() // 预留同步接口

2. lib/repositories/wish_repository.dart
   - 定义抽象类 WishRepository
   - 包含方法：
     - Future<List<Wish>> getAllWishes()
     - Future<void> saveWish(Wish wish)
     - Future<void> updateWish(Wish wish)
     - Future<void> deleteWish(String wishId)
     - Future<void> syncWishes() // 预留同步接口

3. lib/repositories/ai_chat_repository.dart
   - 定义抽象类 AIChatRepository
   - 包含方法：
     - Future<String> sendMessage({required String message, SpiritType? spiritType, bool isGroupChat})
   - 注意：前端不应该直接调用 DeepSeek API（API Key 会暴露），应该调用后端接口

注意：所有方法都是异步的，因为后续可能涉及网络请求。
```

---

### 步骤 2: 实现本地存储版本

**复制这条给 Cursor：**

```
请创建本地存储版本的 Repository 实现：

1. lib/repositories/local_task_repository.dart
   - 实现 TaskRepository 接口
   - 内部使用 StorageService 实现所有方法
   - 参考现有的 TaskProvider 中的 _loadInitialTasks 和 _persistTasks 逻辑

2. lib/repositories/local_wish_repository.dart
   - 实现 WishRepository 接口
   - 内部使用 StorageService 实现所有方法
   - 参考现有的 WishProvider 中的 _loadFromStorage 和 _syncToStorage 逻辑

3. lib/repositories/local_ai_chat_repository.dart
   - 实现 AIChatRepository 接口
   - 开发阶段可以返回 mock 数据（模拟 AI 回复）
   - 后端准备好后，可以用 RemoteAIChatRepository 替换
   - 注意：生产环境必须使用后端接口，不能直接调用 DeepSeek API

要求：
- 保持现有功能完全不变
- 只是把逻辑从 Provider 移到 Repository
- 所有方法都用 async/await
```

---

### 步骤 3: 修改 TaskProvider

**复制这条给 Cursor：**

```
请修改 lib/providers/task_provider.dart，改为依赖 TaskRepository 接口：

要求：
1. 构造函数接收 TaskRepository 参数：
   ```dart
   final TaskRepository _repository;
   
   TaskProvider({TaskRepository? repository})
     : _repository = repository ?? LocalTaskRepository();
   ```

2. 修改 addTask 方法：
   - 先添加到内存列表
   - 然后调用 _repository.saveTask(task)
   - 最后 notifyListeners()

3. 修改 removeTask 方法：
   - 先从内存列表删除
   - 然后调用 _repository.deleteTask(task.id)
   - 最后 notifyListeners()

4. 修改 _loadInitialTasks 方法：
   - 改为调用 _repository.getAllTasks()
   - 移除对 StorageService 的直接调用

5. 删除 _persistTasks 方法（不再需要）

6. 保持现有功能完全不变，只是数据来源从 StorageService 改为 Repository
```

---

### 步骤 4: 修改 WishProvider

**复制这条给 Cursor：**

```
请修改 lib/providers/wish_provider.dart，改为依赖 WishRepository 接口：

要求：
1. 构造函数接收 WishRepository 参数：
   ```dart
   final WishRepository _repository;
   
   WishProvider({WishRepository? repository})
     : _repository = repository ?? LocalWishRepository();
   ```

2. 修改所有方法，改为调用 _repository 的方法：
   - addWish: 先添加到内存，再调用 _repository.saveWish()
   - removeWish: 先从内存删除，再调用 _repository.deleteWish()
   - _loadFromStorage: 改为调用 _repository.getAllWishes()

3. 删除 _syncToStorage 方法（不再需要）

4. 保持现有功能完全不变
```

---

### 步骤 5: 确保功能正常

**复制这条给 Cursor：**

```
请检查修改后的代码，确保：

1. TaskProvider 和 WishProvider 不再直接导入 StorageService
2. 所有 Repository 实现都正确导入了 StorageService
3. main.dart 中创建 Provider 时不需要传参数（使用默认的 LocalRepository）
4. 运行应用，确保功能完全正常（任务列表、愿望列表、增删改查都正常）

如果发现问题，请修复。
```

---

## ✅ 重构完成检查清单

完成后应该：
- [ ] TaskProvider 依赖 TaskRepository 接口，不直接调用 StorageService
- [ ] WishProvider 依赖 WishRepository 接口，不直接调用 StorageService
- [ ] ChatProvider 依赖 AIChatRepository 接口（开发阶段用 mock 实现）
- [ ] 所有现有功能正常工作（任务增删改查、愿望增删改查）
- [ ] 代码结构更清晰，为后续后端接口集成做好准备
- [ ] **前端不会直接调用 DeepSeek API**（通过 Repository 接口，生产环境必须使用后端接口）

---

## 🚀 后续扩展（等后端准备好）

当后端接口准备好后，只需要：

1. 创建 `RemoteTaskRepository` 实现 `TaskRepository`
2. 在 `main.dart` 中切换：
   ```dart
   // 使用远程接口
   TaskRepository taskRepo = RemoteTaskRepository();
   TaskProvider taskProvider = TaskProvider(repository: taskRepo);
   ```

就这么简单！不需要改 Provider 的代码。
