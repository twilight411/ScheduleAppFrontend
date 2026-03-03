# 阶段 3: AI 聊天精灵系统 - Cursor 指令脚本

## 📌 前置条件

确保阶段 2 已完成：
- ✅ WishBottlePage 和愿望系统正常工作
- ✅ 可以选中愿望并显示"发送给AI"按钮
- ✅ AddTaskPage 支持预填充参数

## 📸 图片资源迁移说明

**阶段 3 会用到的图片资源：**
- AI 聊天背景图（iOS: `Assets.xcassets/Backgrounds/ai_chat_bg.imageset/`）
- 精灵图标（iOS: `Assets.xcassets/Spirits/spirit_*.imageset/`）
- 聊天相关图标（群聊/私聊、箭头等）

**建议：**
- 先用 Material Icons 和渐变色背景占位
- 精灵图标可以用圆形 Avatar + 颜色区分
- 到阶段 4-5 统一迁移所有图片资源

---

## 指令 3-1: 创建聊天消息模型

**复制这条给 Cursor：**

```
请创建聊天消息数据模型。

在 lib/models/chat_message.dart 中创建一个 ChatMessage 类：

要求：
1. ChatMessage 类包含以下字段：
   - role: ChatRole（枚举：user 或 assistant）
   - text: String
   - spiritType: SpiritType?（如果 role 是 assistant，可以指定是哪个精灵回复的，null 表示群聊回复）
   - timestamp: DateTime

2. 创建枚举 ChatRole：
   enum ChatRole {
     user,
     assistant,
   }

3. 实现构造函数、copyWith 方法

4. 可选：实现 toJson/fromJson（如果需要持久化聊天记录）

参考 iOS 代码中 ChatBubbleView 的 role 和 spiritType 逻辑。
```

---

## 指令 3-2: 创建 ChatProvider（状态管理）

**复制这条给 Cursor：**

```
请创建一个状态管理类 ChatProvider，用于管理聊天消息列表。

在 lib/providers/chat_provider.dart 中：

1. 继承 ChangeNotifier
2. 包含以下字段：
   - List<ChatMessage> messages: 聊天消息列表
   - bool isGroupChat: 是否群聊模式（true=群聊，false=私聊）
   - SpiritType? selectedSpirit: 当前私聊选中的精灵（群聊时为 null）

3. 实现以下方法：
   - addMessage(ChatMessage message): 添加消息到列表，然后 notifyListeners()
   - sendUserMessage(String text): 添加一条用户消息（role=user）
   - sendAssistantMessage(String text, SpiritType? spiritType): 添加一条助手消息（role=assistant，可指定精灵）
   - toggleChatMode(): 切换群聊/私聊模式
   - selectSpiritForPrivateChat(SpiritType spirit): 在私聊模式下选择一个精灵
   - clearMessages(): 清空所有消息
   - clearSelection(): 清空精灵选择（切回群聊模式）

4. 初始化时可以为空列表，或者添加一条欢迎消息

参考 iOS 代码中 EnhancedAIChatView 的消息管理逻辑。
```

---

## 指令 3-3: 创建聊天气泡 Widget

**复制这条给 Cursor：**

```
请创建一个可复用的聊天气泡组件。

在 lib/widgets/chat_bubble.dart 中创建一个 ChatBubble widget：

要求：
1. 接收 ChatMessage 对象作为参数
2. 根据 role 决定气泡位置：
   - user: 右对齐，蓝色背景，白色文字
   - assistant: 左对齐，根据 spiritType 显示不同颜色背景（如果没有 spiritType，用灰色）

3. 气泡样式：
   - 圆角矩形
   - 适当的内边距
   - 显示消息文本（支持多行）
   - 如果是 assistant 且有 spiritType，可以在气泡左侧显示一个小的精灵图标或颜色标记

4. 气泡大小自适应文本内容

参考 iOS 代码中 ChatBubbleView 的样式和布局。
```

---

## 指令 3-4: 创建 AIChatRepository 接口（后端接口抽象）

**复制这条给 Cursor：**

