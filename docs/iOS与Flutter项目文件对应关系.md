# iOS 与 Flutter 项目文件对应关系

## 📋 目录结构对比

### iOS 项目结构
```
ScheduleApp/
├── AppDelegate.swift              # 应用入口
├── SceneDelegate.swift            # 场景管理
├── Controllers/                    # 视图控制器（管理屏幕）
│   ├── MainContainerViewController.swift
│   ├── CalendarViewController.swift
│   ├── PlantViewController.swift
│   ├── ProfileViewController.swift
│   ├── AddTaskViewController.swift
│   ├── WishBottleViewController.swift
│   └── MonthlyFruitViewController.swift
├── Views/                          # 自定义视图组件（可复用UI）
│   ├── AI/
│   │   ├── AIAPIManager.swift
│   │   └── EnhancedAIChatView.swift
│   ├── Calendar/
│   │   ├── CalendarContainerView.swift
│   │   ├── DayCalendarView.swift
│   │   ├── WeekCalendarView.swift
│   │   ├── MonthCalendarView.swift
│   │   └── TaskDetailView.swift
│   └── Plant/
│       ├── PlantStatusView.swift
│       └── RadarChartView.swift
├── Models/                         # 数据模型
│   ├── SpiritType.swift
│   └── PlantStatus.swift
├── Services/                       # 业务逻辑服务
│   └── PlantService.swift
└── Utills/                         # 工具类
    ├── ResourceManager.swift
    ├── FontManager.swift
    └── Protocols.swift
```

### Flutter 项目结构
```
lib/
├── main.dart                       # 应用入口
├── pages/                          # 页面（对应iOS的Controllers）
│   ├── main_container_view.dart
│   ├── calendar_page.dart
│   ├── plant_page.dart
│   ├── profile_page.dart
│   ├── add_task_page.dart
│   ├── wish_bottle_page.dart
│   ├── add_wish_page.dart
│   └── chat_page.dart
├── widgets/                        # 可复用组件（对应iOS的Views）
│   ├── task_item.dart
│   ├── wish_item.dart
│   └── chat_bubble.dart
├── models/                         # 数据模型
│   ├── task.dart
│   ├── wish.dart
│   ├── spirit_type.dart
│   ├── repeat_option.dart
│   └── chat_message.dart
├── services/                       # 业务逻辑服务
│   ├── ai_service.dart
│   ├── api_service.dart
│   ├── storage_service.dart
│   └── spirit_prompts.dart
├── providers/                      # 状态管理（iOS没有直接对应）
│   ├── task_provider.dart
│   ├── wish_provider.dart
│   └── chat_provider.dart
└── repositories/                   # 数据仓库（iOS没有，Flutter架构模式）
    ├── task_repository.dart
    ├── wish_repository.dart
    ├── ai_chat_repository.dart
    ├── local_task_repository.dart
    ├── local_wish_repository.dart
    └── remote_ai_chat_repository.dart
```

---

## 🔄 文件一一对应关系

### 1. 应用入口层

| iOS | Flutter | 说明 |
|-----|---------|------|
| `AppDelegate.swift` | `main.dart` 中的 `main()` | 应用启动入口 |
| `SceneDelegate.swift` | `main.dart` 中的 `MyApp` | 场景/窗口管理 |
| - | `main.dart` 中的 `MultiProvider` | Flutter特有的Provider注册 |

**设计哲学差异：**
- **iOS**: 使用 `AppDelegate` 和 `SceneDelegate` 分离应用生命周期和场景管理
- **Flutter**: 使用 `main()` 函数作为入口，`MyApp` 作为根Widget，Provider在顶层注册

---

### 2. 视图控制器/页面层

| iOS | Flutter | 说明 |
|-----|---------|------|
| `Controllers/MainContainerViewController.swift` | `pages/main_container_view.dart` | 主容器，管理三个主界面切换 |
| `Controllers/CalendarViewController.swift` | `pages/calendar_page.dart` | 日历界面 |
| `Controllers/PlantViewController.swift` | `pages/plant_page.dart` | 植物界面 |
| `Controllers/ProfileViewController.swift` | `pages/profile_page.dart` | 个人中心 |
| `Controllers/AddTaskViewController.swift` | `pages/add_task_page.dart` | 添加任务页面 |
| `Controllers/WishBottleViewController.swift` | `pages/wish_bottle_page.dart` | 愿望瓶页面 |
| `Controllers/MonthlyFruitViewController.swift` | `pages/plant_page.dart` (部分) | 月果实（集成在植物页面） |

