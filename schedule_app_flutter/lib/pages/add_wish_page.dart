import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/spirit_type.dart';
import '../models/wish.dart';
import '../providers/wish_provider.dart';

/// 新增愿望页面
///
/// 参考 iOS 的 AddWishViewController：
/// - 标题、内容输入
/// - 精灵类别选择
/// - 精灵说明预览
class AddWishPage extends StatefulWidget {
  const AddWishPage({super.key});

  @override
  State<AddWishPage> createState() => _AddWishPageState();
}

class _AddWishPageState extends State<AddWishPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  SpiritType _selectedSpirit = SpiritType.light;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('标题不能为空')),
      );
      return;
    }

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('内容不能为空')),
      );
      return;
    }

    final wish = Wish(
      title: title,
      content: content,
      spirit: _selectedSpirit,
    );

    context.read<WishProvider>().addWish(wish);
    Navigator.of(context).pop();
  }

  String _spiritDescription(SpiritType spirit) {
    switch (spirit) {
      case SpiritType.light:
        return '光精灵：负责工作学习相关的愿望';
      case SpiritType.water:
        return '水精灵：负责娱乐休闲相关的愿望';
      case SpiritType.soil:
        return '土壤精灵：负责健康运动相关的愿望';
      case SpiritType.air:
        return '空气精灵：负责社交活动相关的愿望';
      case SpiritType.nutrition:
        return '营养精灵：负责兴趣爱好相关的愿望';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            '取消',
            style: TextStyle(color: Colors.blue),
          ),
        ),
        centerTitle: true,
        title: const Text(
          '新增心愿',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _onSubmit,
            child: const Text(
              '确定',
              style: TextStyle(color: Colors.blue),
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
                  hintText: '请输入愿望标题',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 内容
              TextField(
                controller: _contentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '内容',
                  hintText: '请输入愿望的详细内容',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // 精灵选择标题
              const Text(
                '选择负责精灵',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // 精灵选择 Chip
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: SpiritType.values.map((spirit) {
                    final bool selected = spirit == _selectedSpirit;
                    final color = spirit.color;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(spirit.displayName),
                        avatar: Icon(
                          spirit.icon,
                          size: 18,
                          color: selected ? Colors.white : color,
                        ),
                        selected: selected,
                        selectedColor: color,
                        backgroundColor: color.withOpacity(0.12),
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: selected ? color : color.withOpacity(0.4),
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedSpirit = spirit;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // 精灵预览卡片
              Card(
                color: _selectedSpirit.color.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: _selectedSpirit.color,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _selectedSpirit.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _selectedSpirit.icon,
                          color: _selectedSpirit.color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _spiritDescription(_selectedSpirit),
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

