import 'package:flutter_test/flutter_test.dart';

import 'package:init_ui_sandbox/app_shell.dart';

void main() {
  testWidgets('loads copied V1 onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(const InitSandboxApp());
    await tester.pump();
    // 第一题气泡文案（与 onboarding_v1_data 一致）
    expect(find.textContaining('标准作息'), findsOneWidget);
  });
}
