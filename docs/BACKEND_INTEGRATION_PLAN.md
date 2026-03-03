# 后端接口集成规划

## 📋 需要后端接口的功能清单

### ✅ **肯定需要后端接口**（多设备同步）

1. **任务管理 (Task)**
   - 获取任务列表（按日期、按精灵类型筛选）
   - 创建任务
   - 更新任务
   - 删除任务
   - 同步任务（多设备间同步）

2. **愿望管理 (Wish)**
   - 获取愿望列表
   - 创建愿望
   - 更新愿望（包括选中状态）
   - 删除愿望
   - 同步愿望（多设备间同步）

3. **用户信息 (Profile)**
   - 获取用户信息（昵称、ID、头像、统计数据）
   - 更新用户信息
   - 用户设置（主题、通知等）

4. **植物状态 (PlantStatus)** ⚠️ **可能需要**
   - 获取植物状态（根据任务完成情况计算）
   - 获取周报数据（AI 生成的周报）
   - 获取月度果实数据
   - 可能后端需要统计任务完成率来计算植物状态

5. **AI 聊天** 🔒 **必须通过后端**（安全考虑）
   - ❌ **不应该在前端直接调用 DeepSeek API**（API Key 会暴露）
   - ✅ **应该调用后端接口**，后端再调用 DeepSeek API
   - 发送聊天消息到后端
   - 接收 AI 回复
   - AI 聊天历史（多设备同步）

### ❌ **不需要后端接口**（纯前端功能）

1. **本地缓存**
   - 即使有后端，也需要本地缓存（离线使用、减少请求）
   - AI 聊天历史也可以本地缓存（但主要存储在服务器）

---

## 🏗️ 架构改进方案

### 问题诊断

**当前架构问题：**
```
TaskProvider ──直接调用──> StorageService (SharedPreferences)
WishProvider ──直接调用──> StorageService (SharedPreferences)
```

**问题：**
- Provider 和存储实现强耦合
- 无法轻松切换为后端接口
- 测试困难（依赖真实存储）

### 改进方案：Repository Pattern

**目标架构：**
```
TaskProvider ──依赖抽象──> TaskRepository (接口)
                              ↓ 实现
                    ┌──────────┴──────────┐
                    ↓                     ↓
        LocalTaskRepository    RemoteTaskRepository
        (本地存储)              (后端接口)
```

**好处：**
1. Provider 只依赖接口，不关心具体实现
2. 可以先用本地存储开发，后端准备好了再切换
3. 可以同时支持本地 + 远程（本地缓存 + 远程同步）
4. 方便单元测试（可以 mock Repository）

---

## 🔧 需要修改的代码

### 1. 创建 Repository 接口层

#### TaskRepository 接口
```dart
// lib/repositories/task_repository.dart
abstract class TaskRepository {
  Future<List<Task>> getAllTasks();
  Future<List<Task>> getTasksByDate(DateTime date);
  Future<List<Task>> getTasksBySpirit(SpiritType spirit);
  Future<void> saveTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Future<void> syncTasks(); // 从服务器同步
}
```

#### WishRepository 接口
```dart
// lib/repositories/wish_repository.dart
abstract class WishRepository {
  Future<List<Wish>> getAllWishes();
  Future<void> saveWish(Wish wish);
  Future<void> updateWish(Wish wish);
  Future<void> deleteWish(String wishId);
  Future<void> syncWishes(); // 从服务器同步
}
```

#### AIChatRepository 接口
```dart
// lib/repositories/ai_chat_repository.dart
abstract class AIChatRepository {
  // 发送消息到后端，后端调用 DeepSeek API
  Future<String> sendMessage({
    required String message,
    SpiritType? spiritType,  // 指定精灵（私聊模式）
    bool isGroupChat = false, // 群聊/私聊模式
  });
  
  // 获取聊天历史（可选）
  Future<List<ChatMessage>> getChatHistory();
  
  // 保存聊天记录到服务器（可选）
  Future<void> saveChatMessage(ChatMessage message);
}
```

### 2. 实现本地存储版本

#### LocalTaskRepository
```dart
// lib/repositories/local_task_repository.dart
class LocalTaskRepository implements TaskRepository {
  final StorageService _storage;
  
  // 实现所有接口方法，内部调用 StorageService
}
```

### 3. 修改 Provider 依赖接口

**修改前：**
```dart
class TaskProvider {
  void addTask(Task task) {
    tasks.add(task);
    _persistTasks(); // 直接调用 StorageService
  }
}
```

