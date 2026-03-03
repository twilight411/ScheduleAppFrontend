# 字体迁移说明

## 概述

iOS项目使用了自定义字体 "work.ttf"，Flutter项目已经完成了字体迁移配置。

## 字体文件

- **字体文件位置**: `fonts/work.ttf`
- **字体家族名称**: `Work`
- **对应iOS**: `FontManager.customFont(size:weight:)`

## 配置

### pubspec.yaml

已在 `pubspec.yaml` 中配置字体：

```yaml
fonts:
  - family: Work
    fonts:
      - asset: fonts/work.ttf
```

### FontManager

已创建 `lib/utils/font_manager.dart`，提供与iOS项目一致的API：

```dart
// 基本使用
FontManager.customFont(size: 18, weight: FontWeight.bold)

// 带颜色
FontManager.customFontWithColor(
  size: 16,
  color: Colors.black,
  weight: FontWeight.medium,
)
```

## 使用方法

### 在Text Widget中使用

```dart
Text(
  'Hello World',
  style: FontManager.customFont(size: 18, weight: FontWeight.bold),
)
```

### 在TextStyle中使用

```dart
TextStyle(
  ...FontManager.customFont(size: 16, weight: FontWeight.medium),
  color: Colors.black87,
)
```

### 对应iOS代码

| iOS | Flutter |
|-----|---------|
| `FontManager.customFont(size: 18, weight: .bold)` | `FontManager.customFont(size: 18, weight: FontWeight.bold)` |
| `FontManager.customFont(size: 14, weight: .medium)` | `FontManager.customFont(size: 14, weight: FontWeight.medium)` |
| `FontManager.customFont(size: 12)` | `FontManager.customFont(size: 12)` |

## 注意事项

1. **字体名称**: Flutter中使用 `Work` 作为字体家族名称（首字母大写），iOS中使用 `work`（小写）
2. **字体粗细**: 如果字体文件不支持指定的weight，Flutter会自动回退到系统字体
3. **字体加载**: 字体文件需要在 `pubspec.yaml` 中正确配置，并在应用启动时自动加载

## 迁移状态

✅ 字体文件已复制到 `fonts/work.ttf`  
✅ `pubspec.yaml` 已配置字体  
✅ `FontManager` 工具类已创建  
⚠️ 需要逐步将现有代码中的字体替换为使用 `FontManager`
