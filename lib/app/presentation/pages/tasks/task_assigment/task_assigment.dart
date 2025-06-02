import 'package:flutter/material.dart';
import 'package:flutter_jornadakids/app/models/usuario.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';
import 'package:flutter_jornadakids/app/presentation/pages/tasks/task_description/task_description_page.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';
import 'package:flutter_jornadakids/app/services/responsible_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TaskAssignmentScreen extends StatefulWidget {
  final int responsavelId;
  final Usuario usuarioResponsavel;
  const TaskAssignmentScreen({super.key, required this.responsavelId, required this.usuarioResponsavel});

  @override
  State<TaskAssignmentScreen> createState() => _TaskAssignmentScreenState();
}

class _TaskAssignmentScreenState extends State<TaskAssignmentScreen> {
  ChildInfo? selectedUser;
  late Future<List<ChildInfo>> _childrenFuture;

  Future<List<ChildInfo>> _loadChildrenFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final childrenString = prefs.getString('children');
    if (childrenString != null) {
      final List<dynamic> childrenJson = jsonDecode(childrenString);
      return childrenJson.map((json) => ChildInfo.fromJson(json)).toList();
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _childrenFuture = _loadChildrenFromLocalStorage();
  }

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
                  child: FutureBuilder<List<ChildInfo>>(
                    future: _childrenFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Erro: \\${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('Nenhuma criança encontrada.'));
                      }
                      final users = snapshot.data!;
                      return ListView(
                        children: users.map((user) => _buildUserTile(user)).toList(),
                      );
                    },
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
                            builder: (context) => TaskDescriptionPage(
                              idResponsavel: widget.responsavelId,
                              idCrianca: selectedUser!.id,
                              usuarioResponsavel: widget.usuarioResponsavel,
                            ),
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

  Widget _buildUserTile(ChildInfo user) {
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
      child: RadioListTile<ChildInfo>(
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
                  user.nome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const Text(
                  'Criança',
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

class ChildInfo {
  final int id;
  final int idade;
  final String nivel;
  final String nome;

  const ChildInfo({
    required this.id,
    required this.idade,
    required this.nivel,
    required this.nome,
  });

  ChildInfo.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        idade = json['idade'],
        nivel = json['nivel'],
        nome = json['nome'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'idade': idade,
    'nivel': nivel,
    'nome': nome,
  };
}
