import 'package:flutter/material.dart';
import 'package:flutter_jornadakids/app/ui/utils/constants.dart';
import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RankingWidget extends StatefulWidget {
  const RankingWidget({super.key});

  @override
  State<RankingWidget> createState() => _RankingWidgetState();
}

class _RankingWidgetState extends State<RankingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late ConfettiController _confettiController;
  
  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    
    // Dispara confete quando o widget é construído
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 550,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 2,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ranking',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ).animate()
                .fade(duration: 500.ms)
                .slideX(begin: -0.2, duration: 500.ms, curve: Curves.easeOut),
                
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withAlpha(50),
                      AppColors.primary.withAlpha(100),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(40),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people_alt_outlined, color: AppColors.primary, size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      'Top 10',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ).animate(onPlay: (controller) => controller.repeat())
                      .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.5)),
                  ],
                ),
              ).animate()
                .fade(duration: 700.ms, delay: 200.ms)
                .scale(begin: const Offset(0.8, 0.8)),
            ],
          ),
          const SizedBox(height: 24),
          
          // Top 3 cards com efeito de confete para o primeiro lugar
          Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 2º Lugar
                  _buildTopThreeCard(context, 2, '{nomecrianca}', 23232, 
                    Colors.grey.shade400, animationDelay: 400),
                  
                  // 1º Lugar - Maior e destacado
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildTopThreeCard(context, 1, '{nomecrianca}', 323232, 
                        Colors.amber.shade600, isFirst: true, animationDelay: 0),
                      
                      // Controlador de confete acima do primeiro lugar
                      Positioned(
                        top: -20,
                        child: ConfettiWidget(
                          confettiController: _confettiController,
                          blastDirection: math.pi / 2, // para baixo
                          emissionFrequency: 0.05,
                          numberOfParticles: 20,
                          maxBlastForce: 20,
                          minBlastForce: 10,
                          gravity: 0.2,
                          colors: const [
                            Colors.amber,
                            Colors.red,
                            Colors.blue,
                            Colors.green,
                            Colors.purple,
                            Colors.orange,
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // 3º Lugar
                  _buildTopThreeCard(context, 3, '{nomecrianca}', 12114, 
                    Colors.brown.shade300, animationDelay: 800),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Linha divisória com gradiente
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.withAlpha(100),
                  Colors.grey.withAlpha(100),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.2, 0.8, 1.0],
              ),
            ),
          ).animate()
            .fadeIn(duration: 800.ms, delay: 1200.ms)
            .shimmer(color: Colors.white.withOpacity(0.3), duration: 1200.ms),
          
          const SizedBox(height: 16),
          
          // Lista de outros competidores
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                RankingItem(
                  position: 4,
                  name: '{nomecrianca}',
                  points: 10000,
                  animationDelay: 100,
                ),
                const SizedBox(height: 12),
                RankingItem(
                  position: 5,
                  name: '{nomecrianca}',
                  points: 9850,
                  animationDelay: 300,
                ),
                const SizedBox(height: 12),
                RankingItem(
                  position: 6,
                  name: '{nomecrianca}',
                  points: 8720,
                  animationDelay: 500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTopThreeCard(
    BuildContext context,
    int position,
    String name,
    int points,
    Color medalColor, {
    bool isFirst = false,
    int animationDelay = 0,
  }) {
    final size = isFirst ? 110.0 : 90.0;
    final fontSize = isFirst ? 16.0 : 14.0;
    final iconSize = isFirst ? 26.0 : 22.0;
    
    return Column(
      children: [
        // Medal
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    medalColor.withAlpha(isFirst ? 80 : 60),
                    medalColor.withAlpha(isFirst ? 120 : 90),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: medalColor, width: isFirst ? 3 : 2),
                boxShadow: [
                  BoxShadow(
                    color: medalColor.withAlpha(isFirst ? 100 : 60),
                    blurRadius: isFirst ? 10 : 6,
                    spreadRadius: isFirst ? 2 : 1,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: size * 0.8,
                  height: size * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/default_avatar.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.person, size: size * 0.5);
                      },
                    ),
                  ),
                ),
              ),
            ),
            // Posição
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      medalColor,
                      medalColor.withAlpha(220),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '#$position',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Troféu animado para o primeiro lugar
            if (isFirst)
              Positioned(
                top: 0,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withAlpha(100),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: Colors.amber.shade700,
                    size: 24,
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.7))
                .then()
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.2, 1.2),
                  duration: 1000.ms,
                ).then()
                .scale(
                  begin: const Offset(1.2, 1.2),
                  end: const Offset(1.0, 1.0),
                  duration: 1000.ms,
                ),
          ],
        )
        .animate()
        .fade(duration: 600.ms, delay: Duration(milliseconds: animationDelay))
        .scale(begin: const Offset(0.7, 0.7)),
        
        const SizedBox(height: 10),
        Text(
          name,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              color: Colors.amber.shade500,
              size: iconSize,
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
              .rotate(begin: -0.05, end: 0.05, duration: 1000.ms),
            const SizedBox(width: 6),
            Text(
              _formatPoints(points),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                foreground: isFirst ? (Paint()
                  ..shader = LinearGradient(
                    colors: [
                      AppColors.primary,
                      Colors.purple.shade700,
                    ],
                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 100.0, 30.0))) 
                : Paint()..color = AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  String _formatPoints(int points) {
    if (points >= 1000000) {
      return '${(points / 1000000).toStringAsFixed(1)}M';
    } else if (points >= 1000) {
      return '${(points / 1000).toStringAsFixed(1)}K';
    }
    return points.toString();
  }
}

class RankingItem extends StatelessWidget {
  final int position;
  final String name;
  final int points;
  final int animationDelay;

  const RankingItem({
    super.key,
    required this.position,
    required this.name,
    required this.points,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.withAlpha(20),
            Colors.grey.withAlpha(35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Posição
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withAlpha(40),
                  AppColors.secondary.withAlpha(80),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                '$position',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ).animate(onPlay: (controller) => controller.loop(count: 1))
            .shimmer(duration: 1200.ms, delay: Duration(milliseconds: animationDelay + 300)),
            
          const SizedBox(width: 16),
          
          // Avatar com borda pulsante
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.grey.withAlpha(120),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/default_avatar.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.person);
                },
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scaleXY(begin: 1, end: 1.05, duration: 2000.ms),
            
          const SizedBox(width: 16),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber.shade400,
                      size: 18,
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .rotate(begin: -0.05, end: 0.05, duration: 1000.ms),
                    const SizedBox(width: 6),
                    Text(
                      '$points pontos',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.darkText.withAlpha(179),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Pontuação destacada
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withAlpha(40),
                  AppColors.primary.withAlpha(80),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(30),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _formatPoints(points),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ).animate()
            .shimmer(delay: Duration(milliseconds: animationDelay + 600), duration: 1500.ms),
        ],
      ),
    ).animate()
      .fadeIn(delay: Duration(milliseconds: animationDelay))
      .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuad, duration: 600.ms);
  }
  
  String _formatPoints(int points) {
    if (points >= 1000000) {
      return '${(points / 1000000).toStringAsFixed(1)}M';
    } else if (points >= 1000) {
      return '${(points / 1000).toStringAsFixed(1)}K';
    }
    return points.toString();
  }
}