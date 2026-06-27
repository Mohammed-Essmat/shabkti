import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/models/package.dart';
import 'package:shabakti/models/subscription.dart';
import 'package:shabakti/providers/language_provider.dart';
import 'package:shabakti/widgets/shabakti_app_bar.dart';
import 'package:shabakti/screens/payment/payment_upload_screen.dart';

class PaymentScreen extends StatefulWidget {
  final PaymentInfo paymentInfo;
  final InternetPackage package;

  const PaymentScreen({super.key, required this.paymentInfo, required this.package});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'vodafone_cash';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final s = context.watch<LanguageProvider>().strings;

    return Scaffold(
      appBar: ShabaktiAppBar(pageTitle: s.payment, showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.primary.withValues(alpha: 0.06), colors.primary.withValues(alpha: 0.02)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.package.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.package.dataAmountGb.toStringAsFixed(0)} جيجابايت — ${widget.package.validityDays > 0 ? '${widget.package.validityDays} يوم' : 'فورية'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('المبلغ المطلوب', style: Theme.of(context).textTheme.bodyMedium),
                      Text(
                        '${widget.paymentInfo.amount.toStringAsFixed(2)} ج.م',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('اختر طريقة الدفع', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),

            _methodCard(
              context,
              value: 'vodafone_cash',
              title: 'فودافون كاش',
              subtitle: widget.paymentInfo.vodafoneCashNumber,
              icon: Iconsax.mobile,
            ),
            const SizedBox(height: 10),
            _methodCard(
              context,
              value: 'instapay',
              title: 'Instapay',
              subtitle: widget.paymentInfo.instapayAddress,
              icon: Iconsax.bank,
            ),

            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.info_circle, color: colors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      s.isArabic ? 'حوّل المبلغ على الرقم المحدد واحتفظ بصورة إيصال التحويل' : 'Transfer the amount and keep the receipt screenshot',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => PaymentUploadScreen(
                subscriptionId: widget.paymentInfo.subscriptionId,
                paymentMethod: _selectedMethod,
                package: widget.package,
              ),
            )),
            icon: const Icon(Iconsax.document_upload, size: 20),
            label: Text(s.uploadProof),
          ),
        ),
      ),
    );
  }

  Widget _methodCard(BuildContext context, {
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final colors = Theme.of(context).colorScheme;
    final isSelected = _selectedMethod == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? colors.primary : colors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? colors.primary.withValues(alpha: 0.04) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? colors.primary : colors.outline,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: colors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: subtitle));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(children: [
                            const Icon(Iconsax.tick_circle, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            const Text('تم النسخ'),
                          ]),
                          backgroundColor: const Color(0xFF22C55E),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(width: 6),
                        Icon(Iconsax.copy, size: 14, color: colors.outline),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