```
请创建 AI 聊天的 Repository 接口，用于抽象后端接口。

在 lib/repositories/ai_chat_repository.dart 中：

要求：
1. 定义抽象类 AIChatRepository
2. 包含方法：
   Future<String> sendMessage({
     required String message,
     SpiritType? spiritType,  // 指定精灵（私聊模式）
     bool isGroupChat = false,  // 群聊/私聊模式
   })

注意：
- 前端不应该直接调用 DeepSeek API（API Key 会暴露）
- 应该调用后端接口，后端再调用 DeepSeek API
- 开发阶段可以先用本地 mock 实现
```

---

## 指令 3-4-1: 创建本地 Mock 实现（开发阶段使用）

**复制这条给 Cursor：**

```
请创建本地 Mock 版本的 AIChatRepository 实现（开发阶段使用）。

在 lib/repositories/local_ai_chat_repository.dart 中：

要求：
1. 实现 AIChatRepository 接口
2. 开发阶段可以返回模拟的 AI 回复：
   - 根据 spiritType 返回对应的预设回复
   - 群聊模式返回综合回复
3. 这样可以先开发 UI，等后端准备好了再切换为 RemoteAIChatRepository

注意：
- 这只是开发阶段的临时实现
- 生产环境必须使用后端接口（通过 RemoteAIChatRepository）
```

---

## 指令 3-4-2: 预留远程接口实现（等后端准备好）

**重要提示：** 这个指令可以等后端接口准备好后再执行。

**复制这条给 Cursor（后端准备好后）：**

```
请创建远程版本的 AIChatRepository 实现（调用后端接口）。

在 lib/repositories/remote_ai_chat_repository.dart 中：

要求：
1. 实现 AIChatRepository 接口
2. 使用 ApiService 调用后端接口：
   - POST /api/ai/chat
   - Body: {
       "message": message,
       "spiritType": spiritType?.name,
       "isGroupChat": isGroupChat,
     }
   - 后端会调用 DeepSeek API，返回 AI 回复
3. 解析响应，返回 AI 回复文本

注意：
- API Key 存储在后端，前端永远不暴露
- 后端负责调用 DeepSeek API 并返回结果
```

---

## 指令 3-5: 修改 ChatProvider 使用 AIChatRepository

**复制这条给 Cursor：**

```
请修改 lib/providers/chat_provider.dart，改为依赖 AIChatRepository 接口：

要求：
1. 构造函数接收 AIChatRepository 参数：
   ```dart
   final AIChatRepository _repository;
   
   ChatProvider({AIChatRepository? repository})
     : _repository = repository ?? LocalAIChatRepository();
   ```

2. 添加 sendMessage 方法：
   - 先添加用户消息到列表
   - 调用 _repository.sendMessage() 获取 AI 回复
   - 添加助手消息到列表
   - 处理错误情况

3. ChatProvider 不再直接调用 AI Service，而是通过 Repository

注意：
- 开发阶段使用 LocalAIChatRepository（mock 实现）
- 后端准备好后切换为 RemoteAIChatRepository
```

---

## 指令 3-6: 创建 ChatPage（聊天主页面）

**复制这条给 Cursor：**

