import 'package:flutter/material.dart';
import 'login_page.dart';
import '../../../utils/constants.dart';

class LoginTypePage extends StatelessWidget {
  const LoginTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          const Spacer(flex: 3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Image.asset('assets/images/app_logo.png', height: 320),
          ),
          const SizedBox(height: 16),
          const Spacer(),
          Container(
            padding: const EdgeInsets.only(
              top: 30,
              left: 50,
              right: 50,
              bottom: 100,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Bem-Vindo',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Salva a escolha do usuário como responsável
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                const LoginPage(userType: UserType.responsible),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Responsável'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Salva a escolha do usuário como criança/adolescente
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                const LoginPage(userType: UserType.child),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Criança / Adolescente'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
