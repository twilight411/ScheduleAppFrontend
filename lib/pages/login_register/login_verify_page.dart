import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/font_manager.dart';
import '../../utils/resource_manager.dart';

/// 04 登录注册 - 验证码页：获取验证码、已发送至{phone}、验证码输入、重新发送(60s)、协议
class LoginVerifyPage extends StatefulWidget {
  const LoginVerifyPage({
    super.key,
    required this.phone,
    required this.onVerifySuccess,
    this.onBack,
  });

  final String phone;
  final VoidCallback onVerifySuccess;
  final VoidCallback? onBack;

  @override
  State<LoginVerifyPage> createState() => _LoginVerifyPageState();
}

class _LoginVerifyPageState extends State<LoginVerifyPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _agreed = false;
  int _countdown = 0;
  Timer? _timer;

  static const Color _white = Colors.white;
  static const Color _darkGray = Color(0xFF4A4A4A);
  static const Color _greenBtn = Color(0xFF5A7D5A);
  static const Color _inputBg = Color(0xFFE8F0E8);

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() => _countdown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_countdown > 0) _countdown--;
      });
      if (_countdown <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _onResend() {
    if (_countdown > 0) return;
    _startCountdown();
  }

  void _onSubmit() {
    final code = _codeController.text.trim();
    if (code.length >= 4 && _agreed) {
      widget.onVerifySuccess();
    }
  }

  void _onLoginTap() {
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请先勾选服务条款和隐私协议'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final code = _codeController.text.trim();
    if (code.length < 4) return;
    _onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              ResourceManager.loginRegister.backgroundVerify,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF6B8E6B)),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.onBack != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: _white, size: 22),
                      onPressed: widget.onBack,
                    ),
                  ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    '获取验证码',
                    style: FontManager.customFontWithColor(
                      size: 28,
                      color: _white,
                      weight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    '已发送验证码至${widget.phone}',
                    style: FontManager.customFontWithColor(
                      size: 15,
                      color: _white,
                      weight: FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: TextField(
                    controller: _codeController,
                    onChanged: (_) => setState(() {}),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: '请输入验证码',
                      hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                      counterText: '',
                      filled: true,
                      fillColor: _inputBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: FontManager.customFontWithColor(
                      size: 18,
                      color: _darkGray,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _countdown > 0 ? null : _onResend,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _greenBtn,
                        foregroundColor: _white,
                        disabledBackgroundColor: _greenBtn.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: Text(
                        _countdown > 0 ? '重新发送(${_countdown}s)' : '重新发送',
                        style: FontManager.customFontWithColor(
                          size: 16,
                          color: _white,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _agreed = !_agreed),
                        child: Icon(
                          _agreed ? Icons.check_circle : Icons.radio_button_unchecked,
                          size: 22,
                          color: _white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _agreed = !_agreed),
                          child: Text(
                            '已经阅读并同意服务条款和隐私协议',
                            style: FontManager.customFontWithColor(
                              size: 13,
                              color: _white,
                              weight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _onLoginTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (_codeController.text.trim().length >= 4 && _agreed)
                            ? _greenBtn
                            : _greenBtn.withOpacity(0.6),
                        foregroundColor: _white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: Text(
                        '登录',
                        style: FontManager.customFontWithColor(
                          size: 17,
                          color: _white,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
