import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_jornadakids/app/services/auth_service.dart';
import 'package:flutter_jornadakids/app/presentation/pages/home/home_page.dart';
import 'package:flutter_jornadakids/app/presentation/pages/auth/user_register/register_page_child.dart';
import 'package:flutter_jornadakids/app/presentation/pages/auth/user_register/register_page.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart' as constants;

class LoginPage extends StatefulWidget {
  final TipoUsuario userType;
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

    final result = await _authService.login(
      _usernameController.text, 
      _passwordController.text,
      widget.userType
    );

    if (result.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              usuario: result.user!,
            ),
          ),
        );
      }
    } else {
      // Se for erro de tipo de usuário, mostrar dialog especial
      if (result.message != null && result.message!.contains('Tipo de usuário incorreto')) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Tipo de usuário incorreto'),
            content: Text(result.message ?? 'Você está tentando acessar a área errada. Verifique se está na tela correta para seu tipo de conta.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      setState(() {
        _errorMessage = result.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              constants.AppColors.primary,
              constants.AppColors.secondary,
              constants.AppColors.darkBlue,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Column(
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
                          // Título Bem-Vindo com ShaderMask
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [constants.AppColors.primary, constants.AppColors.secondary],
                            ).createShader(bounds),
                            child: const Text(
                              'Bem-Vindo',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // será sobrescrito pelo ShaderMask
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 500.ms)
                          .slideY(begin: 0.2, end: 0, delay: 300.ms, duration: 500.ms, curve: Curves.easeOut),
                          
                          if (widget.userType == TipoUsuario.crianca)
                            const Text(
                              '(Área da Criança/Adolescente)',
                              style: TextStyle(
                                fontSize: 16, 
                                color: constants.AppColors.gray400,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            )
                            .animate()
                            .fadeIn(delay: 300.ms, duration: 500.ms),
                            
                          if (widget.userType == TipoUsuario.responsavel)
                            const Text(
                              '(Área do Responsável)',
                              style: TextStyle(
                                fontSize: 16,
                                color: constants.AppColors.gray400,
                                fontWeight: FontWeight.w500,
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
                              color: constants.AppColors.gray100.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: constants.AppColors.gray300.withOpacity(0.3),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _usernameController,
                              style: const TextStyle(
                                color: constants.AppColors.darkText,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Nome do usuário',
                                hintStyle: TextStyle(
                                  color: constants.AppColors.gray300,
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [constants.AppColors.primary, constants.AppColors.secondary],
                                  ).createShader(bounds),
                                  child: Icon(Icons.person, color: Colors.white),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 18,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: constants.AppColors.primary,
                                    width: 1.7,
                                  ),
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
                              color: constants.AppColors.gray100.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: constants.AppColors.gray300.withOpacity(0.3),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 1,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              style: const TextStyle(
                                color: constants.AppColors.darkText,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Senha',
                                hintStyle: TextStyle(
                                  color: constants.AppColors.gray300,
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [constants.AppColors.primary, constants.AppColors.secondary],
                                  ).createShader(bounds),
                                  child: Icon(Icons.lock, color: Colors.white),
                                ),
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
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 18,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: constants.AppColors.primary,
                                    width: 1.7,
                                  ),
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
                              const Text(
                                'Não possui uma conta?',
                                style: TextStyle(
                                  color: constants.AppColors.gray400,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (widget.userType == TipoUsuario.responsavel) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => RegisterPage(isResponsible: true),
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
                                  foregroundColor: constants.AppColors.secondary,
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
                        ],
                      ),
                    ),
                  ),
                ).animate().slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutQuint),
              ],
            ),
            // Botão de voltar estilizado
            Positioned(
              top: 36,
              left: 16,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: constants.AppColors.primary.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: constants.AppColors.primary.withOpacity(0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          'Voltar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}