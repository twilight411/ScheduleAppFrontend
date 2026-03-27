import 'package:flutter/material.dart';

import 'pages/onboarding/onboarding_v1_sandbox_flow_page.dart';
import 'theme/app_theme.dart';

/// 入口：直接跑主工程同源的 V1 三题引导（资源与页面从 schedule_app_flutter 拷贝）。
class InitSandboxApp extends StatelessWidget {
  const InitSandboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Init UI Sandbox',
      theme: AppTheme.light(),
      home: const OnboardingV1SandboxFlowPage(),
    );
  }
}
