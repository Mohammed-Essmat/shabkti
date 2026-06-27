import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/providers/language_provider.dart';
import 'package:shabakti/services/user_service.dart';
import 'package:shabakti/widgets/custom_button.dart';
import 'package:shabakti/widgets/custom_text_field.dart';
import 'package:shabakti/widgets/shabakti_app_bar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() { _currentController.dispose(); _newController.dispose(); _confirmController.dispose(); super.dispose(); }

  int get _strengthLevel {
    final p = _newController.text;
    if (p.length < 6) return 0;
    int score = 1;
    if (p.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[0-9]').hasMatch(p)) score++;
    return score;
  }

  Color get _strengthColor => switch (_strengthLevel) {
    0 => Colors.grey, 1 => Colors.red, 2 => Colors.orange, _ => const Color(0xFF22C55E),
  };

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      await context.read<UserService>().changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
        confirmPassword: _confirmController.text,
      );
      if (mounted) {
        final s = context.read<LanguageProvider>().strings;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(s.isArabic ? 'تم تغيير كلمة السر' : 'Password changed'),
          backgroundColor: const Color(0xFF22C55E),
        ));
        Navigator.pop(context);
      }
    } catch (_) {
      final s = context.read<LanguageProvider>().strings;
      setState(() => _error = s.isArabic ? 'كلمة السر الحالية غير صحيحة' : 'Current password is incorrect');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LanguageProvider>().strings;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: ShabaktiAppBar(pageTitle: s.changePassword, showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                hint: s.isArabic ? 'كلمة السر الحالية' : 'Current Password',
                controller: _currentController, isPassword: true, prefixIcon: Iconsax.lock,
                validator: (v) => v == null || v.isEmpty ? s.required : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hint: s.isArabic ? 'كلمة السر الجديدة' : 'New Password',
                controller: _newController, isPassword: true, prefixIcon: Iconsax.lock,
                validator: (v) => v == null || v.length < 6 ? (s.isArabic ? '6 أحرف على الأقل' : 'At least 6 characters') : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hint: s.confirmPassword,
                controller: _confirmController, isPassword: true, prefixIcon: Iconsax.lock_1,
                validator: (v) {
                  if (v == null || v.isEmpty) return s.required;
                  if (v != _newController.text) return s.isArabic ? 'كلمة السر غير متطابقة' : 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListenableBuilder(
                listenable: _newController,
                builder: (context, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(value: _strengthLevel / 3, backgroundColor: colors.outlineVariant.withValues(alpha: 0.3), color: _strengthColor, minHeight: 6),
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      Icon(_strengthLevel >= 3 ? Iconsax.shield_tick : Iconsax.shield, size: 16, color: _strengthColor),
                      const SizedBox(width: 6),
                      Text(s.strengthLabel(_strengthLevel), style: TextStyle(color: _strengthColor, fontSize: 13, fontWeight: FontWeight.w500)),
                    ]),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: colors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    Icon(Iconsax.warning_2, size: 18, color: colors.error), const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: TextStyle(color: colors.error, fontSize: 13))),
                  ]),
                ),
              ],
              const SizedBox(height: 32),
              CustomButton(text: s.isArabic ? 'حفظ' : 'Save', onPressed: _save, isLoading: _isLoading),
            ],
          ),
        ),
      ),
    );
  }
}
