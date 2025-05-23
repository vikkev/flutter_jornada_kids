import 'package:flutter/material.dart';
import 'package:flutter_jornadakids/app/presentation/pages/auth/login/login_page.dart';
import 'package:flutter_jornadakids/app/presentation/pages/auth/login/login_type_page.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart' as constants;
import 'package:flutter_jornadakids/app/presentation/widgets/success_message_page.dart';

class RegisterPageChild extends StatefulWidget {
  const RegisterPageChild({super.key});

  @override
  State<RegisterPageChild> createState() => _RegisterPageChildState();
}

class _RegisterPageChildState extends State<RegisterPageChild> {
  final List<TextEditingController> _codeControllers = List.generate(
    6, 
    (index) => TextEditingController()
  );
  
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Adicionar listeners para validação do código
    for (var controller in _codeControllers) {
      controller.addListener(_validateCode);
    }
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
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
    });
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
            child: Image.asset('assets/images/app_logo.png', height: 320),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Digite o código para identificar o responsável',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                        (index) => SizedBox(
                          width: 40,
                          height: 50,
                          child: TextField(
                            controller: _codeControllers[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                            decoration: InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: AppColors.lightGray,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                   ElevatedButton(
                  onPressed: _isFormValid
                    ? () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SuccessMessagePage(
                              message: 'Cadastro efetuado com sucesso!',
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
                    : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFormValid ? AppColors.darkBlue : AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.gray200,
                        disabledForegroundColor: Colors.white.withAlpha(204),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Confirmar'),
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