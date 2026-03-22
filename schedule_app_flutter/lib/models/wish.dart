import 'package:uuid/uuid.dart';

import 'spirit_type.dart';

/// 对应 iOS 中的 Wish 结构体
class Wish {
  final String id;
  final String title;
  final String content;
  final SpiritType spirit;
  final bool isChecked;
  final DateTime createdDate;

  static const _uuid = Uuid();

  Wish({
    String? id,
    required this.title,
    required this.content,
    required this.spirit,
    bool isChecked = false,
    DateTime? createdDate,
  })  : id = id ?? _uuid.v4(),
        isChecked = isChecked,
        createdDate = createdDate ?? DateTime.now();

  Wish copyWith({
    String? id,
    String? title,
    String? content,
    SpiritType? spirit,
    bool? isChecked,
    DateTime? createdDate,
  }) {
    return Wish(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      spirit: spirit ?? this.spirit,
      isChecked: isChecked ?? this.isChecked,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'spirit': spirit.name,
      'isChecked': isChecked,
      'createdDate': createdDate.millisecondsSinceEpoch,
    };
  }

  factory Wish.fromJson(Map<String, dynamic> json) {
    return Wish(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      spirit: SpiritType.values.firstWhere(
        (e) => e.name == json['spirit'],
        orElse: () => SpiritType.light,
      ),
      isChecked: json['isChecked'] as bool? ?? false,
      createdDate: json['createdDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              json['createdDate'] as int,
            )
          : DateTime.now(),
    );
  }
}

