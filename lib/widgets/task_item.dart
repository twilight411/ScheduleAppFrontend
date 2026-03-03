import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../models/spirit_type.dart';
import '../utils/resource_manager.dart';
import 'animated_image.dart';

/// 单个任务列表项组件
///
/// 样式参考 iOS 的 Task 列表展示方式：
/// - 左侧显示标题和时间区间
/// - 右侧是精灵类型的小标签
/// - 整体使用 Card 包裹，带圆角与阴影
class TaskItem extends StatefulWidget {
  const TaskItem({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  bool _isPressed = false;

  String get _formattedStart {
    // 示例格式：2024年1月15日 14:00
    final formatter = DateFormat('yyyy年M月d日 HH:mm');
    return formatter.format(widget.task.startDate);
  }

  String get _formattedEnd {
    final formatter = DateFormat('yyyy年M月d日 HH:mm');
    return formatter.format(widget.task.endDate);
  }

  @override
  Widget build(BuildContext context) {
    final spirit = widget.task.category;

    return Card(
      elevation: _isPressed ? 8 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTapDown: (_) {
          setState(() {
            _isPressed = true;
          });
        },
        onTapCancel: () {
          setState(() {
            _isPressed = false;
          });
        },
        onTapUp: (_) {
          setState(() {
            _isPressed = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: _isPressed
                ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                : Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 左侧：标题 + 时间
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_formattedStart - $_formattedEnd',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // 右侧：精灵类型标签
              Chip(
                avatar: FadeInAssetImage(
                  assetPath: ResourceManager.getSpiritIcon(spirit),
                  width: 18,
                  height: 18,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      spirit.icon,
                      size: 18,
                      color: Colors.white,
                    );
                  },
                ),
                label: Text(
                  spirit.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: spirit.color,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

