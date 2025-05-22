import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_jornadakids/app/services/auth_service.dart';
import 'package:flutter_jornadakids/app/ui/pages/home/home_page.dart';
import 'package:flutter_jornadakids/app/ui/pages/auth/user_register/register_page_child.dart';
import 'package:flutter_jornadakids/app/ui/pages/auth/user_register/register_page_responsible.dart';
import 'package:flutter_jornadakids/app/ui/utils/constants.dart' as constants;

class LoginPage extends StatefulWidget {
  final constants.UserType userType;
  const LoginPage({super.key, required this.userType});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _authService = AuthService();
  
  bool _isFormValid = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

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
      _isFormValid =
          _usernameController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
      _errorMessage = null; // Clear error on input change
    });
  }

  void _handleLogin() async {
    // Clear previous error message and show loading state
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Call the mock authentication service
    final result = await _authService.login(
      _usernameController.text, 
      _passwordController.text,
      widget.userType
    );

    // Check authentication result
    if (result.success) {
      // Navigate to Home page
      if (mounted) {
        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Navigate to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              userType: widget.userType,
              username: result.user?.name ?? _usernameController.text,
            ),
          ),
        );
      }
    } else {
      // Show error message
      setState(() {
        _errorMessage = result.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constants.AppColors.primary,
      appBar: AppBar(
        backgroundColor: constants.AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Fazer Login', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Image.asset('assets/images/app_logo.png', height: 250)
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: 500.ms,
                curve: Curves.easeOutBack,
              ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Bem-Vindo',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: constants.AppColors.darkText,
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0, delay: 300.ms, duration: 500.ms, curve: Curves.easeOut),
                    
                    if (widget.userType == constants.UserType.child)
                      const Text(
                        '(Área da Criança)',
                        style: TextStyle(
                          fontSize: 16, 
                          color: constants.AppColors.secondary,
                        ),
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 500.ms),
                      
                    if (widget.userType == constants.UserType.responsible)
                      const Text(
                        '(Área do Responsável)',
                        style: TextStyle(
                          fontSize: 16,
                          color: constants.AppColors.secondary,
                        ),
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 500.ms),

                    const SizedBox(height: 24),
                    
                    // Display error message if present
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .shakeX(duration: 500.ms, curve: Curves.elasticOut),

                    const SizedBox(height: 16),                    
                    Container(
                      decoration: BoxDecoration(
                        color: constants.AppColors.lightGray,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1), 
                            blurRadius: 5, 
                            offset: const Offset(0, 3), 
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Nome do usuário',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          prefixIcon: Icon(Icons.person, color: constants.AppColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent, 
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 500.ms)
                    .slideX(begin: -0.2, end: 0, delay: 400.ms, duration: 500.ms, curve: Curves.easeOut),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: constants.AppColors.lightGray,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1), 
                            blurRadius: 5, 
                            offset: const Offset(0, 3), 
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Senha',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          prefixIcon: Icon(Icons.lock, color: constants.AppColors.primary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                              color: constants.AppColors.primary,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 500.ms)
                    .slideX(begin: 0.2, end: 0, delay: 500.ms, duration: 500.ms, curve: Curves.easeOut),      

                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isFormValid && !_isLoading ? _handleLogin : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isFormValid
                                ? const Color(0xFF000957)
                                : constants.AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: constants.AppColors.gray200,
                        disabledForegroundColor: Colors.white.withAlpha(204),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 5,
                        shadowColor: _isFormValid 
                            ? const Color(0xFF000957).withOpacity(0.5)
                            : constants.AppColors.primary.withOpacity(0.5),
                      ),
                      child: _isLoading 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Entrar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                    )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 500.ms)
                    .scaleXY(begin: 0.9, end: 1.0, delay: 600.ms, duration: 800.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Não possui uma conta?'),
                        TextButton(
                          onPressed: () {
                            if (widget.userType ==
                                constants.UserType.responsible) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          const RegisterPageResponsible(),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const RegisterPageChild(),
                                ),
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF000957),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('Crie uma'),
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 500.ms),
                    
                    const SizedBox(height: 20),
                    // Mock users information for testing
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Usuários para teste:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (widget.userType == constants.UserType.responsible)
                            Text(
                              'Responsáveis: maria / 123456, joao / 123456',
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                          if (widget.userType == constants.UserType.child)
                            Text(
                              'Crianças: lucas / 123456, ana / 123456',
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 500.ms),
                  ],
                ),
              ),
            ),
          ).animate().slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutQuint),
        ],
      ),
    );
  }
}