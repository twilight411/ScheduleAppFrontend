import 'package:flutter/material.dart';

import '../pages/onboarding/onboarding_v1_sandbox_flow_page.dart';

/// 迁移前占位：表示「初始化结束」。主工程里应进入真实首页或登录流。
class DonePlaceholderScreen extends StatelessWidget {
  const DonePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('沙盒结束')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              Text(
                '这里代表初始化完成',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '迁主工程时删除本屏，改为 Navigator 进 MainContainerView 等。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () {
                  // 必须用本页 context，避免上一页已 dispose
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => const OnboardingV1SandboxFlowPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.replay),
                label: const Text('再跑一遍流程（调试用）'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
