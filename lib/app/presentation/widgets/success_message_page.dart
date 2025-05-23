import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';

class SuccessMessagePage extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const SuccessMessagePage({
    super.key,
    required this.message,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
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
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: 0.2),

                      const SizedBox(height: 50),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.darkBlue, width: 3),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: const Icon(
                          Icons.check,
                          color: AppColors.darkBlue,
                          size: 64,
                        ),
                      )
                          .animate()
                          .scale(duration: 500.ms) // efeito pop
                          .fadeIn(),

                      const Spacer(),
                      ElevatedButton(
                        onPressed: onButtonPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkBlue,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          buttonText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: 0.3, curve: Curves.easeOut),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
