import '../models/wish.dart';
import '../services/storage_service.dart';
import 'wish_repository.dart';

/// 使用本地 StorageService 作为愿望数据源的实现。
class LocalWishRepository implements WishRepository {
  const LocalWishRepository();

  @override
  Future<List<Wish>> getAllWishes() async {
    return StorageService.instance.loadWishes();
  }

  @override
  Future<void> saveWishes(List<Wish> wishes) async {
    await StorageService.instance.saveWishes(List<Wish>.from(wishes));
  }
}

