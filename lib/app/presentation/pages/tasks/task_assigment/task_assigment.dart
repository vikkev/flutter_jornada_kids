import 'package:flutter/material.dart';
import 'package:flutter_jornadakids/app/models/usuario.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';
import 'package:flutter_jornadakids/app/presentation/pages/tasks/task_description/task_description_page.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';

class TaskAssignmentScreen extends StatefulWidget {
  const TaskAssignmentScreen({super.key});

  @override
  State<TaskAssignmentScreen> createState() => _TaskAssignmentScreenState();
}

class _TaskAssignmentScreenState extends State<TaskAssignmentScreen> {
  Usuario? selectedUser;

  // Mock de usuários reais (criança e responsável)
  final List<Usuario> users = [
    Usuario(
      id: 1,
      nomeCompleto: 'Lucas Silva',
      nomeUsuario: 'lucas',
      email: 'lucas@teste.com',
      telefone: '99999-1111',
      senha: '123456',
      tipoUsuario: TipoUsuario.crianca,
      criadoEm: DateTime.now(),
      atualizadoEm: DateTime.now(),
    ),
    Usuario(
      id: 2,
      nomeCompleto: 'Maria Souza',
      nomeUsuario: 'maria',
      email: 'maria@teste.com',
      telefone: '99999-2222',
      senha: '123456',
      tipoUsuario: TipoUsuario.responsavel,
      criadoEm: DateTime.now(),
      atualizadoEm: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Designar tarefa para',
                    style: TextStyle(
                      color: AppColors.darkText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.grey.withOpacity(1),
                      width: 1,
                    ),
                  ),
                  child: ListView(
                    children: users.map((user) => _buildUserTile(user)).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: selectedUser != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskDescriptionPage(assignedUser: selectedUser!.nomeCompleto),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                  disabledBackgroundColor: AppColors.grey.withOpacity(1),
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

  Widget _buildUserTile(Usuario user) {
    final isSelected = selectedUser?.id == user.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.grey.withOpacity(1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<Usuario>(
        value: user,
        groupValue: selectedUser,
        onChanged: (value) {
          setState(() {
            selectedUser = value;
          });
        },
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(Icons.person, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nomeCompleto,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  user.tipoUsuario == TipoUsuario.crianca ? 'Criança' : 'Responsável',
                  style: TextStyle(fontSize: 14, color: AppColors.gray400),
                ),
              ],
            ),
          ],
        ),
        activeColor: AppColors.primary,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
