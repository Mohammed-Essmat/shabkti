import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/services/beneficiary_service.dart';
import 'package:shabakti/widgets/custom_button.dart';
import 'package:shabakti/widgets/custom_text_field.dart';

class AddBeneficiarySheet extends StatefulWidget {
  const AddBeneficiarySheet({super.key});

  @override
  State<AddBeneficiarySheet> createState() => _AddBeneficiarySheetState();
}

class _AddBeneficiarySheetState extends State<AddBeneficiarySheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      await context.read<BeneficiaryService>().addBeneficiary(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: '+2${_phoneController.text.trim()}',
        password: _passwordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت الإضافة'), backgroundColor: Color(0xFF22C55E)),
        );
        Navigator.pop(context, true);
      }
    } catch (_) {
      setState(() => _error = 'فشل في الإضافة — تأكد من البيانات');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text('إضافة مستفيد', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              CustomTextField(
                hint: 'الاسم الكامل',
                controller: _nameController,
                prefixIcon: Icons.person_outlined,
                validator: (v) => v == null || v.length < 2 ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                hint: 'البريد الإلكتروني',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (v) => v == null || !v.contains('@') ? 'بريد غير صحيح' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                hint: 'رقم الهاتف',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (v) => v == null || v.length < 10 ? 'رقم غير صحيح' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                hint: 'كلمة السر',
                controller: _passwordController,
                isPassword: true,
                prefixIcon: Icons.lock_outlined,
                validator: (v) => v == null || v.length < 6 ? '6 أحرف على الأقل' : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 20),
              CustomButton(text: 'إضافة المستفيد', onPressed: _submit, isLoading: _isLoading),
            ],
          ),
        ),
      ),
    );
  }
}
