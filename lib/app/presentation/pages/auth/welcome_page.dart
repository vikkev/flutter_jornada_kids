import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';
import 'package:flutter_jornadakids/app/presentation/pages/auth/login/login_type_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _breathController;

  @override
  void initState() {
    super.initState();
    
    // Controller para o efeito de pulsação no fundo
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Controller para o efeito "breathing" nos círculos
    _breathController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    // Navega após 3.5s
    Future.delayed(3500.ms, () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginTypePage(),
            transitionDuration: const Duration(milliseconds: 800),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.05),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background com gradient animado
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(AppColors.primary, AppColors.secondary, _pulseController.value * 0.3)!,
                      AppColors.secondary,
                      Color.lerp(AppColors.darkBlue, AppColors.primary, _pulseController.value * 0.2)!,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              );
            },
          ),

          // Círculos decorativos animados no fundo
          ...List.generate(6, (index) {
            return AnimatedBuilder(
              animation: _breathController,
              builder: (context, child) {
                final delay = index * 0.5;
                final animValue = ((_breathController.value + delay) % 1.0);
                
                return Positioned(
                  left: (index.isEven ? -50 : size.width - 100) + (animValue * 30),
                  top: (size.height * 0.1) + (index * size.height * 0.15) + (animValue * 20),
                  child: Container(
                    width: 80 + (animValue * 40),
                    height: 80 + (animValue * 40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.03 + (animValue * 0.05)),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Partículas flutuantes
          ...List.generate(15, (index) {
            return Positioned(
              left: (index * 30.0) % size.width,
              top: (index * 50.0) % size.height,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.4),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .moveY(
                    begin: 0,
                    end: -20,
                    duration: Duration(seconds: 3 + (index % 3)),
                    curve: Curves.easeInOut,
                  )
                  .fadeIn(duration: 1000.ms)
                  .then()
                  .fadeOut(duration: 1000.ms),
            );
          }),

          // Conteúdo principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Container com sombra para o logo
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Hero(
                    tag: 'app_logo',
                    child: Image.asset('assets/images/app_logo.png', height: 220)
                        .animate()
                        .fadeIn(
                          duration: 1.5.seconds,
                          curve: Curves.easeOutCubic,
                        )
                        .scale(
                          begin: const Offset(0.3, 0.3),
                          duration: 2.seconds,
                          curve: Curves.elasticOut,
                        )
                        .then() // Depois das animações iniciais
                        .shimmer(
                          delay: 2.seconds,
                          duration: 1.seconds,
                          color: Colors.white.withOpacity(0.3),
                        ),
                  ),
                ),

                const SizedBox(height: 60),

                // Texto de boas-vindas
                Text(
                  'Jornada Kids',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(
                      delay: 1.seconds,
                      duration: 1.2.seconds,
                      curve: Curves.easeOut,
                    )
                    .slideY(
                      begin: 0.3,
                      delay: 1.seconds,
                      duration: 1.2.seconds,
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: 12),

                // Subtítulo
                Text(
                  'Responsabilidade que vira diversão!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.5,
                  ),
                )
                    .animate()
                    .fadeIn(
                      delay: 1.8.seconds,
                      duration: 1.seconds,
                    )
                    .slideY(
                      begin: 0.2,
                      delay: 1.8.seconds,
                      duration: 1.seconds,
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 80),

                // Loading indicator elegante
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Círculo externo pulsante
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 2.5.seconds)
                        .scale(
                          delay: 2.5.seconds,
                          duration: 2.seconds,
                          curve: Curves.easeOut,
                        )
                        .then()
                        .scale(
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.1, 1.1),
                          duration: 1.5.seconds,
                          curve: Curves.easeInOut,
                        )
                        .animate(onPlay: (controller) => controller.repeat(reverse: true)),

                    // Progress indicator customizado
                    SizedBox(
                      width: 35,
                      height: 35,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.8),
                        ),
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    )
                        .animate()
                        .fadeIn(
                          delay: 2.8.seconds,
                          duration: 800.ms,
                        )
                        .scale(
                          delay: 2.8.seconds,
                          begin: const Offset(0.5, 0.5),
                          duration: 800.ms,
                          curve: Curves.elasticOut,
                        ),
                  ],
                ),

                const SizedBox(height: 24),

                // Texto "Carregando..."
                Text(
                  'Preparando sua jornada...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.8,
                  ),
                )
                    .animate()
                    .fadeIn(
                      delay: 3.seconds,
                      duration: 800.ms,
                    )
                    .then()
                    .shimmer(
                      duration: 2.seconds,
                      color: Colors.white.withOpacity(0.5),
                    )
                    .animate(onPlay: (controller) => controller.repeat()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}