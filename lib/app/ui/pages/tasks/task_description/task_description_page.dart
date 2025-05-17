import 'package:flutter/material.dart';
import 'package:flutter_jornadakids/app/ui/utils/constants.dart';

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
              _buildTextField(responsibleController, 'Responsável'),
              const SizedBox(height: 12),
              _buildTextField(taskNameController, 'Nome da Tarefa'),
              const SizedBox(height: 12),
              _buildTextField(deadlineController, 'Data e Hora Limite'),
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
                onPressed: () {
                  // TODO: Lógica de criação da tarefa
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
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

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.grey.withOpacity(0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.grey.withOpacity(0.4)),
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
