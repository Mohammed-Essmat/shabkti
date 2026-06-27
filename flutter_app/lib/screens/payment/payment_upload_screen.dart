import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/models/package.dart';
import 'package:shabakti/providers/language_provider.dart';
import 'package:shabakti/providers/subscription_provider.dart';
import 'package:shabakti/widgets/shabakti_app_bar.dart';
import 'package:shabakti/screens/payment/payment_success_screen.dart';

class PaymentUploadScreen extends StatefulWidget {
  final String subscriptionId;
  final String paymentMethod;
  final InternetPackage package;

  const PaymentUploadScreen({
    super.key,
    required this.subscriptionId,
    required this.paymentMethod,
    required this.package,
  });

  @override
  State<PaymentUploadScreen> createState() => _PaymentUploadScreenState();
}

class _PaymentUploadScreenState extends State<PaymentUploadScreen> {
  File? _image;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _submit() async {
    if (_image == null) return;
    final sub = context.read<SubscriptionProvider>();
    final success = await sub.uploadPayment(
      subscriptionId: widget.subscriptionId,
      filePath: _image!.path,
      paymentMethod: widget.paymentMethod,
    );
    if (success && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(package: widget.package),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final sub = context.watch<SubscriptionProvider>();
    final s = context.watch<LanguageProvider>().strings;
    final methodLabel = widget.paymentMethod == 'vodafone_cash' ? (s.isArabic ? 'فودافون كاش' : 'Vodafone Cash') : 'Instapay';

    return Scaffold(
      appBar: ShabaktiAppBar(pageTitle: s.uploadProof, showBack: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.paymentMethod == 'vodafone_cash' ? Iconsax.mobile : Iconsax.bank,
                    size: 16, color: colors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(methodLabel, style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _image == null ? _buildUploadZone(context) : _buildPreview(context),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton.icon(
            onPressed: _image != null && !sub.isLoading ? _submit : null,
            icon: sub.isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Iconsax.tick_circle, size: 20),
            label: Text(sub.isLoading ? (s.isArabic ? 'جاري الرفع...' : 'Uploading...') : s.confirmPayment),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadZone(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isAr = context.read<LanguageProvider>().isArabic;
    return GestureDetector(
      onTap: () => _showPickerOptions(context),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.outlineVariant, width: 1.5, strokeAlign: BorderSide.strokeAlignCenter),
          color: colors.surfaceContainerHighest.withValues(alpha: 0.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.document_upload, size: 40, color: colors.primary),
            ),
            const SizedBox(height: 16),
            Text(isAr ? 'اضغط لاختيار صورة الإيصال' : 'Tap to select receipt image',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colors.outline)),
            const SizedBox(height: 6),
            Text('JPG, PNG', style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Iconsax.camera, color: Theme.of(context).colorScheme.primary),
                ),
                title: const Text('الكاميرا'),
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Iconsax.gallery, color: Theme.of(context).colorScheme.primary),
                ),
                title: const Text('المعرض'),
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.file(_image!, fit: BoxFit.contain, width: double.infinity),
          ),
        ),
        const SizedBox(height: 14),
        TextButton.icon(
          onPressed: () => setState(() => _image = null),
          icon: Icon(Iconsax.close_circle, color: colors.error, size: 20),
          label: Text('إزالة الصورة', style: TextStyle(color: colors.error)),
        ),
      ],
    );
  }
}
