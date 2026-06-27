import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/providers/language_provider.dart';
import 'package:shabakti/services/auth_service.dart';
import 'package:shabakti/widgets/custom_button.dart';
import 'package:shabakti/widgets/custom_text_field.dart';
import 'package:shabakti/widgets/shabakti_app_bar.dart';
import 'package:shabakti/screens/login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _isDone = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  int get _strengthLevel {
    final p = _passwordController.text;
    if (p.length < 6) return 0;
    int score = 1;
    if (p.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[0-9]').hasMatch(p)) score++;
    return score;
  }

  Color get _strengthColor => switch (_strengthLevel) {
    0 => Colors.grey, 1 => Colors.red, 2 => Colors.orange, _ => const Color(0xFF22C55E),
  };

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final authService = context.read<AuthService>();
      await authService.resetPassword(
        identifier: widget.email,
        password: _passwordController.text,
        confirmPassword: _confirmController.text,
      );
      setState(() => _isDone = true);
    } on DioException catch (e) {
      final detail = e.response?.data;
      setState(() => _error = detail is Map ? detail['detail'] : 'حدث خطأ');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = context.watch<LanguageProvider>().strings;

    if (_isDone) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  builder: (_, v, child) => Transform.scale(scale: v, child: child),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF16A34A)]),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: const Color(0xFF22C55E).withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8))],
                    ),
                    child: const Icon(Iconsax.tick_circle, color: Colors.white, size: 50),
                  ),
                ),
                const SizedBox(height: 28),
                Text(s.isArabic ? 'تم تغيير كلمة السر بنجاح!' : 'Password changed successfully!', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(s.isArabic ? 'يمكنك الآن تسجيل الدخول بكلمة السر الجديدة' : 'You can now login with your new password', style: Theme.of(context).textTheme.bodyMedium),
                const Spacer(flex: 2),
                CustomButton(
                  text: s.login,
                  icon: Iconsax.login,
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: ShabaktiAppBar(pageTitle: s.isArabic ? 'كلمة سر جديدة' : 'New Password', showBack: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.key, size: 36, color: colors.primary),
                ),
                const SizedBox(height: 24),
                Text(s.isArabic ? 'كلمة سر جديدة' : 'New Password', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(s.isArabic ? 'أدخل كلمة السر الجديدة لحسابك' : 'Enter your new password', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 32),
                CustomTextField(
                  hint: s.password,
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Iconsax.lock,
                  validator: (v) => v == null || v.length < 6 ? (s.isArabic ? '6 أحرف على الأقل' : 'At least 6 characters') : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  hint: s.confirmPassword,
                  controller: _confirmController,
                  isPassword: true,
                  prefixIcon: Iconsax.lock_1,
                  validator: (v) {
                    if (v == null || v.isEmpty) return s.required;
                    if (v != _passwordController.text) return s.isArabic ? 'كلمة السر غير متطابقة' : 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                ListenableBuilder(
                  listenable: _passwordController,
                  builder: (context, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: _strengthLevel / 3,
                          backgroundColor: colors.outlineVariant.withValues(alpha: 0.3),
                          color: _strengthColor,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(_strengthLevel >= 3 ? Iconsax.shield_tick : Iconsax.shield, size: 16, color: _strengthColor),
                          const SizedBox(width: 6),
                          Text(s.strengthLabel(_strengthLevel), style: TextStyle(color: _strengthColor, fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
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
                const SizedBox(height: 32),
                CustomButton(text: s.isArabic ? 'حفظ كلمة السر' : 'Save Password', onPressed: _submit, isLoading: _isLoading, icon: Iconsax.tick_circle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
