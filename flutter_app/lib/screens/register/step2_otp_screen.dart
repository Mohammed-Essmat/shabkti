import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/providers/auth_provider.dart';
import 'package:shabakti/providers/language_provider.dart';
import 'package:shabakti/widgets/custom_button.dart';
import 'package:shabakti/widgets/shabakti_app_bar.dart';
import 'package:shabakti/screens/register/step3_password_screen.dart';

class Step2OtpScreen extends StatefulWidget {
  const Step2OtpScreen({super.key});
  @override
  State<Step2OtpScreen> createState() => _Step2OtpScreenState();
}

class _Step2OtpScreenState extends State<Step2OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _countdown = 150;
  Timer? _timer;

  @override
  void initState() { super.initState(); _startTimer(); }

  void _startTimer() {
    _timer?.cancel(); _countdown = 150;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) { if (_countdown <= 0) { t.cancel(); return; } setState(() => _countdown--); });
  }

  String get _otpCode => _controllers.map((c) => c.text).join();
  String get _timerText { final m = (_countdown ~/ 60).toString().padLeft(2, '0'); final sec = (_countdown % 60).toString().padLeft(2, '0'); return '$m:$sec'; }

  Future<void> _verify() async {
    if (_otpCode.length != 6) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.verifyOtp(code: _otpCode);
    if (success && mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const Step3PasswordScreen()));
  }

  @override
  void dispose() { _timer?.cancel(); for (final c in _controllers) { c.dispose(); } for (final f in _focusNodes) { f.dispose(); } super.dispose(); }

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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _stepBar(2, s, context),
            const SizedBox(height: 24),
            Text(s.otpTitle, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(s.otpSent, style: Theme.of(context).textTheme.bodyMedium),
            if (auth.regEmail != null) ...[const SizedBox(height: 4),
              Text(auth.regEmail!, style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600, fontSize: 14))],
            const SizedBox(height: 36),

            Directionality(textDirection: TextDirection.ltr,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (i) => SizedBox(width: 48, height: 56,
                  child: TextField(
                    controller: _controllers[i], focusNode: _focusNodes[i], textAlign: TextAlign.center,
                    keyboardType: TextInputType.number, maxLength: 1,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(counterText: '', contentPadding: const EdgeInsets.symmetric(vertical: 14), filled: true,
                      fillColor: _controllers[i].text.isNotEmpty ? colors.primary.withValues(alpha: 0.06) : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: colors.outlineVariant)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: _controllers[i].text.isNotEmpty ? colors.primary : colors.outlineVariant)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: colors.primary, width: 2))),
                    onChanged: (v) { setState(() {});
                      if (v.isNotEmpty && i < 5) { _focusNodes[i + 1].requestFocus(); }
                      else if (v.isEmpty && i > 0) { _focusNodes[i - 1].requestFocus(); }
                    },
                  ),
                )),
              ),
            ),

            const SizedBox(height: 28),
            Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: colors.surfaceContainerHighest.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Iconsax.timer_1, size: 16, color: colors.outline), const SizedBox(width: 6),
                Text(_timerText, style: TextStyle(color: colors.outline, fontWeight: FontWeight.w600, fontSize: 14)),
              ]),
            )),

            if (auth.error != null) ...[const SizedBox(height: 16),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: colors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                child: Row(children: [Icon(Iconsax.warning_2, size: 18, color: colors.error), const SizedBox(width: 8),
                  Expanded(child: Text(auth.error!, style: TextStyle(color: colors.error, fontSize: 13)))]))],

            const SizedBox(height: 24),
            CustomButton(text: s.confirmCode, onPressed: _otpCode.length == 6 ? _verify : null, isLoading: auth.isLoading, icon: Iconsax.shield_tick),
            const SizedBox(height: 16),
            Center(child: TextButton(
              onPressed: _countdown <= 0 ? () { _startTimer(); } : null,
              child: Text(s.noCode, style: TextStyle(color: _countdown <= 0 ? colors.primary : colors.outline, fontWeight: _countdown <= 0 ? FontWeight.w600 : FontWeight.w400)),
            )),
          ]),
        ),
      ),
    );
  }

  Widget _stepBar(int step, dynamic s, BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: List.generate(3, (i) => Expanded(child: Container(height: 4, margin: EdgeInsets.only(left: i > 0 ? 6 : 0),
        decoration: BoxDecoration(color: i < step ? colors.primary : colors.outlineVariant.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)))))),
      const SizedBox(height: 10), Text(s.stepOf(step), style: Theme.of(context).textTheme.labelMedium),
    ]);
  }
}
