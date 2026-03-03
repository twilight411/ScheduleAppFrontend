import '../models/wish.dart';

/// 抽象愿望数据源，方便后续切换为远程接口或混合模式。
abstract class WishRepository {
  /// 获取所有愿望
  Future<List<Wish>> getAllWishes();

  /// 持久化整个愿望列表
  ///
  /// 当前实现为「整表保存」，后续可以扩展为增删改的细粒度方法。
  Future<void> saveWishes(List<Wish> wishes);
}

