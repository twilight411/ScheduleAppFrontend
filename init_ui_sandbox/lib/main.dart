import 'package:flutter/material.dart';

import 'app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 若曾把根组件在 StatefulWidget ↔ StatelessWidget 之间改过，
  // 必须 Hot Restart（或重跑），勿仅用 Hot Reload，否则会报 _InitSandboxAppState 类型错误。
  runApp(const InitSandboxApp());
}