```
请创建 lib/pages/chat_page.dart，实现 AI 聊天界面。

要求：
1. 使用 StatefulWidget
2. 使用 Provider 获取 ChatProvider
3. 布局结构：
   - 顶部 AppBar：
     - 左侧：群聊/私聊切换按钮（图标：Icons.group / Icons.person）
     - 中间：标题（群聊显示"AI 精灵群聊"，私聊显示"与 [精灵名] 私聊"）
     - 右侧：关闭按钮
   - 中间聊天区域：
     - 如果是私聊模式，在顶部显示精灵选择器（水平滚动的精灵头像按钮）
     - ListView.builder 显示消息列表，使用 ChatBubble widget
     - 自动滚动到底部（当有新消息时）
   - 底部输入区域：
     - 左侧：愿望瓶按钮（可选，图标 Icons.auto_awesome）
     - 中间：输入框（TextField）
     - 右侧：发送按钮（IconButton，图标 Icons.send）

4. 交互功能：
   - 点击群聊/私聊切换：调用 ChatProvider.toggleChatMode()
   - 点击精灵头像（私聊模式）：调用 ChatProvider.selectSpiritForPrivateChat()
   - 点击发送：获取输入框文本，调用 sendMessage() 方法
   - 点击关闭：Navigator.pop()

5. 发送消息流程：
   - 先添加一条用户消息（ChatProvider.sendUserMessage()）
   - 添加一条"正在思考..."的占位助手消息
   - 异步调用 AIService.sendMessage()
   - 收到回复后，移除占位消息，添加真正的助手消息
   - 清空输入框
   - 滚动到底部

6. 支持从外部传入初始消息（可选参数 initialMessage, initialSpiritType, initialIsGroupChat），用于从愿望瓶跳转

参考 iOS 代码中 EnhancedAIChatView 的完整功能和布局。
```

---

## 指令 3-7: 实现发送消息和接收回复逻辑

**复制这条给 Cursor：**

```
请完善 ChatPage 中的发送消息功能。

要求：
1. 在 ChatPage 中实现 sendMessage() 方法：
   ```dart
   Future<void> sendMessage(String text) async {
     // 1. 清空输入框
     // 2. 添加用户消息
     // 3. 添加"正在思考..."占位消息
     // 4. 调用 AIService.sendMessage()，传入：
     //    - message: text
     //    - spiritType: ChatProvider.selectedSpirit（私聊模式）
     //    - isGroupChat: ChatProvider.isGroupChat
     // 5. 等待响应
     // 6. 移除占位消息
     // 7. 添加助手回复消息
     // 8. 滚动到底部
   }
   ```

2. 错误处理：
   - 如果 API 调用失败，移除占位消息，显示错误提示（SnackBar）
   - 如果输入为空，不发送

3. 加载状态：显示"正在思考..."时，发送按钮可以禁用或显示加载图标

参考 iOS 代码中 EnhancedAIChatView 的 sendMessage 和 handleAPIResponse 逻辑。
```

---

## 指令 3-8: 实现从愿望瓶发送到 AI

**复制这条给 Cursor：**

```
请完善 WishBottlePage 中的"发送给AI"功能。

要求：
1. 在"发送给AI"按钮的 onPressed 中：
   - 获取当前选中的愿望
   - 弹出对话框让用户选择模式：
     - "群聊模式（所有精灵参与）"
     - "私聊模式（[精灵名]）"
   - 根据用户选择，构建初始消息：
     ```dart
     String message = "我有一个愿望：${wish.title}\n\n详细说明：${wish.content}\n\n请帮我分析如何实现这个愿望。";
     ```
   - 跳转到 ChatPage，传入参数：
     - initialMessage: message
     - initialSpiritType: wish.spirit（如果是私聊模式）
     - initialIsGroupChat: 根据用户选择设置

2. ChatPage 收到 initialMessage 后：
   - 在 initState 中自动发送这条消息（调用 sendMessage）
   - 如果是私聊模式，自动选择对应的精灵

3. 跳转后，WishBottlePage 保持打开状态（不关闭），方便用户返回

参考 iOS 代码中 WishBottleViewController 的 sendToAITapped 和 sendWishToAI 逻辑。
```

---

## 指令 3-9: 在 main.dart 中注册 ChatProvider

**复制这条给 Cursor：**

```
请修改 lib/main.dart，添加 ChatProvider 到 MultiProvider。

要求：
1. 在 MultiProvider 的 providers 列表中添加：
   ChangeNotifierProvider<ChatProvider>(
     create: (_) => ChatProvider(),
   ),

2. 确保所有页面都能通过 Provider.of<ChatProvider>(context) 访问

3. 更新导入语句，引入 chat_provider.dart
```

---

## 指令 3-10: 添加精灵系统提示词（后端需要，前端不需要）

**注意：** 这个指令的提示词信息是给后端参考的，前端不需要实现。

