import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/providers/language_provider.dart';
import 'package:shabakti/services/auth_service.dart';
import 'package:shabakti/widgets/custom_button.dart';
import 'package:shabakti/widgets/custom_text_field.dart';
import 'package:shabakti/widgets/shabakti_app_bar.dart';
import 'package:shabakti/screens/forgot_password/forgot_otp_screen.dart';

class ForgotEmailScreen extends StatefulWidget {
  const ForgotEmailScreen({super.key});

  @override
  State<ForgotEmailScreen> createState() => _ForgotEmailScreenState();
}

class _ForgotEmailScreenState extends State<ForgotEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final authService = context.read<AuthService>();
      await authService.forgotPassword(email: _emailController.text.trim());
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ForgotOtpScreen(email: _emailController.text.trim()),
        ));
      }
    } on DioException catch (_) {
      final s = context.read<LanguageProvider>().strings;
      setState(() => _error = s.isArabic ? 'حدث خطأ، حاول مرة أخرى' : 'An error occurred, try again');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = context.watch<LanguageProvider>().strings;

    return Scaffold(
      appBar: ShabaktiAppBar(pageTitle: s.forgotPassword, showBack: true),
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
                  child: Icon(Iconsax.lock_1, size: 36, color: colors.primary),
                ),
                const SizedBox(height: 24),
                Text(s.forgotPassword, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(s.isArabic ? 'أدخل بريدك الإلكتروني وهنبعتلك كود التحقق' : 'Enter your email and we will send you a verification code',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 32),
                CustomTextField(
                  hint: s.email,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Iconsax.sms,
                  validator: (v) => v == null || !v.contains('@') ? 'بريد غير صحيح' : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.warning_2, size: 18, color: colors.error),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!, style: TextStyle(color: colors.error, fontSize: 13))),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                CustomButton(text: s.sendOtp, onPressed: _submit, isLoading: _isLoading, icon: Iconsax.send_1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