**修改后：**
```dart
class TaskProvider {
  final TaskRepository _repository;
  
  TaskProvider({TaskRepository? repository}) 
    : _repository = repository ?? LocalTaskRepository();
  
  void addTask(Task task) {
    tasks.add(task);
    _repository.saveTask(task); // 通过接口调用
  }
}
```

### 4. 预留远程接口实现

#### RemoteTaskRepository（后续实现）
```dart
// lib/repositories/remote_task_repository.dart
class RemoteTaskRepository implements TaskRepository {
  final ApiService _apiService;
  
  // 实现所有接口方法，内部调用 API
  @override
  Future<List<Task>> getAllTasks() async {
    final response = await _apiService.get('/api/tasks');
    // 解析 JSON 返回 Task 列表
  }
  
  @override
  Future<void> saveTask(Task task) async {
    await _apiService.post('/api/tasks', task.toJson());
  }
}
```

#### RemoteAIChatRepository（后续实现）
```dart
// lib/repositories/remote_ai_chat_repository.dart
class RemoteAIChatRepository implements AIChatRepository {
  final ApiService _apiService;
  
  // 调用后端接口，后端再调用 DeepSeek API
  @override
  Future<String> sendMessage({
    required String message,
    SpiritType? spiritType,
    bool isGroupChat = false,
  }) async {
    final response = await _apiService.post('/api/ai/chat', {
      'message': message,
      'spiritType': spiritType?.name,
      'isGroupChat': isGroupChat,
    });
    // 解析响应，返回 AI 回复文本
    return response['reply'] as String;
  }
}
```

### 5. 混合模式（本地缓存 + 远程同步）

#### HybridTaskRepository
```dart
// lib/repositories/hybrid_task_repository.dart
class HybridTaskRepository implements TaskRepository {
  final LocalTaskRepository _local;
  final RemoteTaskRepository? _remote;
  
  // 读取时：先从本地读取（快速响应），然后异步同步远程
  // 写入时：先写入本地，然后异步同步远程
}
```

---

## 📝 迁移步骤（最小改动）

### 阶段 1：抽象化（不改功能，只改架构）

1. 创建 `TaskRepository` 接口
2. 创建 `LocalTaskRepository` 实现（内部调用 StorageService）
3. 修改 `TaskProvider`，依赖 `TaskRepository` 而不是直接调用 StorageService
4. 同样处理 `WishProvider` 和 `WishRepository`
5. **创建 `AIChatRepository` 接口**（为后续后端接口做准备）
6. **开发阶段可以先用本地 mock 实现**（模拟 AI 回复），后端准备好后再切换

**效果：** 功能不变，但架构更灵活，为后端集成做好准备

### 阶段 2：添加远程接口（可选，等后端准备好）

1. 创建 `ApiService`（HTTP 请求封装）
2. 实现 `RemoteTaskRepository`
3. 在 `main.dart` 中切换 Repository 实现：
   ```dart
   // 使用本地存储
   TaskRepository taskRepo = LocalTaskRepository();
   
   // 或者使用远程接口
   TaskRepository taskRepo = RemoteTaskRepository();
   
   // 或者使用混合模式
   TaskRepository taskRepo = HybridTaskRepository();
   ```

---

## 🎯 建议的改进时机

**现在改（推荐）：**
- ✅ 代码量还小，改起来快
- ✅ 不影响现有功能（只是抽象一层）
- ✅ 为后续后端集成铺路

**不改的代价：**
- ❌ 后面要改 Provider 代码，改动量大
- ❌ 无法测试（依赖真实存储）
- ❌ 切换为后端接口会很麻烦

---

## 📌 总结

**肯定需要后端接口：**
1. 任务管理（多设备同步）
2. 愿望管理（多设备同步）
3. 用户信息
4. 植物状态（可能需要后端统计）
5. **AI 聊天** 🔒 **必须通过后端**（保护 API Key）

**安全考虑：**
- ❌ **前端不应该直接调用 DeepSeek API**（API Key 会暴露在客户端代码中）
- ✅ **前端调用后端接口**，后端再调用 DeepSeek API
- API Key 应该存储在后端服务器，永远不暴露给客户端

**架构改进建议：**
- 使用 Repository Pattern
- Provider 依赖接口，不依赖具体实现
- AI Service 也应该通过 Repository 模式调用后端接口
- 现在就可以抽象，不影响现有功能（开发阶段可以先用本地 mock 实现）
