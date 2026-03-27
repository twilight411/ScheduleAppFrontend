import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_question_page.dart';
import 'onboarding_v1_data.dart';
import 'onboarding_v1_flow_page.dart' show kOnboardingV1DoneKey;
import 'onboarding_v2_flow_page.dart' show kOnboardingV2DoneKey;
import 'onboarding_v2_question_page.dart' show OnboardingV2QuestionPage, V2BubbleOption;
import '../../models/onboarding_question.dart';
import '../basic_info/basic_info_flow_page.dart';

/// 统一的 Onboarding 流程页：V1（3 问）+ V2（关键词）在同一页面栈内用状态切换，
/// V2 可点左箭头返回 V1，无需 Navigator.pop。
class OnboardingFlowPage extends StatefulWidget {
  const OnboardingFlowPage({
    super.key,
    this.initialPhase = OnboardingPhase.v1,
  });

  /// 进入时先显示哪一阶段（例如从 app 恢复时 v1 已完成则传 v2）
  final OnboardingPhase initialPhase;

  @override
  State<OnboardingFlowPage> createState() => _OnboardingFlowPageState();
}

enum OnboardingPhase { v1, v2 }

class _OnboardingFlowPageState extends State<OnboardingFlowPage> {
  late OnboardingPhase _phase;

  // V1 状态
  final PageController _pageController = PageController();
  final List<OnboardingQuestionItem> _questions = onboardingV1Questions;
  late List<int> _selectedIndices;

  // V2 状态
  static const List<V2BubbleOption> _v2Options = [
    // 描述里的 \n 会在 OnboardingV2QuestionPage 中按行拆开显示，
    // 例如「专注事业/学业」一行、「寻求跨越」一行，和设计图一致。
    V2BubbleOption(title: '突破', description: '专注事业/学业\n寻求跨越'),
    V2BubbleOption(title: '修复', description: '关注健康/心理\n整理旧疾'),
    V2BubbleOption(title: '探索', description: '尝试兴趣/社交\n发现新可能'),
    V2BubbleOption(title: '稳定', description: '维系现状\n寻找内心的平和'),
  ];
  int _v2SelectedIndex = -1;
  String _v2CustomText = '';
  String _v2CustomDescription = '';

  @override
  void initState() {
    super.initState();
    _phase = widget.initialPhase;
    _selectedIndices = List.filled(_questions.length, -1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int get _currentPage {
    if (!_pageController.hasClients) return 0;
    final page = _pageController.page?.round() ?? 0;
    return page.clamp(0, _questions.length - 1);
  }

  void _goPrev() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goNext() {
    if (_currentPage < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeV1();
    }
  }

  Future<void> _completeV1() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingV1DoneKey, true);
    if (!mounted) return;
    setState(() => _phase = OnboardingPhase.v2);
  }

  void _goBackToV1() {
    // 从 V2 返回时只“往前一页”，停在 V1 的最后一题（第 3 题），不回到第 1 题
    if (_pageController.hasClients) {
      _pageController.jumpToPage(_questions.length - 1);
    }
    setState(() => _phase = OnboardingPhase.v1);
  }

  Future<void> _completeV2AndGoHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingV2DoneKey, true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const BasicInfoFlowPage()),
    );
  }

  void _onV1OptionSelected(int index) {
    setState(() => _selectedIndices[_currentPage] = index);
    // 点完选项后自动跳转到下一题（最后一题则进入 V2）
    _goNext();
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == OnboardingPhase.v1) {
      return Scaffold(
        backgroundColor: const Color(0xFFE2EEE0),
        body: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _questions.length,
          itemBuilder: (context, index) {
            final item = _questions[index];
            return OnboardingQuestionPage(
              item: item,
              selectedIndex: _selectedIndices[index],
              onOptionSelected: _onV1OptionSelected,
              showLeftArrow: index > 0,
              showRightArrow: true,
              onLeftArrowTap: _goPrev,
              onRightArrowTap: _goNext,
            );
          },
        ),
      );
    }

    // V2
    return Scaffold(
      backgroundColor: Colors.black,
      body: OnboardingV2QuestionPage(
        questionLine1: '如果给你接下来的这一年',
        questionLine2: '定一个关键词,你希望是',
        presetOptions: _v2Options,
        selectedIndex: _v2SelectedIndex,
        customText: _v2CustomText,
        customDescription: _v2CustomDescription,
        onSelectionChanged: (i) => setState(() => _v2SelectedIndex = i),
        onCustomTextChanged: (t) => setState(() => _v2CustomText = t),
        onCustomDescriptionChanged: (t) =>
            setState(() => _v2CustomDescription = t),
        showLeftArrow: true,
        showRightArrow: true,
        onLeftArrowTap: _goBackToV1,
        onRightArrowTap: _completeV2AndGoHome,
      ),
    );
  }
}
