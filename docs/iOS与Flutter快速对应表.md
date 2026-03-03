# iOS 与 Flutter 快速对应表

## 📁 目录对应

| iOS目录 | Flutter目录 | 说明 |
|---------|------------|------|
| `Controllers/` | `pages/` | 视图控制器 → 页面 |
| `Views/` | `widgets/` | 自定义视图 → 可复用组件 |
| `Models/` | `models/` | 数据模型 |
| `Services/` | `services/` | 业务逻辑服务 |
| `Utills/` | `services/` 或 `utils/` | 工具类 |
| - | `providers/` | **Flutter特有**：状态管理 |
| - | `repositories/` | **Flutter特有**：数据仓库 |

---

## 📄 文件对应

### 应用入口
| iOS | Flutter |
|-----|---------|
| `AppDelegate.swift` | `main.dart` 的 `main()` |
| `SceneDelegate.swift` | `main.dart` 的 `MyApp` |

### 主容器
| iOS | Flutter |
|-----|---------|
| `MainContainerViewController.swift` | `main_container_view.dart` |

### 主要页面
| iOS | Flutter |
|-----|---------|
| `CalendarViewController.swift` | `calendar_page.dart` |
| `PlantViewController.swift` | `plant_page.dart` |
| `ProfileViewController.swift` | `profile_page.dart` |
| `AddTaskViewController.swift` | `add_task_page.dart` |
| `WishBottleViewController.swift` | `wish_bottle_page.dart` |

### UI组件
| iOS | Flutter |
|-----|---------|
| `DayCalendarView.swift` | `calendar_page.dart` (部分) |
| `WeekCalendarView.swift` | `calendar_page.dart` (部分) |
| `MonthCalendarView.swift` | `calendar_page.dart` (部分) |
| `TaskDetailView.swift` | `task_item.dart` |
| `EnhancedAIChatView.swift` | `chat_page.dart` + `chat_bubble.dart` |

### 数据模型
| iOS | Flutter |
|-----|---------|
| `SpiritType.swift` | `spirit_type.dart` |
| `PlantStatus.swift` | (未完全迁移) |
| `Task` (在AddTaskViewController中) | `task.dart` |
| `Wish` (在WishBottleViewController中) | `wish.dart` |

### 服务层
| iOS | Flutter |
|-----|---------|
| `PlantService.swift` | (未完全迁移) |
| `AIAPIManager.swift` | `ai_service.dart` + `api_service.dart` |

### 状态管理（Flutter特有）
| iOS方式 | Flutter |
|---------|---------|
| Controller中的 `allTasks` 数组 | `task_provider.dart` |
| Controller中的 `wishes` 数组 | `wish_provider.dart` |
| NotificationCenter通知 | `chat_provider.dart` |

### 数据仓库（Flutter特有）
| iOS方式 | Flutter |
|---------|---------|
| 直接使用 `UserDefaults` | `local_task_repository.dart` |
| 直接使用 `UserDefaults` | `local_wish_repository.dart` |
| 直接调用API | `remote_ai_chat_repository.dart` |

---

## 🎯 核心差异

### 1. 状态管理
- **iOS**: 状态在Controller中，用NotificationCenter通信
- **Flutter**: 状态在Provider中，用ChangeNotifier自动更新

### 2. 数据访问
- **iOS**: 直接使用UserDefaults、URLSession
- **Flutter**: 通过Repository抽象，便于切换数据源

### 3. UI组织
- **iOS**: UIView子类，addSubview组合
- **Flutter**: Widget嵌套，声明式组合

### 4. 架构模式
- **iOS**: MVC（Model-View-Controller）
- **Flutter**: 声明式UI + Provider + Repository

---

## 💡 迁移要点

1. **ViewController → Page**: 迁移为StatefulWidget
2. **UIView → Widget**: 迁移为可复用Widget
3. **状态提取**: Controller中的状态 → Provider
4. **数据封装**: 直接数据访问 → Repository
5. **服务保持**: 业务逻辑保持在Service层
