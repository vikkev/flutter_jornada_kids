import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';
import 'package:flutter_jornadakids/app/models/usuario.dart';
import 'package:flutter_jornadakids/app/models/crianca.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_jornadakids/app/services/api_config.dart';
import 'package:flutter_jornadakids/app/services/responsible_service.dart';

class ChildrenListPage extends StatefulWidget {
  final Usuario responsavel;
  const ChildrenListPage({super.key, required this.responsavel});

  @override
  State<ChildrenListPage> createState() => _ChildrenListPageState();
}

class _ChildrenListPageState extends State<ChildrenListPage> {
  late Future<List<ChildInfo>> _childrenFuture;

  @override
  void initState() {
    super.initState();
    _childrenFuture = ResponsibleService().fetchChildren(widget.responsavel.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: const Text(
          'Minhas Crianças',
          style: TextStyle(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.darkBlue),
      ),
      body: FutureBuilder<List<ChildInfo>>(
        future: _childrenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: \\${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma criança encontrada.'));
          }
          final children = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: children.length,
            itemBuilder: (context, index) {
              final crianca = children[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary.withOpacity(0.13),
                      child: Icon(Icons.child_care, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            crianca.nome,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.darkText),
                          ),
                          const SizedBox(height: 4),
                          Text('Nível: ${crianca.nivel}  •  Idade: ${crianca.idade}',
                            style: const TextStyle(fontSize: 14, color: AppColors.gray400)),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: (index * 120).ms).slideY(begin: 0.08);
            },
          );
        },
      ),
    );
  }
}

class _ChildInfo {
  final int id;
  final int idade;
  final int nivel;
  final String nome;

  _ChildInfo({required this.id, required this.idade, required this.nivel, required this.nome});

  factory _ChildInfo.fromJson(Map<String, dynamic> json) {
    return _ChildInfo(
      id: json['id'] ?? 0,
      idade: json['idade'] ?? 0,
      nivel: json['nivel'] ?? 0,
      nome: json['usuario']?['nomeCompleto'] ?? '',
    );
  }
} 