**设计哲学差异：**
- **iOS**: 使用 `UIViewController` 管理屏幕，通过 `present()` 或 `addChild()` 切换
- **Flutter**: 使用 `StatefulWidget` 作为页面，通过 `Navigator.push()` 切换，或直接切换Widget

---

### 3. 自定义视图/组件层

| iOS | Flutter | 说明 |
|-----|---------|------|
| `Views/Calendar/DayCalendarView.swift` | `widgets/` (未完全迁移) | 日视图组件 |
| `Views/Calendar/WeekCalendarView.swift` | `widgets/` (未完全迁移) | 周视图组件 |
| `Views/Calendar/MonthCalendarView.swift` | `widgets/` (未完全迁移) | 月视图组件 |
| `Views/Calendar/TaskDetailView.swift` | `widgets/task_item.dart` | 任务项组件 |
| `Views/AI/EnhancedAIChatView.swift` | `pages/chat_page.dart` + `widgets/chat_bubble.dart` | AI聊天界面 |
| `Views/Plant/PlantStatusView.swift` | `pages/plant_page.dart` (部分) | 植物状态视图 |
| `Views/Plant/RadarChartView.swift` | `pages/plant_page.dart` (部分) | 雷达图视图 |

**设计哲学差异：**
- **iOS**: 使用 `UIView` 子类创建可复用组件，通过 `addSubview()` 组合
- **Flutter**: 使用 `Widget` 创建可复用组件，通过嵌套组合，更灵活

---

### 4. 数据模型层

| iOS | Flutter | 说明 |
|-----|---------|------|
| `Models/SpiritType.swift` | `models/spirit_type.dart` | 精灵类型枚举 |
| `Models/PlantStatus.swift` | `models/` (未完全迁移) | 植物状态模型 |
| `Controllers/AddTaskViewController.swift` 中的 `Task` struct | `models/task.dart` | 任务模型 |
| `Controllers/WishBottleViewController.swift` 中的 `Wish` struct | `models/wish.dart` | 愿望模型 |
| - | `models/repeat_option.dart` | 重复选项（iOS在AddTaskViewController中） |
| - | `models/chat_message.dart` | 聊天消息（iOS在EnhancedAIChatView中） |

**设计哲学差异：**
- **iOS**: 模型可能定义在Controller中（如Task、Wish），或单独文件
- **Flutter**: 模型统一放在 `models/` 目录，更规范，便于复用

---

### 5. 业务逻辑服务层

| iOS | Flutter | 说明 |
|-----|---------|------|
| `Services/PlantService.swift` | `services/` (未完全迁移) | 植物状态计算服务 |
| `Views/AI/AIAPIManager.swift` | `services/ai_service.dart` + `services/api_service.dart` | AI API管理 |
| - | `services/storage_service.dart` | 本地存储服务（iOS在Controller中直接使用UserDefaults） |
| - | `services/spirit_prompts.dart` | 精灵提示词（iOS在AIAPIManager中） |

**设计哲学差异：**
- **iOS**: 服务类较少，很多逻辑直接在Controller中，或使用单例模式
- **Flutter**: 服务层更清晰，职责分离，便于测试和复用

---

### 6. 状态管理层（Flutter特有）

| iOS | Flutter | 说明 |
|-----|---------|------|
| `CalendarViewController` 中的 `allTasks` 数组 | `providers/task_provider.dart` | 任务状态管理 |
| `WishBottleViewController` 中的 `wishes` 数组 | `providers/wish_provider.dart` | 愿望状态管理 |
| `EnhancedAIChatView` 中的聊天状态 | `providers/chat_provider.dart` | 聊天状态管理 |

**设计哲学差异：**
- **iOS**: 状态管理在Controller中，使用属性变量和通知（NotificationCenter）
- **Flutter**: 使用Provider模式，状态与UI分离，通过 `notifyListeners()` 通知UI更新

---

### 7. 数据仓库层（Flutter特有）

| iOS | Flutter | 说明 |
|-----|---------|------|
| Controller中直接使用 `UserDefaults` | `repositories/local_task_repository.dart` | 本地任务存储 |
| Controller中直接使用 `UserDefaults` | `repositories/local_wish_repository.dart` | 本地愿望存储 |
| `AIAPIManager` 直接调用API | `repositories/remote_ai_chat_repository.dart` | 远程AI聊天 |
| - | `repositories/task_repository.dart` | 抽象接口（便于切换数据源） |
| - | `repositories/ai_chat_repository.dart` | 抽象接口 |

