import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';

class SuccessMessagePage extends StatefulWidget {
  final String message;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonPressed;

  const SuccessMessagePage({
    super.key,
    required this.message,
    required this.buttonText,
    required this.onButtonPressed,
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
  });

  @override
  State<SuccessMessagePage> createState() => _SuccessMessagePageState();
}

class _SuccessMessagePageState extends State<SuccessMessagePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color.lerp(AppColors.darkBlue, AppColors.secondary, _pulseController.value * 0.3)!,
                      AppColors.secondary,
                      Color.lerp(AppColors.primary, AppColors.secondary, _pulseController.value * 0.2)!,
                    ],
                    stops: const [0.0, 0.3, 1.0],
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  Image.asset(
                    'assets/images/app_logo.png',
                    height: 300,
                  )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .slideY(begin: -0.3, end: 0),

                  const SizedBox(height: 48),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Ícone abaixo do logo, acima do texto
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.secondary, width: 8),
                            ),
                            padding: const EdgeInsets.all(24),
                            child: const Icon(
                              Icons.check,
                              color: AppColors.secondary,
                              size: 72,
                              weight: 900,
                            ),
                          )
                              .animate()
                              .scale(duration: 500.ms)
                              .fadeIn(),
                          const SizedBox(height: 32),
                          Text(
                            widget.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .slideY(begin: 0.2),

                          const SizedBox(height: 32),
                          // Ícone abaixo da mensagem

                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 32),
                            child: Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: 250,
                                child: ElevatedButton(
                                  onPressed: widget.onButtonPressed,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(0, 56),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: AppColors.gray200,
                                    disabledForegroundColor: Colors.white.withAlpha(204),
                                    padding: const EdgeInsets.symmetric(vertical: 0),
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.darkBlue,
                                          AppColors.secondary,
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 56,
                                      child: Text(
                                        widget.buttonText,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .slideY(begin: 0.3, curve: Curves.easeOut),
                          if (widget.secondaryButtonText != null && widget.onSecondaryButtonPressed != null) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 48), // aumenta ainda mais o espaço inferior
                              child: SizedBox(
                                width: 250,
                                child: OutlinedButton(
                                  onPressed: widget.onSecondaryButtonPressed,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.darkBlue,
                                    minimumSize: const Size(0, 56),
                                    side: const BorderSide(color: AppColors.darkBlue),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 0),
                                  ),
                                  child: Text(
                                    widget.secondaryButtonText!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}