import 'package:flutter/foundation.dart';

import '../models/wish.dart';
import '../models/spirit_type.dart';
import '../repositories/local_wish_repository.dart';
import '../repositories/wish_repository.dart';

/// 管理愿望列表的状态（对应 iOS 中 WishBottleViewController 的逻辑）
class WishProvider extends ChangeNotifier {
  /// 当前所有愿望列表
  final List<Wish> wishes = [];

  /// 愿望数据源（当前使用本地实现，后续可替换为远程或混合实现）
  final WishRepository _repository;

  /// 当前选中的愿望索引，null 表示未选中
  int? selectedWishIndex;

  WishProvider({WishRepository? repository})
      : _repository = repository ?? const LocalWishRepository() {
    _initMockData();
    _loadFromStorage();
  }

  /// 初始化几条假数据，方便测试
  void _initMockData() {
    wishes.addAll([
      Wish(
        title: '环游世界',
        content: '有一天背上行囊去看世界的每个角落。',
        spirit: SpiritType.light,
      ),
      Wish(
        title: '学会一门新乐器',
        content: '坚持一年，每天练习 30 分钟吉他。',
        spirit: SpiritType.water,
      ),
      Wish(
        title: '写一本属于自己的书',
        content: '记录这些年的故事和感悟，哪怕只是打印一本送给自己。',
        spirit: SpiritType.nutrition,
      ),
    ]);
  }

  /// 从本地存储加载愿望列表
  ///
  /// 使用异步方式加载，加载成功后会覆盖当前内存中的假数据。
  Future<void> _loadFromStorage() async {
    final storedWishes = await _repository.getAllWishes();
    if (storedWishes.isNotEmpty) {
      wishes
        ..clear()
        ..addAll(storedWishes);
      selectedWishIndex = null;
      notifyListeners();
    }
  }

  Future<void> _syncToStorage() async {
    await _repository.saveWishes(List<Wish>.from(wishes));
  }

  /// 添加愿望到列表末尾
  void addWish(Wish wish) {
    wishes.add(wish);
    notifyListeners();
    _syncToStorage();
  }

  /// 删除指定索引的愿望
  ///
  /// 如果删除的是当前选中项，则清空选中状态；
  /// 如果删除的是选中项之前的元素，需要更新选中索引。
  void removeWish(int index) {
    if (index < 0 || index >= wishes.length) return;

    wishes.removeAt(index);

    if (selectedWishIndex != null) {
      if (selectedWishIndex == index) {
        // 删除的是当前选中项
        selectedWishIndex = null;
      } else if (selectedWishIndex! > index) {
        // 删除的是选中项之前的元素，索引需要前移一位
        selectedWishIndex = selectedWishIndex! - 1;
      }
    }

    notifyListeners();
    _syncToStorage();
  }

  /// 切换指定索引愿望的选中状态（单选模式）
  ///
  /// - 如果当前未选中任何愿望，则选中该索引
  /// - 如果当前已选中该索引，则取消选中
  /// - 如果当前选中的是其他索引，则切换到该索引
  void toggleWishSelection(int index) {
    if (index < 0 || index >= wishes.length) return;

    if (selectedWishIndex == index) {
      selectedWishIndex = null;
    } else {
      selectedWishIndex = index;
    }

    notifyListeners();
  }

  /// 清空选中状态
  void clearSelection() {
    if (selectedWishIndex == null) return;
    selectedWishIndex = null;
    notifyListeners();
  }

  /// 获取当前选中的愿望
  Wish? getSelectedWish() {
    if (selectedWishIndex == null) return null;
    final index = selectedWishIndex!;
    if (index < 0 || index >= wishes.length) return null;
    return wishes[index];
  }

  /// 清空所有愿望与选中状态
  void clearAll() {
    wishes.clear();
    selectedWishIndex = null;
    notifyListeners();
    _syncToStorage();
  }
}

