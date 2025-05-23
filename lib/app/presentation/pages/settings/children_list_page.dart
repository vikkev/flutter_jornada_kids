import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';
import 'package:flutter_jornadakids/app/models/usuario.dart';
import 'package:flutter_jornadakids/app/models/crianca.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';

class ChildrenListPage extends StatelessWidget {
  final Usuario responsavel;
  const ChildrenListPage({super.key, required this.responsavel});

  // Mock de crianças vinculadas ao responsável (pronto para API)
  List<Crianca> get _mockCriancas => [
    Crianca(
      id: 1,
      idUsuario: 3,
      dataNascimento: DateTime(2015, 5, 10),
      nivel: 2,
      xp: 120,
      xpTotal: 300,
      ponto: 80,
    ),
    Crianca(
      id: 2,
      idUsuario: 4,
      dataNascimento: DateTime(2012, 8, 22),
      nivel: 4,
      xp: 350,
      xpTotal: 800,
      ponto: 210,
    ),
  ];

  // Mock de usuários das crianças (pronto para API)
  List<Usuario> get _mockUsuariosCriancas => [
    Usuario(
      id: 3,
      nomeCompleto: 'Lucas Souza',
      nomeUsuario: 'lucas',
      email: 'lucas@email.com',
      telefone: '99999-3333',
      senha: '123456',
      tipoUsuario: TipoUsuario.crianca,
      criadoEm: DateTime(2015, 5, 10),
      atualizadoEm: DateTime.now(),
    ),
    Usuario(
      id: 4,
      nomeCompleto: 'Ana Lima',
      nomeUsuario: 'ana',
      email: 'ana@email.com',
      telefone: '99999-4444',
      senha: '123456',
      tipoUsuario: TipoUsuario.crianca,
      criadoEm: DateTime(2012, 8, 22),
      atualizadoEm: DateTime.now(),
    ),
  ];

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
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _mockCriancas.length,
        itemBuilder: (context, index) {
          final crianca = _mockCriancas[index];
          final usuario = _mockUsuariosCriancas.firstWhere((u) => u.id == crianca.idUsuario);
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
                        usuario.nomeCompleto,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.darkText),
                      ),
                      const SizedBox(height: 4),
                      Text('Nível: ${crianca.nivel}  •  Pontos: ${crianca.ponto}',
                        style: const TextStyle(fontSize: 14, color: AppColors.gray400)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms, delay: (index * 120).ms).slideY(begin: 0.08);
        },
      ),
    );
  }
} 