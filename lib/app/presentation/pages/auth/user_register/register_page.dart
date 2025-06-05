import 'package:flutter/material.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';
import 'package:flutter_jornadakids/app/presentation/widgets/data_picker_field.dart';
import 'package:flutter_jornadakids/app/presentation/widgets/success_message_page.dart';
import 'package:flutter_jornadakids/app/services/auth_user_register.dart';
import 'package:flutter_jornadakids/app/presentation/pages/auth/login/login_page.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';

class RegisterPage extends StatefulWidget {
  final bool isResponsible;
  final String? responsibleId;
  final String? responsibleName;

  const RegisterPage({
    super.key,
    required this.isResponsible,
    this.responsibleId,
    this.responsibleName,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  DateTime? _birthDate;
  bool _isFormValid = false;

  // Para responsável
  String? _selectedTipoResponsavel;
  bool _acceptTerms = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _usernameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      if (widget.isResponsible) {
        _isFormValid = _nameController.text.isNotEmpty &&
            _usernameController.text.isNotEmpty &&
            _emailController.text.isNotEmpty &&
            _phoneController.text.isNotEmpty &&
            _birthDate != null &&
            _selectedTipoResponsavel != null &&
            _passwordController.text.isNotEmpty &&
            _confirmPasswordController.text.isNotEmpty &&
            _passwordController.text == _confirmPasswordController.text &&
            _acceptTerms;
      } else {
        _isFormValid = _nameController.text.isNotEmpty &&
            _usernameController.text.isNotEmpty &&
            _emailController.text.isNotEmpty &&
            _phoneController.text.isNotEmpty &&
            _birthDate != null &&
            _passwordController.text.isNotEmpty &&
            _confirmPasswordController.text.isNotEmpty &&
            _passwordController.text == _confirmPasswordController.text;
      }
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
          'Cadastro',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.isResponsible ? 'Novo Cadastro de Responsável' : 'Novo Cadastro de Criança/Adolescente',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(_nameController, 'Nome completo'),
                    const SizedBox(height: 12),
                    _buildTextField(_usernameController, widget.isResponsible ? 'Digite seu nome de usuário' : 'Nome de usuário'),
                    const SizedBox(height: 12),
                    _buildTextField(_emailController, 'E-mail'),
                    const SizedBox(height: 12),
                    _buildTextField(_phoneController, 'Telefone'),
                    const SizedBox(height: 12),
                    if (widget.isResponsible) _buildDropdownField('Tipo de responsável'),
                    if (widget.isResponsible) const SizedBox(height: 12),
                    DatePickerField(
                      initialDate: _birthDate,
                      onDateSelected: (date) {
                        setState(() {
                          _birthDate = date;
                        });
                        _validateForm();
                      },
                      hintText: widget.isResponsible ? 'Selecione a data de nascimento' : 'Data de nascimento',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(_passwordController, 'Senha', isPassword: true),
                    const SizedBox(height: 12),
                    _buildTextField(_confirmPasswordController, 'Confirme a senha', isPassword: true),
                    if (!widget.isResponsible && widget.responsibleName != null) ...[
                      const SizedBox(height: 24),
                      Text('Responsável: ${widget.responsibleName}', style: const TextStyle(fontSize: 15, color: AppColors.primary)),
                    ],
                    if (widget.isResponsible) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptTerms = value ?? false;
                                _validateForm();
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                          Expanded(
                            child: Text(
                              'Ao criar uma conta, você concorda com nossos Termos e Condições.',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: (_isFormValid && !_isLoading)
                          ? () async {
                              setState(() {
                                _isLoading = true;
                              });
                              try {
                                final service = AuthUserRegisterService();
                                dynamic response;
                                if (widget.isResponsible) {
                                  response = await service.registerResponsible(
                                    tipoResponsavel: _selectedTipoResponsavel!,
                                    nomeCompleto: _nameController.text,
                                    nomeUsuario: _usernameController.text,
                                    email: _emailController.text,
                                    telefone: _phoneController.text,
                                    senha: _passwordController.text,
                                    tipoUsuario: 'R',
                                  );
                                } else {
                                  response = await service.registerChild(
                                    nomeCompleto: _nameController.text,
                                    nomeUsuario: _usernameController.text,
                                    email: _emailController.text,
                                    telefone: _phoneController.text,
                                    senha: _passwordController.text,
                                    dataNascimento: _birthDate!,
                                    idResponsavel: widget.responsibleId!,
                                    tipoUsuario: 'C',
                                  );
                                }
                                if (!mounted) return;
                                if (response.statusCode == 201 || response.statusCode == 200) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SuccessMessagePage(
                                        message: widget.isResponsible
                                            ? 'Cadastro efetuado com sucesso!'
                                            : 'Cadastro da criança efetuado com sucesso!',
                                        buttonText: 'Ir para login',
                                        onButtonPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => LoginPage(
                                                userType: widget.isResponsible ? TipoUsuario.responsavel : TipoUsuario.crianca,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Erro ao cadastrar: ${response.data.toString()}')),
                                  );
                                }
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erro ao cadastrar: ${e.toString()}')),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
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
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Criar conta'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isPassword = false}) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade600),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String hint) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTipoResponsavel,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: const [
            DropdownMenuItem(value: 'AM', child: Text('Avô')),
            DropdownMenuItem(value: 'AF', child: Text('Avó')),
            DropdownMenuItem(value: 'P', child: Text('Pai')),
            DropdownMenuItem(value: 'M', child: Text('Mãe')),
            DropdownMenuItem(value: 'TM', child: Text('Tio')),
            DropdownMenuItem(value: 'TF', child: Text('Tia')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedTipoResponsavel = value;
            });
            _validateForm();
          },
        ),
      ),
    );
  }
} 