import 'package:flutter/material.dart';
import '../utils/resource_manager.dart';

/// 月果实组件
/// 
/// 对应 iOS 的 setupMonthFruit，显示本月的果实数据。
class MonthFruitWidget extends StatelessWidget {
  const MonthFruitWidget({
    super.key,
    required this.fruitData,
    this.backgroundImagePath,
    this.fruitImagePath,
  });

  /// 果实数据（Map格式，包含 fruitImageUrl, fruitName, description 等）
  final Map<String, dynamic> fruitData;

  /// 背景图片路径（可选，后续阶段5会添加）
  /// 
  /// 如果提供，将作为背景显示
  final String? backgroundImagePath;

  /// 果实图片路径（可选，后续阶段5会添加）
  /// 
  /// 如果提供，将优先使用此路径，否则使用 fruitData 中的 fruitImageUrl
  final String? fruitImagePath;

  /// 获取果实图片URL
  String? get _fruitImageUrl {
    // 优先使用 fruitImagePath（传入的路径）
    if (fruitImagePath != null) {
      return fruitImagePath;
    }
    // 其次使用 ResourceManager 的默认月果实图片
    return ResourceManager.plant.monthFruit;
  }

  @override
  Widget build(BuildContext context) {
    // 优先使用传入的 backgroundImagePath，否则使用 ResourceManager 的默认路径
    final bgPath = backgroundImagePath ?? ResourceManager.backgrounds.plantBottom;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 背景图片
            Positioned.fill(
              child: Image.asset(
                bgPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // 如果背景图加载失败，使用半透明白色
                  return Container(
                    color: Colors.white.withOpacity(0.3),
                  );
                },
              ),
            ),
            
            // 内容区域
            Column(
              children: [
                // 标题"本月果实"（距离顶部45）
                Padding(
                  padding: const EdgeInsets.only(top: 45),
                  child: Text(
                    '本月果实',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // 果实图片（中间，居中显示，180x180）
                Expanded(
                  child: Center(
                    child: _buildFruitImage(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建果实图片
  Widget _buildFruitImage() {
    final imageUrl = _fruitImageUrl;
    
    // 如果有图片URL
    if (imageUrl != null && imageUrl.isNotEmpty) {
      // 判断是网络图片还是本地资源
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        // 网络图片
        return SizedBox(
          width: 180,
          height: 180,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderFruit();
            },
          ),
        );
      } else {
        // 本地资源图片
        return SizedBox(
          width: 180,
          height: 180,
          child: Image.asset(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderFruit();
            },
          ),
        );
      }
    }
    
    // 如果没有图片，显示占位图标
    return _buildPlaceholderFruit();
  }

  /// 构建占位符果实图标
  /// 
  /// 参考 iOS：使用 star.fill，橙色
  Widget _buildPlaceholderFruit() {
    return SizedBox(
      width: 180,
      height: 180,
      child: Icon(
        Icons.star,
        size: 180,
        color: Colors.orange,
      ),
    );
  }
}
