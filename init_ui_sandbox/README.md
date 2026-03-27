# init_ui_sandbox

**独立 Flutter 工程**：与主 App **解耦运行**，但 **V1 初始化/引导 UI 与主工程同源**——从 `schedule_app_flutter` **直接拷贝**下列内容后在此调试，满意再迁回主工程。

## 按手机宽度适配（沙盒内已加）

- `lib/utils/onboarding_width_adapt.dart`：入口 **`fromMediaQuery`**。
  - **手机**：按 **逻辑宽度 dp** 分档（~360、375–393、**411 Medium Phone / Pixel 9a**、428+）。
  - **平板**：`shortestSide >= 600` 时单独一套：内容区 **居中 + `contentMaxWidth: 540`**，A/B/C 边距按窄栏重算（与全屏背景图脱耦）。**微调选项与背景的左右/上下关系**：只改该文件里 `isTablet: true` 分支，源码中有中文注释逐项说明（`optionsHorizontalPadding`、`block*`、`optionsExtra*` 等）。
- `onboarding_question_page.dart` 用 `LayoutBuilder` + `SizedBox` 包一层，保证内层 `Expanded` 仍有高度约束。
- 迁主工程时请 **一并复制** `onboarding_width_adapt.dart` 并接好 `fromMediaQuery` 与居中限宽结构。

## 已从主工程拷贝的内容（需保持同步时可再覆盖复制）

| 类型 | 路径 |
|------|------|
| 页面 | `lib/pages/onboarding/onboarding_question_page.dart`、`onboarding_v1_data.dart` |
| 模型 | `lib/models/onboarding_question.dart`、`spirit_type.dart` |
| 工具 | `lib/utils/font_manager.dart`、`resource_manager.dart` |
| 资源 | `assets/`、`fonts/work.ttf`（与主工程 `pubspec.yaml` 中 `assets` / `fonts` 声明一致） |

## 沙盒独有（迁主工程时可删或改写）

| 文件 | 说明 |
|------|------|
| `lib/pages/onboarding/onboarding_v1_sandbox_flow_page.dart` | 与 `OnboardingV1FlowPage` 相同交互，**最后一题完成后**进占位结束页，**不**跳转 V2、**不**写 `SharedPreferences` |
| `lib/screens/done_placeholder_screen.dart` | 流程结束占位 +「再跑一遍」 |
| `lib/app_shell.dart` / `lib/main.dart` | 入口 |
| `lib/theme/app_theme.dart` | 仅 `MaterialApp` 主题（可与主工程对齐） |

> 主工程里 **没有** 单独的「dot」组件文件；步骤指示若在 V2 或其它页，请从对应路径再拷贝。

## 运行

```powershell
cd init_ui_sandbox
flutter pub get
flutter run
```

### 热重载报错：`type '_InitSandboxAppState' is not a subtype of ...`

根组件若在 **Stateful ↔ Stateless** 之间改过，**Hot Reload 不够**。请：

- 在 IDE 里点 **Hot Restart**（带闪电的循环箭头），或  
- 停掉进程再 `flutter run`。

仅 **Hot Reload** 会保留旧的 `State` 对象，与新版 Widget 类型冲突。

## 再同步主工程文件的命令示例（PowerShell，在仓库根目录）

```powershell
Copy-Item schedule_app_flutter\lib\pages\onboarding\onboarding_question_page.dart init_ui_sandbox\lib\pages\onboarding\ -Force
Copy-Item schedule_app_flutter\lib\pages\onboarding\onboarding_v1_data.dart init_ui_sandbox\lib\pages\onboarding\ -Force
# …其余同上表
Robocopy schedule_app_flutter\assets init_ui_sandbox\assets /E
Robocopy schedule_app_flutter\fonts init_ui_sandbox\fonts /E
```
