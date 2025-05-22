import 'package:flutter/material.dart';
import 'package:flutter_jornadakids/app/ui/pages/home/home_page.dart';
import 'package:flutter_jornadakids/app/ui/utils/constants.dart';
import 'package:flutter_jornadakids/app/ui/utils/constants.dart' as constants;
import 'package:flutter_jornadakids/app/ui/widgets/data_picker_field.dart';
import 'package:flutter_jornadakids/app/ui/widgets/select_field.dart';
import 'package:flutter_jornadakids/app/ui/widgets/success_message_page.dart';

class TaskDescriptionPage extends StatefulWidget {
  const TaskDescriptionPage({super.key, required String assignedUser});

  @override
  State<TaskDescriptionPage> createState() => _TaskDescriptionPageState();
}

class _TaskDescriptionPageState extends State<TaskDescriptionPage> {
  final TextEditingController responsibleController = TextEditingController();
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController scoreController = TextEditingController();

  bool requiresPhoto = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();

    responsibleController.addListener(_validateForm);
    taskNameController.addListener(_validateForm);
    deadlineController.addListener(_validateForm);
    scoreController.addListener(_validateForm);
  }

  @override
  void dispose() {
    responsibleController.removeListener(_validateForm);
    taskNameController.removeListener(_validateForm);
    deadlineController.removeListener(_validateForm);
    scoreController.removeListener(_validateForm);

    responsibleController.dispose();
    taskNameController.dispose();
    deadlineController.dispose();
    scoreController.dispose();

    super.dispose();
  }

  void _validateForm() {
    final isValid = responsibleController.text.isNotEmpty &&
        taskNameController.text.isNotEmpty &&
        deadlineController.text.isNotEmpty &&
        scoreController.text.isNotEmpty;

    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Botão de voltar e título
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Criar tarefa',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Campos de texto
              Select<String>(
                selectedValue: responsibleController.text.isEmpty ? null : responsibleController.text,
                options: ['Maria', 'João', 'Ana', 'Carlos'], // Substitua pelos nomes reais
                onChanged: (newValue) {
                  setState(() {
                    responsibleController.text = newValue ?? '';
                    _validateForm();
                  });
                },
                getLabel: (value) => value,
                hintText: 'Selecione o responsável',
              ),
              const SizedBox(height: 12),
              _buildTextField(taskNameController, 'Nome da Tarefa'),
              const SizedBox(height: 12),
              DatePickerField(
                initialDate: null,
                onDateSelected: (date) {
                  deadlineController.text =
                      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(scoreController, 'Pontuação da Tarefa'),
              const SizedBox(height: 24),

              // Texto da pergunta
              const Text(
                'Finalizando a tarefa, precisa comprovar com alguma foto?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 12),

              // Radio Buttons
              Row(
                children: [
                  _buildRadioOption(true, 'Sim'),
                  const SizedBox(width: 16),
                  _buildRadioOption(false, 'Não'),
                ],
              ),

              const Spacer(),

              // Botão Criar
              ElevatedButton(
                onPressed: _isFormValid ? _onCreatePressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid ? AppColors.darkBlue : AppColors.primary,
                  disabledBackgroundColor: AppColors.gray300,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white.withAlpha(204),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Criar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onCreatePressed() {
    if (responsibleController.text.isEmpty ||
        taskNameController.text.isEmpty ||
        deadlineController.text.isEmpty ||
        scoreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SuccessMessagePage(
        message: 'Tarefa criada com sucesso!',
        buttonText: 'Voltar para lista',
        onButtonPressed: () {
          // Navigate to HomePage and remove all previous routes
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                userType: constants.UserType.responsible,
                username: 'Nome do Usuário', // You should pass the actual username here
              ),
            ),
            (route) => false, // This removes all previous routes
          );
        },
      ),
    ),
  );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
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
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade600),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption(bool value, String label) {
    return Row(
      children: [
        Radio<bool>(
          value: value,
          groupValue: requiresPhoto,
          onChanged: (newValue) {
            setState(() {
              requiresPhoto = newValue!;
            });
          },
          activeColor: AppColors.darkBlue,
        ),
        Text(label),
      ],
    );
  }
}
