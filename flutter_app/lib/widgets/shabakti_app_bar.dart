import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/providers/language_provider.dart';

class ShabaktiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? pageTitle;
  final List<Widget>? actions;
  final bool showBack;

  const ShabaktiAppBar({super.key, this.pageTitle, this.actions, this.showBack = false});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final colors = Theme.of(context).colorScheme;

    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            if (showBack)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32),
              ),
            Image.asset('assets/images/SHABAKTI LOGO.png', width: 26, height: 26),
            const SizedBox(width: 6),
            Text(
              lang.strings.appName,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.primary),
            ),
            if (pageTitle != null) ...[
              const SizedBox(width: 8),
              Container(width: 1, height: 20, color: colors.outlineVariant.withValues(alpha: 0.5)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pageTitle!,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: colors.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ] else
              const Spacer(),
            ...?actions,
          ],
        ),
      ),
    );
  }
}
