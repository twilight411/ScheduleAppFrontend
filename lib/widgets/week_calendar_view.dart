import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/spirit_type.dart';

/// 周视图：一周 7 天 + 纵向时间栅格 + 任务块（课表样式）
///
/// 对标 iOS 的 WeekCalendarView.swift：
/// - 顶部：上一周 / 当前周范围 / 下一周
/// - 第二行：一周 7 天的日期头
/// - 下方：左侧时间轴（例如 8:00 ~ 20:00），右侧 7 列，每列代表一天，内部按时间纵向排版任务块
class WeekCalendarView extends StatefulWidget {
  const WeekCalendarView({
    super.key,
    required this.anchorDate,
    required this.tasks,
    this.onDateSelected,
    this.onTaskTap,
  });

  /// 任意落在当前周内的日期（用来计算这一周的范围）
  final DateTime anchorDate;

  /// 全部任务（已在外部根据精灵筛选等条件过滤）
  final List<Task> tasks;

  /// 点击某一天（在日期头上）时的回调，用于跳转到日视图
  final ValueChanged<DateTime>? onDateSelected;

  /// 点击某个任务块时的回调，用于打开编辑页
  final ValueChanged<Task>? onTaskTap;

  @override
  State<WeekCalendarView> createState() => _WeekCalendarViewState();
}

class _WeekCalendarViewState extends State<WeekCalendarView> {
  // 时间轴范围：0:00 - 24:00，每 2 小时一个刻度（覆盖全天 24 小时）
  static const int _startHour = 0;
  static const int _endHour = 24;
  static const int _slotMinutes = 120; // 2 小时一格
  static const double _slotHeight = 70.0; // 每个时间格高度，略高一些，避免看起来过挤
  static const double _timeAxisWidth = 44.0; // 时间轴宽度，略缩窄，为 7 列留更多空间
  static const double _minDayColumnWidth = 48.0; // 课表式：每列最小宽度，避免过窄导致内容挤爆

  late DateTime _weekMonday;

  @override
  void initState() {
    super.initState();
    _weekMonday = _findMonday(widget.anchorDate);
  }

