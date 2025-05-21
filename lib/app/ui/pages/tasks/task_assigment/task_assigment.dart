import 'package:flutter/material.dart';
import 'package:flutter_jornadakids/app/ui/pages/tasks/task_description/task_description_page.dart';
import 'package:flutter_jornadakids/app/ui/utils/constants.dart';

class TaskAssignmentScreen extends StatefulWidget {
  const TaskAssignmentScreen({super.key});

  @override
  State<TaskAssignmentScreen> createState() => _TaskAssignmentScreenState();
}

class _TaskAssignmentScreenState extends State<TaskAssignmentScreen> {
  String? selectedUser;

  // Lista de exemplo de usuários - ajuste conforme sua necessidade
  final List<User> users = [
    User(name: 'Nome', type: 'Tipo de conta', avatar: 'assets/avatar1.png'),
    User(name: 'Nome2', type: 'Tipo de conta2', avatar: 'assets/avatar2.png'),
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
                    icon: const Icon(Icons  .arrow_back, color: Colors.black),
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
                  child: Column(
                    children: [...users.map((user) => _buildUserTile(user))],
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
                          builder: (context) => TaskDescriptionPage(assignedUser: selectedUser!),
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


  Widget _buildUserTile(User user) {
    final isSelected = selectedUser == user.name;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isSelected ? AppColors.primary : AppColors.grey.withOpacity(1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<String>(
        value: user.name,
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
                  user.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  user.type,
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

class User {
  final String name;
  final String type;
  final String avatar;

  User({required this.name, required this.type, required this.avatar});
}
