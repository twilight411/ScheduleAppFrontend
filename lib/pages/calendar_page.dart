import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/spirit_type.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/task_item.dart';
import '../widgets/animated_button.dart';
import '../utils/resource_manager.dart';
import '../widgets/week_calendar_view.dart';
import '../widgets/month_calendar_view.dart';
import '../widgets/day_calendar_view.dart';
import '../widgets/leaf_button_group.dart'; // 提供 CalendarMode 枚举
import 'wish_bottle_page.dart';
import 'add_task_page.dart';

/// 日历页面：展示日 / 周 / 月三种视图
///
/// 参考 iOS 的 CalendarViewController：
/// - 顶部为日期选择
/// - 中间为当前日期任务列表
/// - 右下角为添加任务按钮
class CalendarPage extends StatefulWidget {
  const CalendarPage({
    super.key,
    this.aiChatExpandedNotifier,
    this.initialMode = CalendarMode.day,
    this.onModeChanged,
  });

  /// AI聊天框展开状态通知器（用于动态调整卡片大小）
  final ValueNotifier<bool>? aiChatExpandedNotifier;

  /// 初始日历模式（对应三叶草按钮）
  final CalendarMode initialMode;

  /// 当内部主动切换模式时触发（例如点击周 / 月视图里的日期跳转到日视图）
  final ValueChanged<CalendarMode>? onModeChanged;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDate;
  bool _isAIChatExpanded = false;
  late CalendarMode _calendarMode;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _calendarMode = widget.initialMode;