  @override
  void didUpdateWidget(covariant WeekCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isSameDate(oldWidget.anchorDate, widget.anchorDate)) {
      _weekMonday = _findMonday(widget.anchorDate);
    }
  }

  bool isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _findMonday(DateTime date) {
    final weekday = date.weekday; // 1=Mon...7=Sun
    return date.subtract(Duration(days: weekday - 1));
  }

  List<DateTime> get _weekDates =>
      List.generate(7, (i) => _weekMonday.add(Duration(days: i)));

  String get _weekTitle {
    final start = _weekDates.first;
    final end = _weekDates.last;
    String fmt(DateTime d) => '${d.month}月${d.day}日';
    return '${fmt(start)} - ${fmt(end)}';
  }

  List<String> get _timeLabels {
    final List<String> labels = [];
    // 为了避免最后一个时间标签（24:00）超出栅格总高度，只展示到 22:00，
    // 即 [0:00, 2:00, ..., 22:00] 共 12 个刻度，对应 12 个时间格。
    for (int h = _startHour; h < _endHour; h += 2) {
      labels.add('${h.toString().padLeft(2, '0')}:00');
    }
    return labels;
  }

  /// 一周内、按天分组的任务
  Map<int, List<Task>> get _tasksByDayIndex {
    final Map<int, List<Task>> map = {};
    for (final task in widget.tasks) {
      for (int i = 0; i < 7; i++) {
        final date = _weekDates[i];
        if (isSameDate(task.startDate, date)) {
          map.putIfAbsent(i, () => []).add(task);
          break;
        }
      }
    }
    for (final entry in map.entries) {
      entry.value.sort((a, b) => a.startDate.compareTo(b.startDate));
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final tasksByDay = _tasksByDayIndex;
    final totalSlots =
        ((_endHour - _startHour) * 60 / _slotMinutes).round(); // 6 格
    final totalHeight = totalSlots * _slotHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 顶部：上一周 / 标题 / 下一周
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _weekMonday = _weekMonday.subtract(const Duration(days: 7));
                });
              },
            ),
            Text(
              _weekTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _weekMonday = _weekMonday.add(const Duration(days: 7));
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 星期标题栏（左侧预留与时间轴同宽的空白，保证与下方 7 列竖向栅格完全对齐）
        SizedBox(
          height: 40,
          child: Row(
            children: [
              const SizedBox(width: _timeAxisWidth + 4), // 时间轴宽度 + 右侧间距
              Expanded(
                child: Row(
                  children: _weekDates.asMap().entries.map((entry) {
                    final index = entry.key;
                    final date = entry.value;
                    final isToday = isSameDate(date, DateTime.now());
                    final weekdayNames = ['一', '二', '三', '四', '五', '六', '日'];
                    final weekdayText = weekdayNames[date.weekday - 1];

                    final hasTasksForDay =
                        (tasksByDay[index]?.isNotEmpty ?? false);

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onDateSelected?.call(date),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 2.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '周$weekdayText',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isToday
                                      ? Colors.green.shade800
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isToday
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isToday
                                          ? Colors.green.shade800
                                          : Colors.black87,
                                    ),
                                  ),
                                  if (hasTasksForDay) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade700,
                                        borderRadius:
                                            BorderRadius.circular(2),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 时间栅格 + 7 列天（课表式：列有最小宽度，窄屏时横向滚动）
        Expanded(
          child: LayoutBuilder(
            builder: (context, viewportConstraints) {
              final viewportWidth = viewportConstraints.maxWidth;
              // 7 列所需总宽度 = 时间轴 + 间距 + 7 * 每列宽度；每列至少 _minDayColumnWidth
              final gridAreaWidth = viewportWidth - _timeAxisWidth - 4;
              final colWidth = (gridAreaWidth / 7).clamp(_minDayColumnWidth, double.infinity);
              final contentWidth = _timeAxisWidth + 4 + colWidth * 7;

              Widget gridContent = SizedBox(
                width: contentWidth,
                height: totalHeight,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 左侧时间轴
                      SizedBox(
                        width: _timeAxisWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: _timeLabels.map((label) {
                            return SizedBox(
                              height: _slotHeight,
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  const SizedBox(width: 4),
                  // 右侧 7 天列（课表式：固定列宽，保证可读性）
                  Row(
                    children: List.generate(7, (dayIndex) {
                        final dayTasks = tasksByDay[dayIndex] ?? const <Task>[];

                        return SizedBox(
                          width: colWidth,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              // 用 LayoutBuilder 拿到列宽/高，让 Stack 有明确尺寸，任务块才能填满列宽（左 4 右 4），对齐 iOS leading/trailing 约束
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return SizedBox(
                                    width: constraints.maxWidth,
                                    height: constraints.maxHeight,
                                    child: Stack(
                                      clipBehavior: Clip.antiAlias,
                                      children: [
                                        // 背景横线
                                        Column(
                                          children:
                                              List.generate(totalSlots, (i) {
                                            return SizedBox(
                                              height: _slotHeight,
                                              child: Align(
                                                alignment: Alignment.topCenter,
                                                child: Container(
                                                  height: 1,
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                        // 任务块：left/right 相对 Stack 填满列宽，高度按实际时长、可跨格
                                        ...dayTasks.map((task) {
                                          final color = task.category.color;
                                          final double blockHeight =
                                              _computeTaskHeight(task,
                                                  totalHeight: totalHeight);
                                          final double top = _computeTaskTop(
                                            task,
                                            totalHeight: totalHeight,
                                            blockHeight: blockHeight,
                                          );

                                          final start =
                                              '${task.startDate.hour.toString().padLeft(2, '0')}:${task.startDate.minute.toString().padLeft(2, '0')}';
                                          final end =
                                              '${task.endDate.hour.toString().padLeft(2, '0')}:${task.endDate.minute.toString().padLeft(2, '0')}';

                                          return Positioned(
                                            top: top,
                                            left: 4,
                                            right: 4,
                                            height: blockHeight,
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: widget.onTaskTap != null
                                                    ? () => widget.onTaskTap!(task)
                                                    : null,
                                                borderRadius: BorderRadius.circular(8),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  clipBehavior: Clip.antiAlias,
                                                  child: LayoutBuilder(
                                                    builder: (context, blockConstraints) {
                                                      // 课表式：根据块高度自适应布局，避免溢出
                                                      final h = blockConstraints.maxHeight;
                                                      final tight = h < 32;
                                                      final paddingV = tight ? 2.0 : 4.0;
                                                      final paddingH = tight ? 4.0 : 6.0;
                                                      return Container(
                                                        width: double.infinity,
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal: paddingH,
                                                            vertical: paddingV),
                                                        decoration: BoxDecoration(
                                                          color: color.withOpacity(0.85),
                                                          borderRadius:
                                                              BorderRadius.circular(8),
                                                          border: Border.all(
                                                            color: Colors.white
                                                                .withOpacity(0.8),
                                                            width: 1,
                                                          ),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color:
                                                                  color.withOpacity(0.35),
                                                              offset: const Offset(0, 2),
                                                              blurRadius: 4,
                                                            ),
                                                          ],
                                                        ),
                                                        child: FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          alignment: Alignment.centerLeft,
                                                          child: ConstrainedBox(
                                                            constraints: BoxConstraints(
                                                              maxWidth: blockConstraints.maxWidth - paddingH * 2,
                                                              maxHeight: h - paddingV * 2,
                                                            ),
                                                            child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment.stretch,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment.center,
                                                              children: [
                                                                Text(
                                                                  task.title,
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow.ellipsis,
                                                                  style: TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: tight ? 10 : 11,
                                                                    fontWeight:
                                                                        FontWeight.w600,
                                                                  ),
                                                                ),
                                                                SizedBox(height: tight ? 1 : 2),
                                                                Text(
                                                                  '$start - $end',
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow.ellipsis,
                                                                  style: TextStyle(
                                                                    color: Colors.white70,
                                                                    fontSize: tight ? 9 : 10,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      }),
                  ),
                ],
              ),
            );

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: gridContent,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 根据任务持续时间换算出在纵向时间轴上的高度（课表式）。
  /// 用户时间不一定落在默认时间格上，跨格是正常的，只按实际分钟数线性映射。
  double _computeTaskHeight(Task task, {required double totalHeight}) {
    final int totalMinutesRange = (_endHour - _startHour) * 60;
    if (totalMinutesRange <= 0) return 40;

    int durationMinutes = task.endDate.difference(task.startDate).inMinutes;
    if (durationMinutes < 1) durationMinutes = 1;

    // 按实际时长线性映射到全天高度，不按格对齐
    double h = totalHeight * (durationMinutes / totalMinutesRange);
    const double minHeight = 28.0;
    // 不设最大跨格数，允许长任务跨多格；仅限制不超过一天总高
    final double maxHeight = totalHeight - 4;
    return h.clamp(minHeight, maxHeight);
  }

  /// 根据任务开始时间换算到纵向位置（精确到分钟，不按格对齐，可落在两格之间）。
  double _computeTaskTop(
    Task task, {
    required double totalHeight,
    required double blockHeight,
  }) {
    final start = task.startDate;
    final int totalMinutesRange = (_endHour - _startHour) * 60;
    int minutesFromStart = (start.hour - _startHour) * 60 + start.minute;

    if (totalMinutesRange <= 0) return 2;
    if (minutesFromStart < 0) minutesFromStart = 0;
    if (minutesFromStart >= totalMinutesRange) {
      minutesFromStart = totalMinutesRange - 1;
    }

    // 按分钟线性映射，不吸附到格线
    double top = totalHeight * (minutesFromStart / totalMinutesRange);

    // 不超出底部
    if (top + blockHeight > totalHeight) {
      top = (totalHeight - blockHeight).clamp(2.0, double.infinity);
    }
    if (top < 2) top = 2;
    return top;
  }
}
