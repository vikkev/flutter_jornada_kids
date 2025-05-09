import 'package:flutter/material.dart';
import 'package:flutter_jornadakids/app/ui/utils/constants.dart';

class RegisterPageResponsible extends StatefulWidget {
  const RegisterPageResponsible({super.key});

  @override
  State<RegisterPageResponsible> createState() => _RegisterPageResponsibleState();
}

class _RegisterPageResponsibleState extends State<RegisterPageResponsible> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _acceptTerms = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Adicionar listeners para validação do formulário
    _nameController.addListener(_validateForm);
    _usernameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _birthDateController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _nameController.text.isNotEmpty &&
          _usernameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty &&
          _birthDateController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text &&
          _acceptTerms;
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
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 82),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Novo Cadastro',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildTextField(_nameController, 'Nome completo'),
              const SizedBox(height: 12),
              _buildTextField(_usernameController, 'Digite seu nome de usuário'),
              const SizedBox(height: 12),
              _buildTextField(_emailController, 'E-mail'),
              const SizedBox(height: 12),
              _buildTextField(_phoneController, 'Telefone'),
              const SizedBox(height: 12),
              _buildDropdownField('Responsável'),
              const SizedBox(height: 12),
              _buildTextField(_birthDateController, 'Data de nascimento'),
              const SizedBox(height: 12),
              _buildTextField(_passwordController, 'Senha', isPassword: true),
              const SizedBox(height: 12),
              _buildTextField(_confirmPasswordController, 'Confirme a senha', isPassword: true),
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isFormValid 
                    ? () {
                        // Lógica para criar conta
                      } 
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid 
                      ? AppColors.darkBlue 
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary,
                  disabledForegroundColor: Colors.white.withAlpha(204),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Criar conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: AppColors.lightGray,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDropdownField(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: const [
            DropdownMenuItem(value: 'pai', child: Text('Pai')),
            DropdownMenuItem(value: 'mae', child: Text('Mãe')),
            DropdownMenuItem(value: 'outro', child: Text('Outro')),
          ],
          onChanged: (value) {
            // Atualizar valor selecionado
            _validateForm();
          },
        ),
      ),
    );
  }
}