import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/main_container_view.dart';
import 'pages/basic_info/basic_info_flow_page.dart' show BasicInfoFlowPage, kBasicInfoDoneKey;
import 'pages/login_register/login_flow_page.dart' show LoginFlowPage, kLoginDoneKey;
import 'pages/onboarding/onboarding_flow_page.dart' show OnboardingFlowPage, OnboardingPhase;
import 'pages/onboarding/onboarding_v1_flow_page.dart' show kOnboardingV1DoneKey;
import 'pages/onboarding/onboarding_v2_flow_page.dart' show kOnboardingV2DoneKey;
import 'providers/chat_provider.dart';
import 'providers/plant_provider.dart';
import 'providers/task_provider.dart';
import 'providers/wish_provider.dart';
import 'repositories/local_plant_repository.dart';
import 'repositories/remote_ai_chat_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化日期格式化（中文）
  await initializeDateFormatting('zh_CN', null);

  runApp(const MyApp());
}

/// 获取初始化流程状态：V1 -> V2 -> 03 基本信息 -> 04 登录注册 -> 主界面
/// 调试模式下强制从 V1 开始，方便反复查看
Future<({bool v1Done, bool v2Done, bool basicInfoDone, bool loginDone})> getOnboardingStatus() async {
  if (kDebugMode) {
    return (v1Done: false, v2Done: false, basicInfoDone: false, loginDone: false);
  }
  final prefs = await SharedPreferences.getInstance();
  final v1 = prefs.getBool(kOnboardingV1DoneKey) ?? false;
  final v2 = prefs.getBool(kOnboardingV2DoneKey) ?? false;
  final basicInfo = prefs.getBool(kBasicInfoDoneKey) ?? false;
  final login = prefs.getBool(kLoginDoneKey) ?? false;
  return (v1Done: v1, v2Done: v2, basicInfoDone: basicInfo, loginDone: login);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TaskProvider>(
          create: (_) => TaskProvider(),
        ),
        ChangeNotifierProvider<WishProvider>(
          create: (_) => WishProvider(),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (context) => ChatProvider(
            repository: RemoteAIChatRepository(),
            taskProvider: context.read<TaskProvider>(),
          ),
        ),
        ChangeNotifierProvider<PlantProvider>(
          create: (_) => PlantProvider(
            repository: LocalPlantRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Schedule App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: FutureBuilder<({bool v1Done, bool v2Done, bool basicInfoDone, bool loginDone})>(
          future: getOnboardingStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final status = snapshot.data ??
                  (v1Done: false, v2Done: false, basicInfoDone: false, loginDone: false);
              if (!status.v2Done) {
                return OnboardingFlowPage(
                  initialPhase: status.v1Done
                      ? OnboardingPhase.v2
                      : OnboardingPhase.v1,
                );
              }
              if (!status.basicInfoDone) {
                return const BasicInfoFlowPage();
              }
              if (!status.loginDone) {
                return const LoginFlowPage();
              }
              return const MainContainerView();
            }
            return const Scaffold(
              backgroundColor: Color(0xFF4A7C4E),
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}