**设计哲学差异：**
- **iOS**: 数据访问直接在Controller或Service中，使用 `UserDefaults`、URLSession等
- **Flutter**: 使用Repository模式，抽象数据源，便于切换本地/远程，更符合Clean Architecture

---

### 8. 工具类层

| iOS | Flutter | 说明 |
|-----|---------|------|
| `Utills/ResourceManager.swift` | `services/` 或 `utils/` (未完全迁移) | 资源管理器 |
| `Utills/FontManager.swift` | `theme` 在 `main.dart` 中 | 字体管理 |
| `Utills/Protocols.swift` | `models/` 或接口定义 | 协议定义 |

**设计哲学差异：**
- **iOS**: 工具类使用静态方法或单例，集中管理资源
- **Flutter**: 资源通过 `pubspec.yaml` 声明，主题在 `ThemeData` 中统一管理

---

## 🎯 核心设计哲学差异总结

### 1. **架构模式**

**iOS (MVC模式):**
```
Controller (ViewController)
    ↓ 管理
View (UIView) + Model (数据)
```
- Controller 负责管理 View 和 Model
- 状态和逻辑集中在 Controller
- 使用通知（NotificationCenter）进行通信

**Flutter (声明式UI + 状态管理):**
```
Page (StatefulWidget)
    ↓ 使用
Provider (状态管理) + Repository (数据层) + Service (业务逻辑)
```
- UI 是声明式的，通过状态驱动
- 状态管理与 UI 分离
- 使用 Provider 进行状态共享

---

### 2. **状态管理**

**iOS:**
- 状态存储在 Controller 的属性中
- 使用 `NotificationCenter` 或 Delegate 模式通信
- 手动调用 `view.setNeedsDisplay()` 或刷新UI

**Flutter:**
- 状态存储在 Provider 中
- 使用 `ChangeNotifier` + `notifyListeners()` 自动更新UI
- UI 自动响应状态变化（声明式）

---

### 3. **数据持久化**

**iOS:**
- 直接在 Controller 中使用 `UserDefaults`、`CoreData` 等
- 数据访问逻辑分散在各处

**Flutter:**
- 使用 Repository 模式抽象数据源
- 通过接口定义，便于切换实现（本地/远程）
- 更符合依赖倒置原则

---

### 4. **UI组件组织**

**iOS:**
- `UIView` 子类创建组件
- 通过 `addSubview()` 和 Auto Layout 组合
- 需要手动管理视图层次

**Flutter:**
- `Widget` 创建组件
- 通过嵌套组合，更灵活
- Widget 树自动管理

---

### 5. **页面导航**

**iOS:**
- `present()` 模态弹出
- `addChild()` 容器管理
- `pushViewController()` 导航栈

**Flutter:**
- `Navigator.push()` 导航
- 直接切换 Widget（如 MainContainerView）
- 路由管理更统一

---

### 6. **代码组织**

**iOS:**
- 一个类一个文件（通常）
- 相关代码可能分散（如Task定义在AddTaskViewController中）

**Flutter:**
- 一个文件可以包含多个类
- 但按功能模块组织更清晰（models/, pages/, widgets/）

---

## 📊 迁移建议

1. **Controller → Page**: 将 ViewController 迁移为 StatefulWidget Page
2. **View → Widget**: 将 UIView 子类迁移为 Widget
3. **状态管理**: 将 Controller 中的状态提取到 Provider
4. **数据访问**: 将直接的数据访问封装到 Repository
5. **服务层**: 保持业务逻辑在 Service 层，但更清晰分离

---

## ✅ 总结

| 方面 | iOS | Flutter |
|------|-----|---------|
| **架构** | MVC | 声明式UI + Provider |
| **状态管理** | Controller属性 + 通知 | Provider + ChangeNotifier |
| **数据访问** | 直接使用UserDefaults等 | Repository模式 |
| **UI组件** | UIView子类 | Widget组合 |
| **导航** | present/addChild | Navigator/Widget切换 |
| **代码组织** | 一个类一个文件 | 按模块组织 |

Flutter 项目采用了更现代的架构模式（Repository、Provider），代码组织更清晰，职责分离更明确，便于测试和维护。
