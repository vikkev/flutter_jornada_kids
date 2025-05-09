import 'package:flutter/material.dart';
import 'package:flutter_jornadakids/app/ui/pages/home/home_page.dart';
import 'package:flutter_jornadakids/app/ui/pages/auth/user_register/register_page_child.dart';
import 'package:flutter_jornadakids/app/ui/pages/auth/user_register/register_page_responsible.dart';
import 'package:flutter_jornadakids/app/ui/utils/constants.dart';

class LoginPage extends StatefulWidget {
  final UserType userType;
  
  const LoginPage({super.key, required this.userType});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _usernameController.text.isNotEmpty && 
                    _passwordController.text.isNotEmpty;
    });
  }

  void _handleLogin() {
    // Aqui você implementaria a lógica real de autenticação
    // Por enquanto, vamos apenas navegar para a tela inicial
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(
          userType: widget.userType,
          username: _usernameController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Fazer Login',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Image.asset('assets/images/app_logo.png', height: 250),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
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
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Nome do usuário',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.lightGray,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Senha',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.lightGray,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isFormValid ? _handleLogin : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFormValid 
                            ? const Color(0xFF000957) 
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.primary,
                        disabledForegroundColor: Colors.white.withAlpha(204),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Entrar'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Não possui uma conta?'),
                        TextButton(
                          onPressed: () {
                            // Navega para a página correta baseado no tipo de usuário
                            if (widget.userType == UserType.responsible) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPageResponsible(),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPageChild(),
                                ),
                              );
                            }
                          },
                          child: const Text('Crie uma'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}