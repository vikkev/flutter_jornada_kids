import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_jornadakids/app/ui/pages/auth/login/login_type_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Após 2s, navega para a próxima tela com animação
    Future.delayed(4.seconds, () {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginTypePage(),
            transitionDuration: const Duration(milliseconds: 800),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var curved = CurvedAnimation(parent: animation, curve: Curves.easeInOut);

              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.3),
                    end: Offset.zero,
                  ).animate(curved),
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
        child: Image.asset('assets/images/app_logo.png')
            .animate() // inicia a animação automaticamente
            .fadeIn(duration: 800.ms, curve: Curves.easeIn)
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              duration: 1200.ms,
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }
}
