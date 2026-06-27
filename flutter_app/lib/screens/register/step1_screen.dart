import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/providers/auth_provider.dart';
import 'package:shabakti/providers/language_provider.dart';
import 'package:shabakti/widgets/custom_button.dart';
import 'package:shabakti/widgets/custom_text_field.dart';
import 'package:shabakti/widgets/shabakti_app_bar.dart';
import 'package:shabakti/screens/register/step2_otp_screen.dart';

class Step1Screen extends StatefulWidget {
  const Step1Screen({super.key});
  @override
  State<Step1Screen> createState() => _Step1ScreenState();
}

class _Step1ScreenState extends State<Step1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() { _nameController.dispose(); _phoneController.dispose(); _emailController.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.register(name: _nameController.text.trim(), email: _emailController.text.trim(), phone: '+2${_phoneController.text.trim()}');
    if (success && mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const Step2OtpScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final s = context.watch<LanguageProvider>().strings;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const ShabaktiAppBar(showBack: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _StepBar(currentStep: 1, s: s),
              const SizedBox(height: 24),
              Text(s.personalInfo, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(s.personalInfoSub, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 28),
              CustomTextField(hint: s.fullName, controller: _nameController, prefixIcon: Iconsax.user,
                  validator: (v) => v == null || v.length < 2 ? (s.isArabic ? 'الاسم لازم حرفين على الأقل' : 'Name must be at least 2 characters') : null),
              const SizedBox(height: 14),
              CustomTextField(hint: s.phone, controller: _phoneController, keyboardType: TextInputType.phone, prefixIcon: Iconsax.call,
                  validator: (v) => v == null || v.length < 10 ? (s.isArabic ? 'رقم غير صحيح' : 'Invalid phone number') : null),
              const SizedBox(height: 14),
              CustomTextField(hint: s.email, controller: _emailController, keyboardType: TextInputType.emailAddress, prefixIcon: Iconsax.sms,
                  validator: (v) => v == null || !v.contains('@') ? (s.isArabic ? 'بريد غير صحيح' : 'Invalid email') : null),
              if (auth.error != null) ...[
                const SizedBox(height: 14),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: colors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [Icon(Iconsax.warning_2, size: 18, color: colors.error), const SizedBox(width: 8),
                    Expanded(child: Text(auth.error!, style: TextStyle(color: colors.error, fontSize: 13)))])),
              ],
              const SizedBox(height: 28),
              CustomButton(text: s.sendOtp, onPressed: _submit, isLoading: auth.isLoading, icon: Iconsax.send_1),
              const SizedBox(height: 16),
              Center(child: TextButton(onPressed: () => Navigator.pop(context), child: Text(s.haveAccount))),
            ]),
          ),
        ),
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  final int currentStep;
  final dynamic s;
  const _StepBar({required this.currentStep, required this.s});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: List.generate(3, (i) => Expanded(child: Container(
        height: 4, margin: EdgeInsets.only(left: i > 0 ? 6 : 0),
        decoration: BoxDecoration(color: i < currentStep ? colors.primary : colors.outlineVariant.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)),
      )))),
      const SizedBox(height: 10),
      Text(s.stepOf(currentStep), style: Theme.of(context).textTheme.labelMedium),
    ]);
  }
}
