import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/providers/auth_provider.dart';
import 'package:shabakti/providers/language_provider.dart';
import 'package:shabakti/services/user_service.dart';
import 'package:shabakti/widgets/custom_button.dart';
import 'package:shabakti/widgets/custom_text_field.dart';
import 'package:shabakti/widgets/shabakti_app_bar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController.text = user?.name ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    setState(() => _isLoading = true);
    try {
      final userService = context.read<UserService>();
      final updated = await userService.uploadProfilePicture(picked.path);
      if (mounted) context.read<AuthProvider>().updateUser(updated);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل رفع الصورة')));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final userService = context.read<UserService>();
      final updated = await userService.updateProfile(name: _nameController.text.trim());
      if (mounted) {
        context.read<AuthProvider>().updateUser(updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الحفظ'), backgroundColor: Color(0xFF22C55E)),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: ShabaktiAppBar(pageTitle: context.watch<LanguageProvider>().strings.editProfile, showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickAndUpload,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: colors.primaryContainer,
                    backgroundImage: user?.profilePictureUrl != null ? NetworkImage(user!.profilePictureUrl!) : null,
                    child: user?.profilePictureUrl == null ? Icon(Icons.person, size: 48, color: colors.onPrimary) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                      child: Icon(Icons.camera_alt, size: 18, color: colors.onPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _pickAndUpload, child: const Text('تغيير الصورة')),
            const SizedBox(height: 24),
            CustomTextField(hint: 'الاسم الكامل', controller: _nameController, prefixIcon: Icons.person_outlined),
            const SizedBox(height: 16),
            CustomTextField(hint: user?.email ?? '', readOnly: true, prefixIcon: Icons.email_outlined),
            const SizedBox(height: 16),
            CustomTextField(hint: user?.phone ?? '', readOnly: true, prefixIcon: Icons.phone_outlined),
            const SizedBox(height: 32),
            CustomButton(text: 'حفظ التغييرات', onPressed: _save, isLoading: _isLoading),
          ],
        ),
      ),
    );
  }
}
