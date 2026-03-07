import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_v2_question_page.dart';
import '../../pages/main_container_view.dart';

/// 是否已完成版本二提问的本地存储 key
const String kOnboardingV2DoneKey = 'onboarding_v2_done';

/// 版本二提问流程：单页（关键词选题），完成后写入本地并跳转主界面
class OnboardingV2FlowPage extends StatefulWidget {
  const OnboardingV2FlowPage({super.key});

  @override
  State<OnboardingV2FlowPage> createState() => _OnboardingV2FlowPageState();
}

class _OnboardingV2FlowPageState extends State<OnboardingV2FlowPage> {
  static const List<V2BubbleOption> _options = [
    V2BubbleOption(
      title: '突破',
      // 使用 \n 手动控制换行，第一行「专注事业/学业」，第二行「寻求跨越」
      description: '专注事业/学业\n寻求跨越',
    ),
    V2BubbleOption(
      title: '修复',
      description: '关注健康/心理\n整理旧疾',
    ),
    V2BubbleOption(
      title: '探索',
      description: '尝试兴趣/社交\n发现新可能',
    ),
    V2BubbleOption(
      title: '稳定',
      description: '维系现状\n寻找内心的平和',
    ),
  ];

  int _selectedIndex = -1;
  String _customText = '';

  Future<void> _completeAndGoHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingV2DoneKey, true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const MainContainerView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: OnboardingV2QuestionPage(
        questionLine1: '如果给你接下来的这一年',
        questionLine2: '定一个关键词,你希望是',
        presetOptions: _options,
        selectedIndex: _selectedIndex,
        customText: _customText,
        onSelectionChanged: (index) => setState(() => _selectedIndex = index),
        onCustomTextChanged: (text) => setState(() => _customText = text),
        showLeftArrow: Navigator.of(context).canPop(),
        showRightArrow: true,
        onLeftArrowTap: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
        onRightArrowTap: _completeAndGoHome,
      ),
    );
  }
}
