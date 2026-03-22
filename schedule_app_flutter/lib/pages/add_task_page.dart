import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/repeat_option.dart';
import '../models/spirit_type.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

/// 新建任务页面
///
/// 参考 iOS 的 AddTaskViewController：
/// - 上方为标题、简介等基础信息
/// - 中间为时间、重复选项与是否全天
/// - 下方为精灵类别选择
class AddTaskPage extends StatefulWidget {
  const AddTaskPage({
    super.key,
    this.prefilledTitle,
    this.prefilledDescription,
    this.prefilledCategory,
    this.taskToEdit,
  });

  /// 预填标题（从愿望等入口跳转时使用）
  final String? prefilledTitle;

  /// 预填简介
  final String? prefilledDescription;

  /// 预填精灵类别
  final SpiritType? prefilledCategory;

  /// 要编辑的任务（周视图/日视图点击任务进入编辑时传入）
  final Task? taskToEdit;

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  late DateTime _startDateTime;
  late DateTime _endDateTime;

  bool _isAllDay = false;
  RepeatOption _repeatOption = RepeatOption.never;
  late SpiritType _selectedSpirit;

  final DateFormat _dateTimeFormatter = DateFormat('yyyy年M月d日 HH:mm');

  @override
  void initState() {
    super.initState();

    final task = widget.taskToEdit;
    if (task != null) {
      _startDateTime = task.startDate;
      _endDateTime = task.endDate;
      _titleController = TextEditingController(text: task.title);
      _descriptionController = TextEditingController(text: task.description);
      _selectedSpirit = task.category;
      _repeatOption = task.repeatOption;
      _isAllDay = task.isAllDay;
    } else {
      final now = DateTime.now();
      _startDateTime = DateTime(now.year, now.month, now.day, now.hour, (now.minute ~/ 5) * 5);
      _endDateTime = _startDateTime.add(const Duration(hours: 1));
      _titleController = TextEditingController(text: widget.prefilledTitle ?? '');
      _descriptionController = TextEditingController(text: widget.prefilledDescription ?? '');
      _selectedSpirit = widget.prefilledCategory ?? SpiritType.light;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    // 等待日期选择器完全关闭，避免部分 Android 设备上时间选择器无法弹出的问题
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _startDateTime.hour,
        minute: _startDateTime.minute,
      ),
    );
    if (time == null || !mounted) return;

    setState(() {
      _startDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (_endDateTime.isBefore(_startDateTime)) {
        _endDateTime = _startDateTime.add(const Duration(hours: 1));
      }
    });
  }

  Future<void> _pickEndDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    // 等待日期选择器完全关闭，避免部分 Android 设备上时间选择器无法弹出的问题
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _endDateTime.hour,
        minute: _endDateTime.minute,
      ),
    );
    if (time == null || !mounted) return;

    setState(() {
      _endDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (_endDateTime.isBefore(_startDateTime)) {
        _startDateTime = _endDateTime.subtract(const Duration(hours: 1));
      }
    });
  }

  void _onSubmit() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('标题不能为空')),
      );
      return;
    }

    final task = Task(
      title: title,
      description: description,
      startDate: _startDateTime,
      endDate: _endDateTime,
      category: _selectedSpirit,
      repeatOption: _repeatOption,
      isAllDay: _isAllDay,
    );

    final provider = context.read<TaskProvider>();
    if (widget.taskToEdit != null) {
      provider.updateTask(widget.taskToEdit!, task);
    } else {
      provider.addTask(task);
    }
    Navigator.of(context).pop(true);
  }

  /// 删除任务（仅编辑模式下可用）
  Future<void> _onDelete() async {
    if (widget.taskToEdit == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除任务'),
        content: const Text('确定要删除这个任务吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              '删除',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<TaskProvider>().removeTask(widget.taskToEdit!);
      Navigator.of(context).pop(true);
    }
  }

  /// 选择精灵类别（iOS 风格的底部弹窗）
  void _pickSpiritType() {
    showModalBottomSheet<SpiritType>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '选择类别',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(height: 1),
              ...SpiritType.values.map((spirit) {
                final selected = spirit == _selectedSpirit;
                return ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: spirit.color.withOpacity(0.2),
                    child: Icon(
                      spirit.icon,
                      size: 18,
                      color: spirit.color,
                    ),
                  ),
                  title: Text(spirit.displayName),
                  trailing: selected
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedSpirit = spirit;
                    });
                    Navigator.of(context).pop();
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            '取消',
            style: TextStyle(color: Colors.blue),
          ),
        ),
        centerTitle: true,
        title: Text(
          widget.taskToEdit != null ? '编辑任务' : '新任务',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (widget.taskToEdit != null)
            TextButton(
              onPressed: _onDelete,
              child: Text(
                '删除',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          TextButton(
            onPressed: _onSubmit,
            child: Text(
              widget.taskToEdit != null ? '保存' : '添加',
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '标题',
                  hintText: '请输入任务标题',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 简介
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '简介',
                  hintText: '可选，简单描述一下这个任务',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // 开始时间
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('开始时间'),
                subtitle: Text(_dateTimeFormatter.format(_startDateTime)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickStartDateTime,
              ),
              const Divider(),

              // 结束时间
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('结束时间'),
                subtitle: Text(_dateTimeFormatter.format(_endDateTime)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickEndDateTime,
              ),
              const Divider(),

              // 是否全天
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('全天'),
                value: _isAllDay,
                onChanged: (value) {
                  setState(() {
                    _isAllDay = value;
                  });
                },
              ),
              const SizedBox(height: 8),

              // 重复选项
              Row(
                children: [
                  const Text('重复'),
                  const SizedBox(width: 16),
                  DropdownButton<RepeatOption>(
                    value: _repeatOption,
                    items: RepeatOptionValues.values
                        .map(
                          (option) => DropdownMenuItem<RepeatOption>(
                            value: option,
                            child: Text(option.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _repeatOption = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 精灵类别选择（iOS 风格：点击行后弹出底部选单）
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  '类别',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _selectedSpirit.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _selectedSpirit.icon,
                        size: 18,
                        color: _selectedSpirit.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedSpirit.displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickSpiritType,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

