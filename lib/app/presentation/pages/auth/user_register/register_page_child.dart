import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_jornadakids/app/presentation/pages/auth/login/login_page.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';
import 'package:flutter_jornadakids/app/presentation/widgets/success_message_page.dart';
import 'package:flutter_jornadakids/app/services/auth_user_register.dart';
import 'package:flutter_jornadakids/app/presentation/pages/auth/user_register/select_responsible_page.dart';


class RegisterPageChild extends StatefulWidget {
  const RegisterPageChild({super.key});

  @override
  State<RegisterPageChild> createState() => _RegisterPageChildState();
}

class _RegisterPageChildState extends State<RegisterPageChild> with TickerProviderStateMixin {
  final List<TextEditingController> _codeControllers = List.generate(
    6, 
    (index) => TextEditingController()
  );
  
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  
  bool _isFormValid = false;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  
  final AuthUserRegisterService _authService = AuthUserRegisterService();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _codeControllers.length; i++) {
      _codeControllers[i].addListener(_validateCode);
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          setState(() {
            _hasError = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _validateCode() {
    bool allFilled = true;
    for (var controller in _codeControllers) {
      if (controller.text.isEmpty) {
        allFilled = false;
        break;
      }
    }
    
    setState(() {
      _isFormValid = allFilled;
      if (allFilled) {
        _hasError = false;
      }
    });
  }

  String get _fullCode {
    return _codeControllers.map((controller) => controller.text).join();
  }

  Future<void> _validateResponsibleCode() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      // Usar o service real para validar o código
      final result = await _authService.validateResponsibleCode(_fullCode);
      final responsibleInfo = _authService.extractResponsibleInfo(result);
      
      if (responsibleInfo != null) {
        // Código válido - prosseguir para tela de sucesso
        _navigateToSuccess(responsibleInfo);
      } else {
        throw Exception('Erro ao processar dados do responsável');
      }
      
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      
      // Limpar campos e focar no primeiro
      for (var controller in _codeControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
      
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToSuccess([ResponsibleInfo? responsibleInfo]) {
    if (responsibleInfo != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SelectResponsiblePage(
            responsibleCode: responsibleInfo.codigo,
            responsibleName: responsibleInfo.nomeCompleto,
            responsibleId: responsibleInfo.id,
          ),
        ),
      );
    } else {
      final message = 'Cadastro efetuado com sucesso!';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessMessagePage(
            message: message,
            buttonText: 'Ir para login',
            onButtonPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(
                    userType: TipoUsuario.crianca,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  Widget _buildPinInput(int index) {
    final bool isFocused = _focusNodes[index].hasFocus;
    final bool hasContent = _codeControllers[index].text.isNotEmpty;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.ease,
      width: 50,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _hasError
              ? [Colors.red.shade50, Colors.red.shade100]
              : isFocused
                  ? [AppColors.gray400.withOpacity(0.25), AppColors.secondary.withOpacity(0.18)]
                  : hasContent
                      ? [AppColors.gray400.withOpacity(0.18), AppColors.secondary.withOpacity(0.12)]
                      : [Colors.grey.shade50, Colors.grey.shade100],
        ),
        border: Border.all(
          color: _hasError
              ? Colors.red.shade300
              : Colors.grey.shade300,
          width: 1.5,
        ),

      ),
      child: TextField(
        controller: _codeControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _hasError
              ? Colors.red
              : hasContent
                  ? AppColors.secondary
                  : AppColors.secondary,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          hintText: '•',
          hintStyle: TextStyle(
            fontSize: 20,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Troque o backgroundColor pelo Container com gradient
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                colors: [
                  AppColors.darkBlue,
                  AppColors.secondary,
                  AppColors.primary,
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Image.asset('assets/images/app_logo.png', height: 280)
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(
                        begin: const Offset(0.6, 0.6), 
                        duration: 800.ms, 
                        curve: Curves.elasticOut,
                      )
                      .then()
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.02, 1.02),
                        duration: 2000.ms,
                        curve: Curves.easeInOut,
                      ),
                ),
                
                // Container principal com animação
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          
                          // Título com animação melhorada
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              children: [
                                const Text(
                                  'Digite o código de identificação',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                    letterSpacing: 0.1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Insira o código fornecido pelo responsável',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ).animate()
                           .fadeIn(delay: 300.ms, duration: 600.ms)
                           .slideY(begin: 0.3, duration: 600.ms, curve: Curves.easeOutBack),
                          
                          const SizedBox(height: 40),
                          
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                6,
                                (index) => _buildPinInput(index)
                                    .animate()
                                    .fadeIn(
                                      delay: Duration(milliseconds: 400 + (index * 100)), 
                                      duration: 500.ms,
                                    )
                                    .slideY(
                                      begin: 0.5, 
                                      duration: 500.ms, 
                                      curve: Curves.easeOutBack,
                                    )
                                    .then()
                                    .animate(
                                      onPlay: (controller) {
                                        if (_hasError) {
                                          controller.forward();
                                        }
                                      },
                                    )
                                    .shake(
                                      duration: _hasError ? 600.ms : 0.ms,
                                      hz: 4,
                                      curve: Curves.easeInOut,
                                    ),
                              ),
                            ),
                          ),
                          if (_hasError)
                            Container(
                              margin: const EdgeInsets.only(top: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade600,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate()
                             .fadeIn(duration: 400.ms)
                             .slideY(begin: -0.3, duration: 400.ms)
                             .scale(begin: const Offset(0.9, 0.9)),
                          
                          const SizedBox(height: 50),
                         
                          SizedBox(
                            height: 56,
                            // Remova o gradient e boxShadow daqui, deixe só no Ink
                            child: Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: 200,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : (_isFormValid ? _validateResponsibleCode : null),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent, // sempre transparente
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: AppColors.gray200,
                                    disabledForegroundColor: Colors.white.withOpacity(0.7),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 0),
                                  ),
                                  child: _isFormValid
                                      ? Ink(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [AppColors.darkBlue, AppColors.primary],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius: BorderRadius.circular(40),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.18),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                                spreadRadius: 0,
                                              ),
                                            ],
                                          ),
                                          child: Container(
                                            alignment: Alignment.center,
                                            height: 48,
                                            child: _isLoading
                                                ? Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      const SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2.5,
                                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      const Text(
                                                        'Validando...',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ).animate(onPlay: (controller) => controller.repeat())
                                                   .fadeIn(duration: 300.ms)
                                                : const Text(
                                                    'Confirmar Código',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w700,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                          ),
                                        )
                                      : Container(
                                          alignment: Alignment.center,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: AppColors.gray200,
                                            borderRadius: BorderRadius.circular(40),
                                          ),
                                          child: _isLoading
                                              ? Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2.5,
                                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    const Text(
                                                      'Validando...',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ).animate(onPlay: (controller) => controller.repeat())
                                                 .fadeIn(duration: 300.ms)
                                              : const Text(
                                                  'Confirmar Código',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                        ),
                                ),
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 1100.ms, duration: 600.ms)
                          .slideY(begin: 0.3, duration: 600.ms, curve: Curves.easeOutBack)
                          .then()
                          .animate(
                            onPlay: (controller) {
                              if (_isFormValid && !_isLoading) {
                                controller.repeat(reverse: true);
                              }
                            },
                          )
                          .shimmer(
                            duration: _isFormValid && !_isLoading ? 2000.ms : 0.ms,
                            color: Colors.white.withOpacity(0.3),
                            size: 0.8,
                          ),
                        ],
                      ),
                    ),
                  ).animate()
                   .slideY(begin: 0.4, duration: 800.ms, curve: Curves.easeOutCubic)
                   .fadeIn(delay: 200.ms, duration: 800.ms),
                   ),
              ],
            ),
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
                    color: AppColors.primary.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.18),
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
    );
  }
}