    // 监听AI聊天框展开状态
    widget.aiChatExpandedNotifier?.addListener(_onAIChatExpandedChanged);
    _isAIChatExpanded = widget.aiChatExpandedNotifier?.value ?? false;
  }

  @override
  void didUpdateWidget(covariant CalendarPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当外部传入的 initialMode 发生变化（例如三叶草按钮被点击）时，
    // 立即同步到内部的 _calendarMode，从而立刻切换日 / 周 / 月视图，
    // 避免必须“切换页面再切回来”才能看到变化。
    if (oldWidget.initialMode != widget.initialMode) {
      setState(() {
        _calendarMode = widget.initialMode;
      });
    }
  }

  @override
  void dispose() {
    widget.aiChatExpandedNotifier?.removeListener(_onAIChatExpandedChanged);
    super.dispose();
  }

  void _onAIChatExpandedChanged() {
    setState(() {
      _isAIChatExpanded = widget.aiChatExpandedNotifier?.value ?? false;
    });
  }

  /// 前一天
  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  /// 后一天
  void _goToNextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  /// 从外部（周 / 月视图）跳到某一天，并自动切到日视图
  void _jumpToDay(DateTime date) {
    setState(() {
      _selectedDate = date;
      _calendarMode = CalendarMode.day;
    });
    widget.onModeChanged?.call(CalendarMode.day);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // 顶部文字格式、周标题等由各自子视图（Day/Week/Month）内部负责，这里不再计算。

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final chatProvider = context.watch<ChatProvider>();

    final allTasks = List<Task>.from(taskProvider.tasks)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    // 根据 AI 聊天区的精灵选择进行全局过滤：
    // 只要选中了小精灵（selectedSpirit != null），就按该精灵类型过滤任务，
    // 和是否群聊无关（对齐 iOS：点击小精灵即视为“过滤该类型任务”）。
    final SpiritType? filterSpirit = chatProvider.selectedSpirit;

    final List<Task> filteredAllTasks = filterSpirit == null
        ? allTasks
        : allTasks.where((task) => task.category == filterSpirit).toList();

    // 容器垂直范围：top 10，bottom 距底部 130/400；边线3/4处用于放许愿瓶、加号
    final mq = MediaQuery.of(context);
    final bodyHeight = mq.size.height - mq.padding.top - 60; // 状态栏 + 导航栏
    final bottomPadding = _isAIChatExpanded ? 400 : 130;
    final containerHeight = bodyHeight - 10 - bottomPadding;
    final containerThreeQuarterY = 10 + containerHeight * 3 / 4; // 3/4处位置

    return Scaffold(
      // 让外层 MainContainerView 的背景透出来
      backgroundColor: Colors.transparent,
      // iOS: calendarContainerView.topAnchor = safeAreaLayoutGuide.topAnchor + 10
      // 这里不使用SafeArea，因为外层MainContainerView已经处理了SafeArea
      body: Stack(
        clipBehavior: Clip.none, // 允许三叶草按钮超出边界显示
        children: [
          // 主日程容器（半透明白色卡片，参考 iOS 的 calendarContainerView）
          // iOS: 当AI展开时，containerBottomConstraint从-130变为-400
          Align(
            alignment: Alignment.topCenter,
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              // iOS: top = safeAreaLayoutGuide.topAnchor + 10
              // iOS: leading/trailing = 20
              // iOS: bottom = view.bottomAnchor - 130（收起）或 -400（展开）
              padding: EdgeInsets.fromLTRB(
                20,
                10, // 从顶部开始，距离SafeArea顶部10
                20,
                _isAIChatExpanded ? 400 : 130, // 底部距离：收起时130，展开时400
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Padding(
                  // 参考 iOS：calendarContentView 内边距 top 20 / left 40 / right 20 / bottom 20
                  // 这里适当收紧顶部内边距，让日期标题更靠近容器顶部
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    children: [
                      // 顶部区域 + 主体内容根据 _calendarMode 切换
                      if (_calendarMode == CalendarMode.day) ...[
                        // 日视图：使用 24 小时时间格 + 任务块的 DayCalendarView
                        Expanded(
                          child: DayCalendarView(
                            anchorDate: _selectedDate,
                            tasks: filteredAllTasks,
                            onDateChanged: (date) {
                              setState(() {
                                _selectedDate = date;
                              });
                            },
                          ),
                        ),
                      ] else if (_calendarMode == CalendarMode.week) ...[
                        Expanded(
                          child: WeekCalendarView(
                            anchorDate: _selectedDate,
                            tasks: filteredAllTasks,
                            onDateSelected: _jumpToDay,
                            onTaskTap: (task) {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => AddTaskPage(taskToEdit: task),
                                ),
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: MonthCalendarView(
                            anchorDate: _selectedDate,
                            tasks: filteredAllTasks,
                            onDateSelected: _jumpToDay,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 加号按钮：嵌在日历卡片右下角边缘（对齐 iOS: addTaskButton.bottom = calendarContainerView.bottom + 10）
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            right: 20, // 与容器右边距对齐
            // 按 iOS 约束：按钮底部比容器底部再低 10，所以这里用容器底部 Y + 10 - 按钮半高
            top: 10 + (containerHeight) - 22, // 22 = 44/2
            child: AnimatedButton(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddTaskPage()),
                );
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Image.asset(
                  ResourceManager.calendar.addTask,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover, // 使用 cover 让图片填满整个按钮，避免白边
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.add,
                      size: 24,
                    );
                  },
                ),
              ),
            ),
          ),

          // 许愿瓶按钮：嵌在日历卡片左下角边缘（对齐 iOS: wishBottleButton.bottom = calendarContainerView.bottom + 10）
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            left: 10, // iOS: leading = calendarContainer.leading - 10
            // 容器底部 Y + 10 - 按钮半高（50/2=25）
            top: 10 + (containerHeight) - 25,
            child: AnimatedButton(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WishBottlePage()),
                );
              },
              child: SizedBox(
                width: 50,
                height: 50,
                child: Image.asset(
                  ResourceManager.calendar.wishBottle,
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.auto_awesome,
                      size: 44,
                      color: Colors.purple,
                    );
                  },
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

// 日视图的顶部和任务块动画交由 DayCalendarView 组件内部处理，这里无需额外封装。
