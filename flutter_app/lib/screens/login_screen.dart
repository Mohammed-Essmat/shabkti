import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/providers/auth_provider.dart';
import 'package:shabakti/providers/language_provider.dart';
import 'package:shabakti/widgets/custom_button.dart';
import 'package:shabakti/widgets/custom_text_field.dart';
import 'package:shabakti/screens/register/step1_screen.dart';
import 'package:shabakti/screens/home_screen.dart';
import 'package:shabakti/screens/forgot_password/forgot_email_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() { _emailController.dispose(); _passwordController.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(email: _emailController.text.trim(), password: _passwordController.text);
    if (success && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final s = context.watch<LanguageProvider>().strings;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
                  child: Image.asset('assets/images/SHABAKTI LOGO.png', width: 64, height: 64),
                ),
                const SizedBox(height: 16),
                Text(s.appName, style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 6),
                Text(s.loginSubtitle, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 40),
                CustomTextField(
                  hint: s.email, controller: _emailController,
                  keyboardType: TextInputType.emailAddress, prefixIcon: Iconsax.sms,
                  validator: (v) => v == null || v.isEmpty ? s.required : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  hint: s.password, controller: _passwordController,
                  isPassword: true, prefixIcon: Iconsax.lock,
                  validator: (v) => v == null || v.isEmpty ? s.required : null,
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotEmailScreen())),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 36)),
                    child: Text(s.forgotPassword, style: TextStyle(color: colors.primary, fontSize: 13)),
                  ),
                ),
                if (auth.error != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(color: colors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                    child: Row(children: [
                      Icon(Iconsax.warning_2, size: 18, color: colors.error), const SizedBox(width: 8),
                      Expanded(child: Text(auth.error!, style: TextStyle(color: colors.error, fontSize: 13))),
                    ]),
                  ),
                ],
                const SizedBox(height: 20),
                CustomButton(text: s.login, onPressed: _login, isLoading: auth.isLoading),
                const SizedBox(height: 28),
                Row(children: [
                  Expanded(child: Divider(color: colors.outlineVariant)),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(s.or, style: Theme.of(context).textTheme.labelMedium)),
                  Expanded(child: Divider(color: colors.outlineVariant)),
                ]),
                const SizedBox(height: 20),
                CustomButton(
                  text: s.createAccount, isOutlined: true, icon: Iconsax.user_add,
                  onPressed: () { auth.clearError(); Navigator.push(context, MaterialPageRoute(builder: (_) => const Step1Screen())); },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
