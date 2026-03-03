import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_phone_page.dart';
import 'login_verify_page.dart';
import 'login_other_phone_page.dart';
import '../main_container_view.dart';

/// 是否已完成 04 登录注册的本地存储 key
const String kLoginDoneKey = 'login_done';

/// 存储昵称的 key（03 基本信息填写，04 页展示「你好,{昵称}」）
const String kNicknameKey = 'user_nickname';

/// 04 登录注册流程：手机号页 → 验证码页 → 主界面
class LoginFlowPage extends StatefulWidget {
  const LoginFlowPage({super.key});

  @override
  State<LoginFlowPage> createState() => _LoginFlowPageState();
}

class _LoginFlowPageState extends State<LoginFlowPage> {
  static const String _defaultPhone = '13312240306';
  static const String _defaultPhoneMasked = '133****0306';

  bool _onPhonePage = true;
  String _phone = _defaultPhone;
  String _nickname = '';
  bool _agreed = false;

  @override
  void initState() {
    super.initState();
    _loadNickname();
  }

  /// 仅展示合规昵称：单行、长度合理（如 03 填写的昵称），否则展示占位
  static String _sanitizeNickname(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final t = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (t.contains('\n') || t.length > 10) return '';
    return t;
  }

  Future<void> _loadNickname() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kNicknameKey) ?? '';
    if (mounted) setState(() => _nickname = _sanitizeNickname(raw));
  }

  void _goToOneClick() {
    setState(() {
      _phone = _defaultPhone;
      _onPhonePage = false;
    });
  }

  void _goToOtherPhone() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoginOtherPhonePage(
          onVerifySuccess: _onLoginSuccess,
        ),
      ),
    );
  }

  void _backToPhone() {
    setState(() => _onPhonePage = true);
  }

  Future<void> _onLoginSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kLoginDoneKey, true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainContainerView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_onPhonePage) {
      return LoginPhonePage(
        nickname: _nickname,
        defaultPhoneMasked: _defaultPhoneMasked,
        onOneClickLogin: _agreed ? _goToOneClick : () {},
        onOtherPhone: _goToOtherPhone,
        agreed: _agreed,
        onAgreementChanged: (v) => setState(() => _agreed = v),
      );
    }
    return LoginVerifyPage(
      phone: _phone,
      onVerifySuccess: _onLoginSuccess,
      onBack: _backToPhone,
    );
  }
}

// 旧版「其他手机号登录」底部弹窗已废弃，逻辑改为跳转独立页面 LoginOtherPhonePage。
