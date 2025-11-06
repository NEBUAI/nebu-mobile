import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _textController;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // Animación del ícono (gatito bajando)
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _iconScaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );

    _iconOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Animación del texto "FLOW"
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 1.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    _textOpacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    // Iniciar secuencia de animaciones
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    // 1. Animar el ícono del gatito
    await _iconController.forward();

    // 2. Esperar un poco
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // 3. Animar el texto "FLOW"
    await _textController.forward();

    // 4. Esperar antes de navegar
    await Future<void>.delayed(const Duration(milliseconds: 600));

    // 5. Navegar a la siguiente pantalla
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) {
      return;
    }

    final authState = ref.read(authProvider);

    if (authState.isAuthenticated) {
      context.go(AppConstants.routeHome);
    } else {
      context.go(AppConstants.routeWelcome);
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF6B4EFF),
    body: SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono del gatito animado
            AnimatedBuilder(
              animation: _iconController,
              builder: (context, child) => Opacity(
                opacity: _iconOpacityAnimation.value,
                child: Transform.scale(
                  scale: _iconScaleAnimation.value,
                  child: SvgPicture.asset(
                    'assets/icon_flow.svg',
                    width: 120,
                    height: 120,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Texto "FLOW" animado
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) => SlideTransition(
                position: _textSlideAnimation,
                child: Opacity(
                  opacity: _textOpacityAnimation.value,
                  child: Text(
                    'FLOW',
                    style: GoogleFonts.poppins(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 6,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Subtítulo animado
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) => Opacity(
                opacity: _textOpacityAnimation.value,
                child: Text(
                  'Powered by Nebu',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
