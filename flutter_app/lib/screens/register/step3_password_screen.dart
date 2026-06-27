import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/providers/auth_provider.dart';
import 'package:shabakti/providers/language_provider.dart';
import 'package:shabakti/widgets/custom_button.dart';
import 'package:shabakti/widgets/custom_text_field.dart';
import 'package:shabakti/widgets/shabakti_app_bar.dart';
import 'package:shabakti/screens/login_screen.dart';

class Step3PasswordScreen extends StatefulWidget {
  const Step3PasswordScreen({super.key});
  @override
  State<Step3PasswordScreen> createState() => _Step3PasswordScreenState();
}

class _Step3PasswordScreenState extends State<Step3PasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() { _passwordController.dispose(); _confirmController.dispose(); super.dispose(); }

  int get _strengthLevel {
    final p = _passwordController.text;
    if (p.length < 6) return 0;
    int score = 1;
    if (p.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[0-9]').hasMatch(p)) score++;
    return score;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final s = context.read<LanguageProvider>().strings;
    final success = await auth.setPassword(password: _passwordController.text, confirmPassword: _confirmController.text);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [const Icon(Iconsax.tick_circle, color: Colors.white, size: 20), const SizedBox(width: 8), Text(s.accountCreated)]),
        backgroundColor: const Color(0xFF22C55E),
      ));
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final s = context.watch<LanguageProvider>().strings;
    final colors = Theme.of(context).colorScheme;
    final strengthColor = _strengthLevel <= 1 ? Colors.red : _strengthLevel == 2 ? Colors.orange : const Color(0xFF22C55E);

    return Scaffold(
      appBar: const ShabaktiAppBar(showBack: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _stepBar(3, s, context),
              const SizedBox(height: 24),
              Text(s.createPassword, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(s.createPasswordSub, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 28),
              CustomTextField(hint: s.password, controller: _passwordController, isPassword: true, prefixIcon: Iconsax.lock,
                  validator: (v) => v == null || v.length < 6 ? (s.isArabic ? '6 أحرف على الأقل' : 'At least 6 characters') : null),
              const SizedBox(height: 14),
              CustomTextField(hint: s.confirmPassword, controller: _confirmController, isPassword: true, prefixIcon: Iconsax.lock_1,
                  validator: (v) { if (v == null || v.isEmpty) return s.required; if (v != _passwordController.text) return s.isArabic ? 'كلمة السر غير متطابقة' : 'Passwords do not match'; return null; }),
              const SizedBox(height: 18),
              ListenableBuilder(listenable: _passwordController, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: _strengthLevel / 3, backgroundColor: colors.outlineVariant.withValues(alpha: 0.3), color: strengthColor, minHeight: 6)),
                const SizedBox(height: 8),
                Row(children: [Icon(_strengthLevel >= 3 ? Iconsax.shield_tick : Iconsax.shield, size: 16, color: strengthColor), const SizedBox(width: 6),
                  Text(s.strengthLabel(_strengthLevel), style: TextStyle(color: strengthColor, fontSize: 13, fontWeight: FontWeight.w500))]),
              ])),
              if (auth.error != null) ...[const SizedBox(height: 14),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: colors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [Icon(Iconsax.warning_2, size: 18, color: colors.error), const SizedBox(width: 8),
                    Expanded(child: Text(auth.error!, style: TextStyle(color: colors.error, fontSize: 13)))]))],
              const SizedBox(height: 32),
              CustomButton(text: s.createAccountBtn, onPressed: _submit, isLoading: auth.isLoading, icon: Iconsax.user_tick),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _stepBar(int step, dynamic s, BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: List.generate(3, (i) => Expanded(child: Container(height: 4, margin: EdgeInsets.only(left: i > 0 ? 6 : 0),
        decoration: BoxDecoration(color: i < step ? colors.primary : colors.outlineVariant.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)))))),
      const SizedBox(height: 10), Text(s.stepOf(step), style: Theme.of(context).textTheme.labelMedium),
    ]);
  }
}
