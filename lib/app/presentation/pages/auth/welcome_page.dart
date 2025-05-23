import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_jornadakids/app/presentation/pages/auth/login/login_type_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Navega após 3s (tempo mais confortável)
    Future.delayed(3.seconds, () {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginTypePage(),
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Animação mais suave de fade + slide sutil
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.1), // movimento mais sutil
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  )),
                  child: child,
                ),
              );
            },
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF577BC1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo com animação mais elegante
            Image.asset('assets/images/app_logo.png')
                .animate()
                .fadeIn(
                  duration: 1.2.seconds,
                  curve: Curves.easeOut,
                )
                .scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 1.5.seconds,
                  curve: Curves.elasticOut,
                ),
            
            // Espaçamento
            const SizedBox(height: 40),
            
            // Indicador de loading sutil (opcional)
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.7),
                ),
              ),
            )
                .animate()
                .fadeIn(
                  delay: 2.seconds,
                  duration: 500.ms,
                )
                .scale(
                  delay: 2.seconds,
                  begin: const Offset(0.8, 0.8),
                  duration: 500.ms,
                  curve: Curves.easeOut,
                ),
          ],
        ),
      ),
    );
  }
}