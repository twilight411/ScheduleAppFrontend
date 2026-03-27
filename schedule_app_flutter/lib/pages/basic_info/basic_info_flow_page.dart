import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'basic_info_identity_page.dart';
import 'basic_info_nickname_page.dart';
import 'basic_info_enter_state_page.dart';
import '../login_register/login_flow_page.dart' show LoginFlowPage, kNicknameKey;

/// 是否已完成 03 基本信息的本地存储 key
const String kBasicInfoDoneKey = 'basic_info_done';

/// 03 基本信息流程：身份页 → 昵称页 → 进入状态页 → 主界面
class BasicInfoFlowPage extends StatefulWidget {
  const BasicInfoFlowPage({super.key});

  @override
  State<BasicInfoFlowPage> createState() => _BasicInfoFlowPageState();
}

class _BasicInfoFlowPageState extends State<BasicInfoFlowPage> {
  int _step = 0; // 0=身份, 1=昵称, 2=进入状态
  int _identityIndex = -1;
  String _nickname = '';

  void _goPrev() {
    if (_step > 0) setState(() => _step--);
  }

  void _goNext() {
    if (_step == 0 && _identityIndex >= 0) {
      setState(() => _step = 1);
    } else if (_step == 1 && _nickname.trim().isNotEmpty) {
      setState(() => _step = 2);
    }
  }

  Future<void> _completeAndGoHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kNicknameKey, _nickname.trim().isEmpty ? '' : _nickname.trim());
    await prefs.setBool(kBasicInfoDoneKey, true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginFlowPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 0) {
      return BasicInfoIdentityPage(
        selectedIndex: _identityIndex,
        // 与引导页一致：点选身份后自动进入昵称页，无需再点右上角箭头
        onSelected: (i) => setState(() {
          _identityIndex = i;
          _step = 1;
        }),
        onNext: _goNext,
        showLeftArrow: false,
        onLeftArrowTap: null,
      );
    }
    if (_step == 1) {
      return BasicInfoNicknamePage(
        nickname: _nickname,
        onNicknameChanged: (t) => setState(() => _nickname = t),
        onNext: _goNext,
        showLeftArrow: true,
        onLeftArrowTap: _goPrev,
      );
    }
    return BasicInfoEnterStatePage(
      nickname: _nickname.trim().isEmpty ? '——' : _nickname.trim(),
      onEnter: _completeAndGoHome,
      showLeftArrow: true,
      onLeftArrowTap: _goPrev,
    );
  }
}
