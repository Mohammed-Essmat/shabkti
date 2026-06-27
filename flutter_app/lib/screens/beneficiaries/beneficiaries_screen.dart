import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/models/user.dart';
import 'package:shabakti/providers/language_provider.dart';
import 'package:shabakti/services/beneficiary_service.dart';
import 'package:shabakti/widgets/shabakti_app_bar.dart';
import 'package:shabakti/screens/beneficiaries/add_beneficiary_sheet.dart';

class BeneficiariesScreen extends StatefulWidget {
  const BeneficiariesScreen({super.key});

  @override
  State<BeneficiariesScreen> createState() => _BeneficiariesScreenState();
}

class _BeneficiariesScreenState extends State<BeneficiariesScreen> {
  List<User> _beneficiaries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final service = context.read<BeneficiaryService>();
      _beneficiaries = await service.getBeneficiaries();
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _delete(User ben) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.warning_rounded, color: Theme.of(context).colorScheme.error, size: 40),
        title: const Text('حذف مستفيد'),
        content: Text('هل تريد حذف ${ben.name}؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await context.read<BeneficiaryService>().deleteBeneficiary(ben.id);
        _load();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحذف'), backgroundColor: Color(0xFF22C55E)));
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final s = context.watch<LanguageProvider>().strings;

    return Scaffold(
      appBar: ShabaktiAppBar(pageTitle: '${s.beneficiaries} (${_beneficiaries.length})', showBack: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _beneficiaries.isEmpty
              ? _buildEmpty(context)
              : _buildList(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            builder: (_) => const AddBeneficiarySheet(),
          );
          if (added == true) _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final isAr = context.read<LanguageProvider>().isArabic;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.people, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(isAr ? 'لا يوجد مستفيدون' : 'No beneficiaries', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(isAr ? 'أضف مستفيد لمشاركة باقتك' : 'Add a beneficiary to share your plan', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: colors.primary, size: 20),
              const SizedBox(width: 8),
              Text(context.read<LanguageProvider>().isArabic ? 'يشاركون نفس بيانات باقتك النشطة' : 'They share your active plan data',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _beneficiaries.length,
            itemBuilder: (_, i) => _card(context, _beneficiaries[i]),
          ),
        ),
      ],
    );
  }

  Widget _card(BuildContext context, User ben) {
    final colors = Theme.of(context).colorScheme;
    final initials = ben.name.split(' ').take(2).map((w) => w.isNotEmpty ? w[0] : '').join();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: colors.primaryContainer,
              child: Text(initials, style: TextStyle(color: colors.onPrimary, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ben.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                  Text(ben.email, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            IconButton(icon: Icon(Icons.delete_outline, color: colors.error), onPressed: () => _delete(ben)),
          ],
        ),
      ),
    );
  }
}
