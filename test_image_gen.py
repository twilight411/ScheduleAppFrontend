"""
测试图像生成功能
"""
import asyncio
from app.ai.image_client import image_client


async def test_image_generation():
    """测试图像生成"""
    print("=== 图像生成测试 ===")
    print(f"Provider: {image_client.provider}")
    print(f"Base URL: {image_client.base_url}")
    print(f"Size: {image_client.size}")
    print(f"Has credentials: {bool(image_client.jiyun_access_key_id) and bool(image_client.jiyun_secret_access_key)}")
    
    if image_client.provider == "jiyun":
        print("\n--- 测试即梦API ---")
        print("注意：即梦API是异步任务模式，需要轮询结果")
    
    # 测试生图
    prompt = "一棵象征生活平衡的生命树，极简治愈画风，阳光明媚，有绿色的叶子和果实"
    
    try:
        print(f"\n正在生成图像，prompt: {prompt[:50]}...")
        image_url = await image_client.generate(
            prompt=prompt,
            purpose="test",
        )
        
        print(f"\n生成结果:")
        print(f"Image URL: {image_url}")
        
        if image_url.startswith("[FALLBACK]"):
            print("⚠️  使用了兜底图像（API未配置或不可用）")
        elif image_url.startswith("http"):
            print("✅  图像生成成功！")
        else:
            print("❌  生成失败")
            
    except Exception as e:
        print(f"\n❌  生成异常: {str(e)}")


if __name__ == "__main__":
    asyncio.run(test_image_generation())