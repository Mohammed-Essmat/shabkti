import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shabakti/providers/auth_provider.dart';
import 'package:shabakti/providers/language_provider.dart';
import 'package:shabakti/screens/login_screen.dart';
import 'package:shabakti/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _logoController, curve: const Interval(0, 0.5)));
    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _textFade = Tween<double>(begin: 0, end: 1).animate(_textController);
    _logoController.forward().then((_) => _textController.forward());
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final isLoggedIn = await auth.checkAuth();
    if (!mounted) return;
    Navigator.pushReplacement(context, PageRouteBuilder(
      pageBuilder: (_, __, ___) => isLoggedIn ? const HomeScreen() : const LoginScreen(),
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
    ));
  }

  @override
  void dispose() { _logoController.dispose(); _textController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final s = lang.strings;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [const Color(0xFF0041B0), Theme.of(context).colorScheme.primaryContainer, const Color(0xFF1E40AF)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: Image.asset('assets/images/SHABAKTI LOGO.png', width: 100, height: 100),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textFade,
                child: Column(
                  children: [
                    Text(s.appName, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5)),
                    const SizedBox(height: 6),
                    Text(s.appTagline, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 3),
            const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54)),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
