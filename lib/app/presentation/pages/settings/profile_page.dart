import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_jornadakids/app/models/usuario.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';

class ProfilePage extends StatelessWidget {
  final Usuario usuario;
  const ProfilePage({super.key, required this.usuario});

  String _tipoUsuarioLabel(TipoUsuario tipo) {
    switch (tipo) {
      case TipoUsuario.crianca:
        return 'Criança/Adolescente';
      case TipoUsuario.responsavel:
        return 'Responsável';
    }
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
          'Meu Perfil',
          style: TextStyle(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.darkBlue),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primary.withOpacity(0.12),
                backgroundImage: usuario.avatar != null ? MemoryImage(usuario.avatar!) : null,
                child: usuario.avatar == null
                    ? Icon(Icons.person, size: 48, color: AppColors.primary)
                    : null,
              ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(height: 18),
              Text(
                usuario.nomeCompleto,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ),
              const SizedBox(height: 6),
              Text(
                usuario.email,
                style: const TextStyle(fontSize: 15, color: AppColors.gray400),
              ),
              const SizedBox(height: 6),
              Text(
                _tipoUsuarioLabel(usuario.tipoUsuario),
                style: TextStyle(fontSize: 14, color: AppColors.primary.withOpacity(0.85), fontWeight: FontWeight.w500),
              ),
              const Divider(height: 32, thickness: 1.2),
              _buildInfoRow(Icons.phone, usuario.telefone),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.calendar_today, 'Criado em: ${_formatDate(usuario.criadoEm)}'),
              _buildInfoRow(Icons.update, 'Atualizado em: ${_formatDate(usuario.atualizadoEm)}'),
            ],
          ),
        ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.1),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 15, color: AppColors.darkText),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }
} 