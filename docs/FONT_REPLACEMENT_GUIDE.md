# 字体替换指南

## 系统字体常见写法模式

以下是代码中使用系统字体的常见模式，可以用编辑器批量替换：

### 模式1：基本 TextStyle（最常见）

```dart
// 查找：
style: TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
  color: Colors.white,
)

// 替换为：
style: FontManager.customFontWithColor(
  size: 20,
  weight: FontWeight.bold,
  color: Colors.white,
)
```

### 模式2：只有 fontSize

```dart
// 查找：
style: TextStyle(
  fontSize: 14,
)

// 替换为：
style: FontManager.customFont(size: 14)
```

### 模式3：fontSize + fontWeight

```dart
// 查找：
style: TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
)

// 替换为：
style: FontManager.customFont(
  size: 18,
  weight: FontWeight.bold,
)
```

### 模式4：fontSize + color

```dart
// 查找：
style: TextStyle(
  fontSize: 16,
  color: Colors.grey,
)

// 替换为：
style: FontManager.customFontWithColor(
  size: 16,
  color: Colors.grey,
)
```

### 模式5：const TextStyle（需要去掉 const）

```dart
// 查找：
style: const TextStyle(
  fontSize: 12,
  color: Colors.grey,
)

// 替换为：
style: FontManager.customFontWithColor(
  size: 12,
  color: Colors.grey,
)
```

### 模式6：复杂样式（需要手动处理）

```dart
// 查找：
style: TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
  color: Colors.white,
  shadows: [
    Shadow(...),
  ],
)

// 替换为（需要保留其他属性）：
style: FontManager.customFontWithColor(
  size: 20,
  weight: FontWeight.bold,
  color: Colors.white,
).copyWith(
  shadows: [
    Shadow(...),
  ],
)
```

## 批量替换步骤

### 步骤1：导入 FontManager

在每个文件顶部添加：
```dart
import '../utils/font_manager.dart';
// 或
import 'package:schedule_app_flutter/utils/font_manager.dart';
```

### 步骤2：使用正则表达式替换

#### 替换模式1：只有 fontSize
**查找（正则）：**
```regex
style:\s*TextStyle\(\s*fontSize:\s*(\d+(?:\.\d+)?),
```

**替换为：**
```
style: FontManager.customFont(size: $1,
```

#### 替换模式2：fontSize + fontWeight
**查找（正则）：**
```regex
style:\s*TextStyle\(\s*fontSize:\s*(\d+(?:\.\d+)?),\s*fontWeight:\s*(FontWeight\.\w+),
```

**替换为：**
```
style: FontManager.customFont(size: $1, weight: $2,
```

#### 替换模式3：fontSize + color
**查找（正则）：**
```regex
style:\s*TextStyle\(\s*fontSize:\s*(\d+(?:\.\d+)?),\s*color:\s*([^,)]+),
```

**替换为：**
```
style: FontManager.customFontWithColor(size: $1, color: $2,
```

### 步骤3：手动处理特殊情况

以下情况需要手动处理：
1. 有 `shadows`、`decoration` 等额外属性的
2. 使用 `const TextStyle` 的（需要去掉 const）
3. 多行 TextStyle 的

## 常见替换对照表

| 原代码 | 替换后 |
|--------|--------|
| `TextStyle(fontSize: 20)` | `FontManager.customFont(size: 20)` |
| `TextStyle(fontSize: 18, fontWeight: FontWeight.bold)` | `FontManager.customFont(size: 18, weight: FontWeight.bold)` |
| `TextStyle(fontSize: 16, color: Colors.grey)` | `FontManager.customFontWithColor(size: 16, color: Colors.grey)` |
| `TextStyle(fontSize: 14, fontWeight: FontWeight.w500)` | `FontManager.customFont(size: 14, weight: FontWeight.w500)` |
| `const TextStyle(fontSize: 12)` | `FontManager.customFont(size: 12)` |

## 注意事项

1. **保留其他属性**：如果 TextStyle 有其他属性（如 shadows、decoration），需要使用 `.copyWith()` 方法
2. **去掉 const**：`const TextStyle` 需要改为非 const 的 FontManager 调用
3. **导入语句**：确保每个文件都导入了 FontManager
4. **测试**：替换后需要测试确保样式正确显示

## 示例：完整替换

### 替换前：
```dart
Text(
  '我的安排',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ),
)
```

### 替换后：
```dart
Text(
  '我的安排',
  style: FontManager.customFontWithColor(
    size: 18,
    weight: FontWeight.bold,
    color: Colors.black,
  ),
)
```

### 带 shadows 的情况：
```dart
// 替换前
Text(
  '狮子',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(
        color: Colors.black.withOpacity(0.3),
        offset: const Offset(0, 1),
        blurRadius: 2,
      ),
    ],
  ),
)

// 替换后
Text(
  '狮子',
  style: FontManager.customFontWithColor(
    size: 20,
    weight: FontWeight.bold,
    color: Colors.white,
  ).copyWith(
    shadows: [
      Shadow(
        color: Colors.black.withOpacity(0.3),
        offset: const Offset(0, 1),
        blurRadius: 2,
      ),
    ],
  ),
)
```
