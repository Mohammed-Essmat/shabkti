import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/providers/language_provider.dart';
import 'package:shabakti/services/auth_service.dart';
import 'package:shabakti/widgets/custom_button.dart';
import 'package:shabakti/widgets/shabakti_app_bar.dart';
import 'package:shabakti/screens/forgot_password/reset_password_screen.dart';

class ForgotOtpScreen extends StatefulWidget {
  final String email;
  const ForgotOtpScreen({super.key, required this.email});

  @override
  State<ForgotOtpScreen> createState() => _ForgotOtpScreenState();
}

class _ForgotOtpScreenState extends State<ForgotOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _countdown = 150;
  Timer? _timer;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _countdown = 150;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 0) { t.cancel(); return; }
      setState(() => _countdown--);
    });
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  String get _timerText {
    final m = (_countdown ~/ 60).toString().padLeft(2, '0');
    final s = (_countdown % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _verify() async {
    if (_otpCode.length != 6) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final authService = context.read<AuthService>();
      await authService.verifyOtp(identifier: widget.email, code: _otpCode);
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: widget.email),
        ));
      }
    } on DioException catch (e) {
      final detail = e.response?.data;
      setState(() => _error = detail is Map ? detail['detail'] : 'كود غير صحيح');
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = context.watch<LanguageProvider>().strings;

    return Scaffold(
      appBar: ShabaktiAppBar(pageTitle: s.otpTitle, showBack: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(s.otpTitle, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(s.otpSent, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(widget.email, style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 36),

              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (i) => SizedBox(
                    width: 48,
                    height: 56,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        filled: true,
                        fillColor: _controllers[i].text.isNotEmpty ? colors.primary.withValues(alpha: 0.06) : null,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: colors.outlineVariant)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: _controllers[i].text.isNotEmpty ? colors.primary : colors.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: colors.primary, width: 2)),
                      ),
                      onChanged: (v) {
                        setState(() {});
                        if (v.isNotEmpty && i < 5) _focusNodes[i + 1].requestFocus();
                        else if (v.isEmpty && i > 0) _focusNodes[i - 1].requestFocus();
                      },
                    ),
                  )),
                ),
              ),

              const SizedBox(height: 28),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.timer_1, size: 16, color: colors.outline),
                      const SizedBox(width: 6),
                      Text(_timerText, style: TextStyle(color: colors.outline, fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: colors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Icon(Iconsax.warning_2, size: 18, color: colors.error),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: TextStyle(color: colors.error, fontSize: 13))),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              CustomButton(
                text: 'تأكيد الكود',
                onPressed: _otpCode.length == 6 ? _verify : null,
                isLoading: _isLoading,
                icon: Iconsax.shield_tick,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _countdown <= 0 ? () async {
                    final authService = context.read<AuthService>();
                    await authService.forgotPassword(email: widget.email);
                    _startTimer();
                  } : null,
                  child: Text(
                    'لم يصلك الكود؟ إعادة الإرسال',
                    style: TextStyle(
                      color: _countdown <= 0 ? colors.primary : colors.outline,
                      fontWeight: _countdown <= 0 ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
