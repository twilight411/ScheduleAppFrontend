import 'package:flutter/material.dart';

import '../models/wish.dart';
import '../models/spirit_type.dart';
import '../utils/resource_manager.dart';
import 'animated_image.dart';

/// 可复用的愿望列表项组件
class WishItem extends StatelessWidget {
  final Wish wish;
  final bool isSelected;
  final VoidCallback onCheckboxTapped;

  const WishItem({
    super.key,
    required this.wish,
    required this.isSelected,
    required this.onCheckboxTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 选中和未选中时的样式
    final cardColor = isSelected
        ? theme.colorScheme.primary.withOpacity(0.08)
        : theme.cardColor;
    final borderColor =
        isSelected ? theme.colorScheme.primary : Colors.grey.shade300;
    final borderWidth = isSelected ? 2.0 : 1.0;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      elevation: isSelected ? 4 : 1,
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧：复选框区域
            InkWell(
              onTap: onCheckboxTapped,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => onCheckboxTapped(),
                  shape: const CircleBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 中间：标题、内容、创建日期
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题行
                  Text(
                    wish.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // 内容
                  Text(
                    wish.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color
                          ?.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // 创建日期（小精灵标签文字去掉，只保留右侧的精灵图标卡片）
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _formatDate(wish.createdDate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // 右侧：精灵卡片图
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: wish.spirit.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FadeInAssetImage(
                    assetPath: ResourceManager.getSpiritIcon(wish.spirit),
                    width: 24,
                    height: 24,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        wish.spirit.icon,
                        color: wish.spirit.color,
                        size: 24,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // 简单格式：YYYY-MM-DD
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

