import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/spirit_type.dart';

/// 月视图（简化版）
///
/// - 显示一个整月的日期网格
/// - 每天底部用小圆点表示任务数量（最多 3 个）
/// - 点击某天会通过 [onDateSelected] 回调日期（用于跳转到日视图）
class MonthCalendarView extends StatefulWidget {
  const MonthCalendarView({
    super.key,
    required this.anchorDate,
    required this.tasks,
    this.onDateSelected,
  });

  /// 任意落在当前月份内的日期
  final DateTime anchorDate;

  /// 当月内的任务（由外部提前过滤）
  final List<Task> tasks;

  final ValueChanged<DateTime>? onDateSelected;

  @override
  State<MonthCalendarView> createState() => _MonthCalendarViewState();
}

class _MonthCalendarViewState extends State<MonthCalendarView> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.anchorDate.year, widget.anchorDate.month);
  }

  @override
  void didUpdateWidget(covariant MonthCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.anchorDate.year != widget.anchorDate.year ||
        oldWidget.anchorDate.month != widget.anchorDate.month) {
      _currentMonth =
          DateTime(widget.anchorDate.year, widget.anchorDate.month);
    }
  }

  int get _daysInMonth {
    final nextMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1)).day;
  }

  int get _firstWeekdayIndex {
    // 我们希望周一=0 ... 周日=6
    final weekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
    return weekday == 7 ? 6 : weekday - 1;
  }

  Map<int, List<Task>> get _tasksByDay {
    final map = <int, List<Task>>{};
    for (final task in widget.tasks) {
      if (task.startDate.year == _currentMonth.year &&
          task.startDate.month == _currentMonth.month) {
        final day = task.startDate.day;
        map.putIfAbsent(day, () => []).add(task);
      }
    }
    return map;
  }

  String get _monthTitle =>
      '${_currentMonth.year}年${_currentMonth.month}月';

  @override
  Widget build(BuildContext context) {
    final tasksByDay = _tasksByDay;
    final daysInMonth = _daysInMonth;
    final firstIndex = _firstWeekdayIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 顶部：上一月 / 标题 / 下一月
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _currentMonth = DateTime(
                      _currentMonth.year, _currentMonth.month - 1, 1);
                });
              },
            ),
            Text(
              _monthTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _currentMonth = DateTime(
                      _currentMonth.year, _currentMonth.month + 1, 1);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
        // 星期标题
        Row(
          children: const [
            _WeekdayHeader('一'),
            _WeekdayHeader('二'),
            _WeekdayHeader('三'),
            _WeekdayHeader('四'),
            _WeekdayHeader('五'),
            _WeekdayHeader('六'),
            _WeekdayHeader('日'),
          ],
        ),
        const SizedBox(height: 4),
        // 日期网格
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 42, // 6 行 * 7 列
            itemBuilder: (context, index) {
              final dayNumber = index - firstIndex + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final date =
                  DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
              final isToday = DateUtils.isSameDay(date, DateTime.now());
              final dayTasks = tasksByDay[dayNumber] ?? const <Task>[];

              Color bg = Colors.white.withOpacity(0.4);
              Color border = Colors.white.withOpacity(0.3);
              Color textColor = Colors.black87;

              if (isToday) {
                bg = Colors.green.withOpacity(0.25);
                border = Colors.green;
                textColor = Colors.green.shade800;
              }

              return GestureDetector(
                onTap: () => widget.onDateSelected?.call(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: border, width: isToday ? 1.5 : 1),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 2,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isToday ? FontWeight.w700 : FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // 小圆点表示任务数量（最多 3 个）
                      if (dayTasks.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: dayTasks
                              .take(3)
                              .map((task) => Container(
                                    width: 4,
                                    height: 4,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: task.category.color,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ))
                              .toList(),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

