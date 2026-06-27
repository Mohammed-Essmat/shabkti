import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/providers/auth_provider.dart';
import 'package:shabakti/providers/language_provider.dart';
import 'package:shabakti/providers/theme_provider.dart';
import 'package:shabakti/widgets/shabakti_app_bar.dart';
import 'package:shabakti/screens/login_screen.dart';
import 'package:shabakti/screens/profile/edit_profile_screen.dart';
import 'package:shabakti/screens/profile/change_password_screen.dart';
import 'package:shabakti/screens/beneficiaries/beneficiaries_screen.dart';
import 'package:shabakti/screens/history/subscription_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final lang = context.watch<LanguageProvider>();
    final s = lang.strings;
    final user = auth.user;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: ShabaktiAppBar(pageTitle: s.myAccount),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [colors.primary.withValues(alpha: 0.08), colors.primary.withValues(alpha: 0.02)], begin: Alignment.topRight, end: Alignment.bottomLeft),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
              ),
              child: Column(children: [
                Stack(children: [
                  CircleAvatar(
                    radius: 40, backgroundColor: colors.primaryContainer,
                    backgroundImage: user?.profilePictureUrl != null ? NetworkImage(user!.profilePictureUrl!) : null,
                    child: user?.profilePictureUrl == null ? Icon(Iconsax.user, size: 36, color: colors.onPrimary) : null,
                  ),
                  Positioned(bottom: 0, left: 0, child: Container(
                    padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                    child: Icon(Iconsax.camera, size: 14, color: colors.onPrimary),
                  )),
                ]),
                const SizedBox(height: 14),
                Text(user?.name ?? '', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(user?.isBeneficiary == true ? s.beneficiary : s.user,
                      style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                ),
              ]),
            ),
            const SizedBox(height: 24),

            Card(child: Column(children: [
              _tile(context, Iconsax.edit_2, s.editProfile, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
              Divider(color: colors.outlineVariant.withValues(alpha: 0.3), height: 1),
              _tile(context, Iconsax.lock, s.changePassword, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()))),
              Divider(color: colors.outlineVariant.withValues(alpha: 0.3), height: 1),
              _tile(context, Iconsax.people, s.beneficiaries, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BeneficiariesScreen()))),
              Divider(color: colors.outlineVariant.withValues(alpha: 0.3), height: 1),
              _tile(context, Iconsax.receipt_1, s.subscriptionHistory, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionHistoryScreen()))),
            ])),
            const SizedBox(height: 12),

            Card(child: Column(children: [
              _tile(context, theme.modeIcon, theme.modeLabelFor(s.isArabic), () => theme.toggleTheme()),
              Divider(color: colors.outlineVariant.withValues(alpha: 0.3), height: 1),
              _tile(context, lang.languageIcon, lang.languageLabel, () => lang.toggleLanguage()),
              Divider(color: colors.outlineVariant.withValues(alpha: 0.3), height: 1),
              _tile(context, Iconsax.trash, s.deleteAccount, () => _confirmDelete(context, s), isDestructive: true),
            ])),
            const SizedBox(height: 20),

            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: () async {
                await auth.logout();
                if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
              },
              icon: const Icon(Iconsax.logout, size: 20),
              label: Text(s.logout),
            )),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? Theme.of(context).colorScheme.error : null;
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(title, style: TextStyle(color: color, fontSize: 15)),
      trailing: Icon(Iconsax.arrow_left_2, size: 16, color: color ?? Theme.of(context).colorScheme.outline),
      onTap: onTap, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }

  void _confirmDelete(BuildContext context, dynamic s) {
    final colors = Theme.of(context).colorScheme;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      icon: Icon(Iconsax.warning_2, color: colors.error, size: 40),
      title: Text(s.deleteAccount),
      content: Text(s.isArabic ? 'هل أنت متأكد من حذف حسابك؟\nلا يمكن التراجع عن هذا الإجراء' : 'Are you sure you want to delete your account?\nThis action cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.isArabic ? 'إلغاء' : 'Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: colors.error, minimumSize: const Size(0, 44)),
          onPressed: () async {
            Navigator.pop(ctx);
            await context.read<AuthProvider>().logout();
            if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
          },
          child: Text(s.isArabic ? 'حذف' : 'Delete'),
        ),
      ],
    ));
  }
}
