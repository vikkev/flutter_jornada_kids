import 'package:flutter/material.dart';
import 'package:flutter_jornadakids/app/presentation/pages/home/home_page.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';
import 'package:flutter_jornadakids/app/models/usuario.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';
import 'package:flutter_jornadakids/app/presentation/widgets/data_picker_field.dart';
import 'package:flutter_jornadakids/app/presentation/widgets/select_field.dart';
import 'package:flutter_jornadakids/app/presentation/widgets/success_message_page.dart';
import 'package:flutter_jornadakids/app/services/task_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TaskDescriptionPage extends StatefulWidget {
  final int idResponsavel;
  final int idCrianca;
  final Usuario usuarioResponsavel;
  const TaskDescriptionPage({super.key, required this.idResponsavel, required this.idCrianca, required this.usuarioResponsavel});

  @override
  State<TaskDescriptionPage> createState() => _TaskDescriptionPageState();
}

class _TaskDescriptionPageState extends State<TaskDescriptionPage> {
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController scoreController = TextEditingController();

  DateTime? selectedDeadline;
  bool requiresPhoto = false;
  bool _isFormValid = false;
  bool _isLoading = false;
  String? _errorMessage;
  PrioridadeTarefa _prioridadeSelecionada = PrioridadeTarefa.media;

  @override
  void initState() {
    super.initState();
    taskNameController.addListener(_validateForm);
    descriptionController.addListener(_validateForm);
    deadlineController.addListener(_validateForm);
    scoreController.addListener(_validateForm);
  }

  @override
  void dispose() {
    taskNameController.removeListener(_validateForm);
    descriptionController.removeListener(_validateForm);
    deadlineController.removeListener(_validateForm);
    scoreController.removeListener(_validateForm);
    taskNameController.dispose();
    descriptionController.dispose();
    deadlineController.dispose();
    scoreController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = taskNameController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        deadlineController.text.isNotEmpty &&
        scoreController.text.isNotEmpty &&
        selectedDeadline != null &&
        _prioridadeSelecionada != null;
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  Future<void> _onCreatePressed() async {
    if (!_isFormValid) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await TaskService().createTask(
        idResponsavel: widget.idResponsavel,
        idCrianca: widget.idCrianca,
        titulo: taskNameController.text,
        descricao: descriptionController.text,
        pontuacaoTotal: int.tryParse(scoreController.text) ?? 0,
        prioridade: _prioridadeSelecionada.code,
        dataHoraLimite: selectedDeadline!,
      );
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessMessagePage(
              message: 'Tarefa criada com sucesso!',
              buttonText: 'Voltar para Home',
              onButtonPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => HomePage(usuario: widget.usuarioResponsavel),
                  ),
                  (route) => false,
                );
              },
              secondaryButtonText: 'Criar outra tarefa',
              onSecondaryButtonPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => TaskDescriptionPage(
                      idResponsavel: widget.idResponsavel,
                      idCrianca: widget.idCrianca,
                      usuarioResponsavel: widget.usuarioResponsavel,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao criar tarefa: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              // Nome da Tarefa
              _buildTextField(taskNameController, 'Nome da Tarefa'),
              const SizedBox(height: 12),
              // Descrição da Tarefa
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: TextField(
                  controller: descriptionController,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Descrição da Tarefa',
                    labelStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Prazo da Tarefa
              DatePickerField(
                initialDate: null,
                firstDate: DateTime.now().add(const Duration(days: 1)),
                onDateSelected: (date) {
                  selectedDeadline = date;
                  deadlineController.text =
                      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                  _validateForm();
                },
              ),
              const SizedBox(height: 12),
              // Pontuação da Tarefa
              _buildTextField(scoreController, 'Pontuação da Tarefa'),
              const SizedBox(height: 12),
              // Prioridade
              Select<PrioridadeTarefa>(
                selectedValue: _prioridadeSelecionada,
                options: PrioridadeTarefa.values,
                onChanged: (value) {
                  setState(() {
                    _prioridadeSelecionada = value!;
                  });
                  _validateForm();
                },
                getLabel: (p) => p.label,
                hintText: 'Selecione a prioridade',
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(bottom: 24), // Adiciona espaço abaixo do botão
                child: ElevatedButton(
                  onPressed: _isFormValid && !_isLoading ? _onCreatePressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.secondary,
                          AppColors.darkText,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      height: 56,
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
                              'Criar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
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
    return Container(
      height: 60, // aumenta a altura do input
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          style: const TextStyle(fontSize: 16, color: Colors.black87), // aumenta o fontSize
          decoration: InputDecoration(
            labelText: hint,
            labelStyle: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15, // aumenta o fontSize do label
              fontWeight: FontWeight.w500,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            border: InputBorder.none,
            isDense: false, // deixa o input mais espaçado
            contentPadding: const EdgeInsets.only(top: 18), // mais espaço para o label
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