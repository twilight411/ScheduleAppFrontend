import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/spirit_type.dart';

/// 日视图：24 小时时间格 + 任务块
///
/// 对标 iOS 的 DayCalendarView.swift，实现思路：
/// - 顶部：上一天 / 日期标题 / 下一天
/// - 中间：0:00 ~ 23:00 每小时一行时间槽
/// - 每个时间槽右侧用彩色块展示这一小时内的任务
class DayCalendarView extends StatefulWidget {
  const DayCalendarView({
    super.key,
    required this.anchorDate,
    required this.tasks,
    this.onDateChanged,
  });

  /// 初始日期
  final DateTime anchorDate;

  /// 全部任务（已根据精灵类型等外部条件过滤）
  final List<Task> tasks;

  /// 当用户点击上一天 / 下一天时，通知外部当前日期变化
  final ValueChanged<DateTime>? onDateChanged;

  @override
  State<DayCalendarView> createState() => _DayCalendarViewState();
}

class _DayCalendarViewState extends State<DayCalendarView> {
  late DateTime _currentDate;
  final ScrollController _scrollController = ScrollController();
  final Map<int, bool> _completedMap = {};

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime(
      widget.anchorDate.year,
      widget.anchorDate.month,
      widget.anchorDate.day,
    );
    // 初次进入时，尝试滚动到当前时间附近
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTime();
    });
  }

  @override
  void didUpdateWidget(covariant DayCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果外部 anchorDate 发生变化，同步当前日期
    if (oldWidget.anchorDate != widget.anchorDate) {
      _currentDate = DateTime(
        widget.anchorDate.year,
        widget.anchorDate.month,
        widget.anchorDate.day,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentTime();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _changeDay(int delta) {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: delta));
    });
    widget.onDateChanged?.call(_currentDate);
    _scrollToCurrentTime();
  }

  String get _dateLabel {
    const weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
    final month = _currentDate.month.toString().padLeft(2, '0');
    final day = _currentDate.day.toString().padLeft(2, '0');
    final weekdayText = weekdays[_currentDate.weekday - 1];
    return '$month月$day日 $weekdayText';
  }

  List<Task> _tasksForHour(int hour) {
    return widget.tasks.where((task) {
      final d = task.startDate;
      return d.year == _currentDate.year &&
          d.month == _currentDate.month &&
          d.day == _currentDate.day &&
          d.hour == hour;
    }).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  void _scrollToCurrentTime() {
    if (!_scrollController.hasClients) return;

    // 1. 优先滚动到当前日期中「最早的任务」所在的时间段
    final tasksOfDay = widget.tasks.where((task) {
      final d = task.startDate;
      return d.year == _currentDate.year &&
          d.month == _currentDate.month &&
          d.day == _currentDate.day;
    }).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    int? targetHour;

    if (tasksOfDay.isNotEmpty) {
      targetHour = tasksOfDay.first.startDate.hour;
    } else {
      // 2. 如果这一天没有任务，再按「今天」的当前时间来滚动（与原逻辑一致）
      final now = DateTime.now();
      if (now.year == _currentDate.year &&
          now.month == _currentDate.month &&
          now.day == _currentDate.day) {
        targetHour = now.hour;
      }
    }

    if (targetHour == null) return;

    targetHour = targetHour.clamp(0, 23);
    // 每个时间槽高度约 70，稍微往上留一点空间
    final offset = targetHour * 70.0 - 100;
    _scrollController.animateTo(
      offset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 顶部：上一天 / 日期标题 / 下一天 + 天气
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => _changeDay(-1),
                icon: const Icon(Icons.chevron_left),
                color: Colors.black87,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _dateLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '☀️ 晴 18°C',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => _changeDay(1),
                icon: const Icon(Icons.chevron_right),
                color: Colors.black87,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
        const Divider(height: 12),
        // 时间格 + 任务块
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: 24,
            itemBuilder: (context, hour) {
              final hourTasks = _tasksForHour(hour);
              final isNow =
                  DateTime.now().year == _currentDate.year &&
                      DateTime.now().month == _currentDate.month &&
                      DateTime.now().day == _currentDate.day &&
                      DateTime.now().hour == hour;

              // 顶部 00:00 行不需要再额外往下留白，否则会感觉「00:00 上面空了一块」。
              final double topMargin = hour == 0 ? 0 : 4;

              return Container(
                margin: EdgeInsets.only(top: topMargin, bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 左侧时间标签
                    SizedBox(
                      width: 52,
                      child: Text(
                        '${hour.toString().padLeft(2, '0')}:00',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isNow ? FontWeight.bold : FontWeight.w400,
                          color: isNow ? Colors.green[700] : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 竖直分隔线
                    Container(
                      width: 1,
                      height: 60,
                      color: (isNow
                              ? Colors.green
                              : Colors.grey.withOpacity(0.3))
                          .withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    // 右侧：该时间段的任务块（纵向排布）
                    Expanded(
                      child: hourTasks.isEmpty
                          ? Container(
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                      Colors.white.withOpacity(isNow ? 0.7 : 0.3),
                                  width: isNow ? 1.5 : 1,
                                ),
                              ),
                            )
                          : Column(
                              children: hourTasks
                                  .map((task) => _TaskBlock(
                                        task: task,
                                        isCompleted:
                                            _completedMap[task.hashCode] ==
                                                true,
                                        onToggleCompleted: () {
                                          setState(() {
                                            final key = task.hashCode;
                                            final current =
                                                _completedMap[key] ?? false;
                                            _completedMap[key] = !current;
                                          });
                                        },
                                      ))
                                  .toList(),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 单个任务块，显示在日视图的时间槽里
class _TaskBlock extends StatelessWidget {
  const _TaskBlock({
    required this.task,
    required this.isCompleted,
    required this.onToggleCompleted,
  });

  final Task task;
  final bool isCompleted;
  final VoidCallback onToggleCompleted;

  @override
  Widget build(BuildContext context) {
    final Color color = task.category.color;
    final start =
        '${task.startDate.hour.toString().padLeft(2, '0')}:${task.startDate.minute.toString().padLeft(2, '0')}';
    final end =
        '${task.endDate.hour.toString().padLeft(2, '0')}:${task.endDate.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isCompleted
            ? color.withOpacity(0.4)
            : color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧：任务文本信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        isCompleted ? FontWeight.w500 : FontWeight.w600,
                    fontSize: 13,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$start - $end',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                if (task.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    task.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          // 右侧：完成勾选框
          GestureDetector(
            onTap: onToggleCompleted,
            child: Icon(
              isCompleted
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

