import 'dart:async';
import 'dart:math';

import '../models/ai_chat_result.dart';
import '../models/spirit_type.dart';
import 'ai_chat_repository.dart';

/// 本地 Mock AI 聊天数据源实现
///
/// 用于开发阶段，不调用真实 API，返回模拟响应。
/// 这样可以先开发 UI，等后端准备好了再切换为 RemoteAIChatRepository。
///
/// 注意：这只是开发阶段的临时实现，生产环境必须使用后端接口。
/// 参考 iOS 代码中 AIAPIManager 的测试模式逻辑。
class LocalAIChatRepository implements AIChatRepository {
  const LocalAIChatRepository();

  @override
  Future<AIChatResult> sendMessage({
    required String message,
    SpiritType? spiritType,
    bool isGroupChat = false,
  }) async {
    // 模拟网络延迟（1-2秒），让 UI 体验更真实
    await Future.delayed(Duration(milliseconds: 1000 + Random().nextInt(1000)));

    // 根据精灵类型或群聊模式生成不同的回复
    if (isGroupChat || spiritType == null) {
      return AIChatResult(reply: _generateGroupChatResponse(message));
    }
    return AIChatResult(reply: _generateSpiritResponse(message, spiritType));
  }

  /// 生成群聊模式的回复
  ///
  /// 群聊模式下，五个精灵一起给出综合建议。
  String _generateGroupChatResponse(String message) {
    final responses = [
      '我们会一起帮助你！',
      '让我们从多个角度来思考这个问题。',
      '小太阳、泡泡、培培、悠悠和星星都在为你出谋划策～',
      '综合大家的建议，我们建议你...',
      '这是一个需要平衡的问题，让我们看看各个精灵怎么说。',
      '五个精灵各有各的看法，但我们都希望你能找到最适合自己的方式。',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  /// 根据精灵类型生成特定回复
  ///
  /// 每个精灵都有自己独特的性格和回复风格。
  String _generateSpiritResponse(String message, SpiritType spiritType) {
    switch (spiritType) {
      case SpiritType.light:
        // 光精灵（工作学习）- 温柔傲娇
        final responses = [
          '让我们一起制定学习计划！',
          '学习需要坚持，但也要注意休息哦～',
          '今天的学习目标完成了吗？',
          '专注力是可以通过练习提升的，我们一起努力！',
          '学习不是一蹴而就的，要有耐心和恒心。',
        ];
        return responses[Random().nextInt(responses.length)];

      case SpiritType.water:
        // 水精灵（娱乐休闲）- 活泼俏皮
        final responses = [
          '记得及时休息哦～',
          '工作再忙也要放松一下！',
          '来，我们一起找点有趣的事情做吧～',
          '娱乐是生活的重要组成部分，不要忽视它！',
          '适当的娱乐能让你的工作效率更高哦！',
        ];
        return responses[Random().nextInt(responses.length)];

      case SpiritType.soil:
        // 土壤精灵（健康）- 温柔关怀
        final responses = [
          '今天运动了吗？',
          '身体健康是最重要的，记得照顾好自己～',
          '适当的运动能让你的状态更好哦！',
          '健康的生活方式需要坚持，我们一起加油！',
          '早睡早起，规律作息，身体会感谢你的。',
        ];
        return responses[Random().nextInt(responses.length)];

      case SpiritType.air:
        // 空气精灵（社交）- 优雅从容
        final responses = [
          '和朋友聊聊天吧～',
          '社交关系需要用心维护，但也不要过度消耗自己。',
          '有时候，和朋友的交流能带来新的灵感。',
          '保持适当的社交距离，既要有联系，也要有空间。',
          '真正的友谊是相互理解和支持的。',
        ];
        return responses[Random().nextInt(responses.length)];

      case SpiritType.nutrition:
        // 营养精灵（爱好）- 高冷傲娇
        final responses = [
          '培养一个新爱好！',
          '兴趣是最好的老师，找到你真正喜欢的事情。',
          '不要为了培养兴趣而培养，要找到真正让你快乐的事情。',
          '兴趣需要时间沉淀，不要急于求成。',
          '真正的兴趣会让人忘记时间，沉浸其中。',
        ];
        return responses[Random().nextInt(responses.length)];
    }
  }
}
