import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_question_page.dart';
import 'onboarding_v1_data.dart';
import 'onboarding_v2_flow_page.dart';
import '../../models/onboarding_question.dart';

/// 是否已完成版本一提问的本地存储 key
const String kOnboardingV1DoneKey = 'onboarding_v1_done';

/// 版本一提问流程：3 页，左/右箭头切换，单选，完成后写入本地并跳转主界面
class OnboardingV1FlowPage extends StatefulWidget {
  const OnboardingV1FlowPage({super.key});

  @override
  State<OnboardingV1FlowPage> createState() => _OnboardingV1FlowPageState();
}

class _OnboardingV1FlowPageState extends State<OnboardingV1FlowPage> {
  final PageController _pageController = PageController();
  final List<OnboardingQuestionItem> _questions = onboardingV1Questions;
  /// 每道题选中的选项索引，-1 表示未选
  late List<int> _selectedIndices;

  @override
  void initState() {
    super.initState();
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
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingV1DoneKey, true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const OnboardingV2FlowPage(),
      ),
    );
  }

  void _onOptionSelected(int index) {
    setState(() {
      _selectedIndices[_currentPage] = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          final item = _questions[index];
          return OnboardingQuestionPage(
            item: item,
            selectedIndex: _selectedIndices[index],
            onOptionSelected: _onOptionSelected,
            showLeftArrow: index > 0,
            showRightArrow: true,
            onLeftArrowTap: _goPrev,
            onRightArrowTap: _goNext,
          );
        },
      ),
    );
  }
}
