import 'package:flutter/material.dart';

import '../../screens/done_placeholder_screen.dart';
import 'onboarding_question_page.dart';
import 'onboarding_v1_data.dart';
import '../../models/onboarding_question.dart';

/// 与主工程 [OnboardingV1FlowPage] 同逻辑，完成三题后进入沙盒占位页（不跳 V2 / 不写 prefs）。
class OnboardingV1SandboxFlowPage extends StatefulWidget {
  const OnboardingV1SandboxFlowPage({super.key});

  @override
  State<OnboardingV1SandboxFlowPage> createState() =>
      _OnboardingV1SandboxFlowPageState();
}

class _OnboardingV1SandboxFlowPageState
    extends State<OnboardingV1SandboxFlowPage> {
  final PageController _pageController = PageController();
  final List<OnboardingQuestionItem> _questions = onboardingV1Questions;
  late List<int> _selectedIndices;

  /// 当前题号（0-based）。必须用 onPageChanged 维护，勿用 pageController.page 在动画中 round，
  /// 否则容易一直判成第 0 页，表现为「永远只有一题」。
  int _pageIndex = 0;

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

  void _goPrev() {
    if (_pageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goNext() {
    if (_pageIndex < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishSandbox();
    }
  }

  void _finishSandbox() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const DonePlaceholderScreen()),
    );
  }

  void _onOptionSelected(int index) {
    setState(() {
      _selectedIndices[_pageIndex] = index;
    });
    // 与主工程 OnboardingFlowPage 一致：点选后自动下一题（最后一题则结束沙盒）
    _goNext();
  }

  @override
  Widget build(BuildContext context) {
    // 勿用纯黑：底图 PNG 若有透明区域会与提问页叠出「蒙层」感；与提问页 error 回退色一致
    return Scaffold(
      backgroundColor: const Color(0xFFE2EEE0),
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _questions.length,
            onPageChanged: (i) {
              setState(() => _pageIndex = i);
            },
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
          // 不占 AppBar，避免压到原引导顶栏；仅提示当前第几题
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Text(
                      '沙盒 · 第 ${_pageIndex + 1} / ${_questions.length} 题',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
