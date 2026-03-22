import 'package:equatable/equatable.dart';

import 'repeat_option.dart';
import 'spirit_type.dart';

/// 对应 iOS 中的 Task 结构体
class Task extends Equatable {
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final SpiritType category;
  final RepeatOption repeatOption;
  final bool isAllDay;

  const Task({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.category,
    required this.repeatOption,
    required this.isAllDay,
  });

  Task copyWith({
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    SpiritType? category,
    RepeatOption? repeatOption,
    bool? isAllDay,
  }) {
    return Task(
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      category: category ?? this.category,
      repeatOption: repeatOption ?? this.repeatOption,
      isAllDay: isAllDay ?? this.isAllDay,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'category': category.name,
      'repeatOption': repeatOption.name,
      'isAllDay': isAllDay,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      startDate: DateTime.fromMillisecondsSinceEpoch(
        (json['startDate'] as int?) ?? 0,
      ),
      endDate: DateTime.fromMillisecondsSinceEpoch(
        (json['endDate'] as int?) ?? 0,
      ),
      category: SpiritType.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => SpiritType.light,
      ),
      repeatOption: RepeatOptionValues.values.firstWhere(
        (e) => e.name == json['repeatOption'],
        orElse: () => RepeatOption.never,
      ),
      isAllDay: json['isAllDay'] as bool? ?? false,
    );
  }

  /// 基于 title + startDate + endDate + category 做去重
  @override
  List<Object?> get props => [
        title,
        startDate,
        endDate,
        category,
      ];
}

