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
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),
        iconTheme: const IconThemeData(color: AppColors.darkBlue),
      ),
      body: FutureBuilder<ResponsibleInfo>(
        future: _responsavelFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ).animate(onPlay: (controller) => controller.repeat())
                .rotate(duration: 1000.ms)
                .then()
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 500.ms)
                .then()
                .scale(begin: const Offset(1.2, 1.2), end: const Offset(1.0, 1.0), duration: 500.ms),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ).animate().shake(duration: 800.ms).fadeIn(),
                  const SizedBox(height: 16),
                  Text(
                    'Erro: ${snapshot.error}',
                    style: TextStyle(color: Colors.red.shade600),
                    textAlign: TextAlign.center,
                  ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ).animate().fadeIn().scale(begin: const Offset(0.5, 0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'Responsável não encontrado.',
                    style: TextStyle(color: Colors.grey),
                  ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),
                ],
              ),
            );
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
                  // Ícone com animação de entrada e pulsação
                  Icon(
                    Icons.vpn_key, 
                    color: AppColors.primary, 
                    size: 48
                  ).animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.5, 0.5), duration: 700.ms, curve: Curves.elasticOut)
                    .then(delay: 500.ms)
                    .shimmer(duration: 1500.ms, color: AppColors.primary.withOpacity(0.3))
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.05, 1.05), duration: 2000.ms),
                  
                  const SizedBox(height: 18),
                  
                  // Título com animação de slide
                  const Text(
                    'Código PIN do responsável',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: AppColors.darkText
                    ),
                  ).animate(delay: 200.ms)
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: -0.5, curve: Curves.easeOutCubic),
                  
                  const SizedBox(height: 10),
                  
                  // Código PIN com múltiplas animações
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Text(
                      responsavel.codigo.padLeft(6, '0'),
                      style: const TextStyle(
                        fontSize: 32, 
                        fontWeight: FontWeight.bold, 
                        color: AppColors.primary, 
                        letterSpacing: 4
                      ),
                    ),
                  ).animate(delay: 400.ms)
                    .fadeIn(duration: 800.ms)
                    .scale(begin: const Offset(0.3, 0.3), curve: Curves.elasticOut)
                    .then(delay: 300.ms)
                    .shimmer(duration: 2000.ms, color: AppColors.primary.withOpacity(0.5))
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.02, 1.02), duration: 3000.ms),
                  
                  const SizedBox(height: 18),
                  
                  // Nome do responsável
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 18,
                        color: AppColors.gray400,
                      ).animate(delay: 600.ms)
                        .fadeIn()
                        .rotate(begin: -0.1, end: 0.1, duration: 1000.ms, curve: Curves.easeInOut)
                        .animate(onPlay: (controller) => controller.repeat(reverse: true))
                        .rotate(begin: 0, end: 0.05, duration: 2000.ms),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          responsavel.usuario.nomeCompleto,
                          style: const TextStyle(fontSize: 16, color: AppColors.gray400),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ).animate(delay: 650.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, curve: Curves.easeOut),
                  
                  const SizedBox(height: 18),
                  
                  // Texto informativo com animação de typewriter
                  const Text(
                    'Use este código para cadastrar uma criança/adolescente vinculada a este responsável',
                    style: TextStyle(fontSize: 14, color: AppColors.gray400),
                    textAlign: TextAlign.center,
                  ).animate(delay: 800.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.5, curve: Curves.easeOut)
                    .then(delay: 200.ms)
                    .shimmer(duration: 2000.ms, color: AppColors.primary.withOpacity(0.2)),
                ],
              ),
            ).animate()
              .fadeIn(duration: 800.ms)
              .slideY(begin: 0.2, curve: Curves.easeOutCubic)
              .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOut),
          );
        },
      ),
    );
  }
}