**复制这条给 Cursor（可选，仅用于文档记录）：**

```
请创建一个精灵提示词配置文件（仅作为文档记录，供后端参考）。

在 lib/services/spirit_prompts.dart 中创建一个类，包含每个精灵的 system prompt：

要求：
1. 创建静态方法 getSystemPrompt(SpiritType? spiritType, bool isGroupChat) 
   返回对应的 system prompt 文本（仅用于文档记录）
2. 每个精灵的 prompt 参考 iOS 的 AIAPIManager.swift 中 SpiritPersonality.systemPrompt
3. 群聊模式的 prompt 参考 iOS 的群聊提示词
4. 这些信息需要提供给后端开发，让后端知道如何构造 system prompt

注意：
- 前端不需要真正使用这些 prompt（后端会处理）
- 这个文件只是为了方便后端开发参考
```

**复制这条给 Cursor：**

```
请创建一个精灵提示词配置文件。

在 lib/services/spirit_prompts.dart 中创建一个类，包含每个精灵的 system prompt：

要求：
1. 创建一个静态方法 getSystemPrompt(SpiritType? spiritType, bool isGroupChat) 返回对应的 system prompt
2. 每个精灵的 prompt 参考 iOS 的 AIAPIManager.swift 中 SpiritPersonality.systemPrompt
3. 群聊模式的 prompt 参考 iOS 的群聊提示词
4. 可以直接从 iOS 代码复制中文内容，保持一致性

5. 然后在 AIService 中调用这个方法获取对应的 prompt

这样可以保持 Flutter 版本和 iOS 版本的 AI 回复风格一致。
```

---

## 指令 3-11: 添加聊天记录持久化（可选）

**复制这条给 Cursor：**

```
（可选）请实现聊天记录的本地持久化。

要求：
1. 在 StorageService 中添加：
   - Future<void> saveChatMessages(List<ChatMessage> messages): 保存聊天记录
   - Future<List<ChatMessage>> loadChatMessages(): 加载聊天记录

2. 在 ChatProvider 中：
   - 初始化时加载历史记录
   - 每次添加消息后自动保存

3. 考虑是否需要限制历史记录数量（例如只保留最近 50 条）

注意：这个功能是可选的，如果不需要历史记录可以不实现。
```

---

## ✅ 阶段 3 完成检查清单

完成以上所有指令后，你应该能够：

- [ ] 从 WishBottlePage 点击"发送给AI"，能打开 ChatPage
- [ ] 可以选择群聊/私聊模式
- [ ] 在私聊模式下可以选择精灵
- [ ] 可以输入消息并发送
- [ ] 发送后显示"正在思考..."占位消息
- [ ] 收到 AI 回复后正确显示在聊天列表中
- [ ] 从愿望瓶发送时，能自动填充消息内容并发送
- [ ] AI 回复的内容符合对应精灵的性格（参考 iOS 版本）
- [ ] 聊天界面滚动正常，新消息自动滚动到底部
- [ ] 错误处理正常（网络错误、API 错误等）

如果以上都完成了，就可以进入 **阶段 4：植物页面** 了！

---

## 📝 注意事项

1. **🔒 安全考虑**：
   - ❌ **前端不应该直接调用 DeepSeek API**（API Key 会暴露在客户端代码中）
   - ✅ **前端调用后端接口**，后端再调用 DeepSeek API
   - API Key 应该存储在后端服务器，永远不暴露给客户端
   - 开发阶段可以使用 LocalAIChatRepository（mock 实现）
   - 生产环境必须使用 RemoteAIChatRepository（调用后端接口）

2. **错误处理**：确保所有网络请求都有错误处理，避免应用崩溃

3. **性能优化**：如果消息很多，考虑使用 ListView.builder 的分页加载

4. **UI 优化**：可以根据实际效果调整气泡样式、间距、颜色等

5. **后端接口规范**（供后端开发参考）：
   - 接口：POST /api/ai/chat
   - 请求体：{ "message": string, "spiritType": string?, "isGroupChat": boolean }
   - 响应体：{ "reply": string }
