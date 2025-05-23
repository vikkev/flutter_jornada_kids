import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';
import 'package:flutter_jornadakids/app/models/crianca.dart';

class ScoreWidget extends StatelessWidget {
  const ScoreWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock de dados de uma criança (futuramente virá da API)
    final Crianca crianca = Crianca(
      id: 1,
      idUsuario: 1,
      dataNascimento: DateTime(2014, 5, 10),
      nivel: 12,
      xp: 2000,
      xpTotal: 10000,
      ponto: 325,
    );

    final int currentPoints = crianca.xp;
    final int targetPoints = crianca.xpTotal;
    final int nivel = crianca.nivel;
    final int pontos = crianca.ponto;
    final double progressPercent = currentPoints / targetPoints;
    final double availableWidth = MediaQuery.of(context).size.width - 40;
    final double progressWidth = availableWidth * progressPercent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.grey,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título e pontuação
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Minha pontuação',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nível $nivel',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ).animate().fadeIn().slideX(begin: -0.2, duration: 500.ms),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: AppColors.primary, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '$pontos',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2, duration: 500.ms),
            ],
          ),
          const SizedBox(height: 20),

          // Barra de progresso animada
          Stack(
            children: [
              // Background da barra
              Container(
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withAlpha(51),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Barra preenchida animada
              Container(
                height: 22,
                width: 0, // inicia zerada
              ).animate().custom(
                duration: 800.ms,
                builder: (_, value, __) {
                  return Container(
                    width: progressWidth * value,
                    height: 22,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.secondary, AppColors.primary],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(77),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Ícone de estrela se movendo junto
              Positioned(
                left: 0,
                top: -4,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.star, color: Colors.white, size: 16),
                ).animate().custom(
                  duration: 800.ms,
                  builder: (_, value, __) {
                    return Transform.translate(
                      offset: Offset(progressWidth * value - 15, 0),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amber,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.star, color: Colors.white, size: 16),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Valores laterais
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(currentPoints / 1000).toStringAsFixed(0)}K',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText.withAlpha(179),
                ),
              ).animate().fadeIn(delay: 400.ms),
              Text(
                '${(targetPoints / 1000).toStringAsFixed(0)}K',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText.withAlpha(179),
                ),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ],
      ),
    );
  }
}
