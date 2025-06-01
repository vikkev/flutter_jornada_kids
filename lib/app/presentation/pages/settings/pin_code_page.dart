import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';
import 'package:flutter_jornadakids/app/models/usuario.dart';
import 'package:flutter_jornadakids/app/models/responsavel.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';
import 'package:flutter_jornadakids/app/services/responsible_service.dart';

class PinCodePage extends StatefulWidget {
  final Usuario usuario;
  const PinCodePage({super.key, required this.usuario});

  @override
  State<PinCodePage> createState() => _PinCodePageState();
}

class _PinCodePageState extends State<PinCodePage> {
  late Future<ResponsibleInfo> _responsavelFuture;

  @override
  void initState() {
    super.initState();
    _responsavelFuture = ResponsibleService().fetchResponsible(widget.usuario.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Código PIN',
          style: TextStyle(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.darkBlue),
      ),
      body: FutureBuilder<ResponsibleInfo>(
        future: _responsavelFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: \\${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Responsável não encontrado.'));
          }
          final responsavel = snapshot.data!;
          return Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(28),
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
                  Icon(Icons.vpn_key, color: AppColors.primary, size: 48),
                  const SizedBox(height: 18),
                  const Text(
                    'Código PIN do responsável',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    responsavel.codigo.padLeft(6, '0'),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 4),
                  ).animate().fadeIn(duration: 700.ms).scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 18),
                  Text(
                    responsavel.usuario.nomeCompleto,
                    style: const TextStyle(fontSize: 16, color: AppColors.gray400),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Use este código para cadastrar uma criança/adolescente vinculada a este responsável. O PIN é único e serve para garantir a segurança do vínculo.',
                    style: TextStyle(fontSize: 14, color: AppColors.gray400),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.1),
          );
        },
      ),
    );
  }
} 