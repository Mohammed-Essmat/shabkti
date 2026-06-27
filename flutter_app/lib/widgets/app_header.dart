import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/providers/auth_provider.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback? onProfileTap;

  const AppHeader({super.key, this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Image.asset('assets/images/SHABAKTI LOGO.png', width: 32, height: 32),
        const SizedBox(width: 8),
        Text('شبكتي', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const Spacer(),
        GestureDetector(
          onTap: onProfileTap,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: colors.primaryContainer,
            backgroundImage: auth.user?.profilePictureUrl != null
                ? NetworkImage(auth.user!.profilePictureUrl!)
                : null,
            child: auth.user?.profilePictureUrl == null
                ? Icon(Iconsax.user, size: 18, color: colors.onPrimary)
                : null,
          ),
        ),
      ],
    );
  }
}
