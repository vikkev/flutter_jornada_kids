import 'package:flutter/material.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';
import 'package:flutter_jornadakids/app/models/crianca.dart';
import 'package:flutter_jornadakids/app/models/usuario.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';
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

  // Mock de ranking de crianças (poderia ser Usuario também)
  final List<Crianca> ranking = [
    Crianca(id: 1, idUsuario: 1, dataNascimento: DateTime(2014, 5, 10), nivel: 5, xp: 1200, xpTotal: 5000, ponto: 323232),
    Crianca(id: 2, idUsuario: 2, dataNascimento: DateTime(2013, 8, 22), nivel: 4, xp: 900, xpTotal: 4000, ponto: 23232),
    Crianca(id: 3, idUsuario: 3, dataNascimento: DateTime(2015, 2, 3), nivel: 3, xp: 700, xpTotal: 3000, ponto: 12114),
    Crianca(id: 4, idUsuario: 4, dataNascimento: DateTime(2012, 11, 15), nivel: 6, xp: 1500, xpTotal: 6000, ponto: 10000),
    Crianca(id: 5, idUsuario: 5, dataNascimento: DateTime(2016, 1, 20), nivel: 2, xp: 400, xpTotal: 2000, ponto: 9850),
    Crianca(id: 6, idUsuario: 6, dataNascimento: DateTime(2014, 7, 8), nivel: 2, xp: 350, xpTotal: 1800, ponto: 8720),
  ];

  // Mock de usuários das crianças (pronto para API)
  final List<Usuario> usuariosCrianca = [
    Usuario(
      id: 1,
      nomeCompleto: 'Lucas Souza',
      nomeUsuario: 'lucas',
      email: 'lucas@email.com',
      telefone: '99999-3333',
      senha: '123456',
      tipoUsuario: TipoUsuario.crianca,
      criadoEm: DateTime(2014, 5, 10),
      atualizadoEm: DateTime.now(),
    ),
    Usuario(
      id: 2,
      nomeCompleto: 'Ana Lima',
      nomeUsuario: 'ana',
      email: 'ana@email.com',
      telefone: '99999-4444',
      senha: '123456',
      tipoUsuario: TipoUsuario.crianca,
      criadoEm: DateTime(2013, 8, 22),
      atualizadoEm: DateTime.now(),
    ),
    Usuario(
      id: 3,
      nomeCompleto: 'Pedro Martins',
      nomeUsuario: 'pedro',
      email: 'pedro@email.com',
      telefone: '99999-5555',
      senha: '123456',
      tipoUsuario: TipoUsuario.crianca,
      criadoEm: DateTime(2015, 2, 3),
      atualizadoEm: DateTime.now(),
    ),
    Usuario(
      id: 4,
      nomeCompleto: 'Julia Alves',
      nomeUsuario: 'julia',
      email: 'julia@email.com',
      telefone: '99999-6666',
      senha: '123456',
      tipoUsuario: TipoUsuario.crianca,
      criadoEm: DateTime(2012, 11, 15),
      atualizadoEm: DateTime.now(),
    ),
    Usuario(
      id: 5,
      nomeCompleto: 'Rafaela Costa',
      nomeUsuario: 'rafaela',
      email: 'rafaela@email.com',
      telefone: '99999-7777',
      senha: '123456',
      tipoUsuario: TipoUsuario.crianca,
      criadoEm: DateTime(2016, 1, 20),
      atualizadoEm: DateTime.now(),
    ),
    Usuario(
      id: 6,
      nomeCompleto: 'Bruno Dias',
      nomeUsuario: 'bruno',
      email: 'bruno@email.com',
      telefone: '99999-8888',
      senha: '123456',
      tipoUsuario: TipoUsuario.crianca,
      criadoEm: DateTime(2014, 7, 8),
      atualizadoEm: DateTime.now(),
    ),
  ];

  String getNomeCrianca(int idUsuario) {
    return usuariosCrianca.firstWhere(
      (u) => u.id == idUsuario,
      orElse: () => Usuario(id: 0, nomeCompleto: 'Desconhecido', nomeUsuario: '', email: '', telefone: '', senha: '', tipoUsuario: TipoUsuario.crianca, criadoEm: DateTime.now(), atualizadoEm: DateTime.now()),
    ).nomeCompleto;
  }

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
    // Ordena por pontos decrescentes
    final sortedRanking = List<Crianca>.from(ranking)
      ..sort((a, b) => b.ponto.compareTo(a.ponto));
    final top3 = sortedRanking.take(3).toList();
    final others = sortedRanking.skip(3).toList();

    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
          ],
          border: Border.all(
            color: AppColors.grey.withOpacity(0.3),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header do ranking
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ranking',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ).animate()
                  .fade(duration: 500.ms)
                  .slideX(begin: -0.2, duration: 500.ms, curve: Curves.easeOut),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withAlpha(50),
                        AppColors.primary.withAlpha(100),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(40),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people_alt_outlined, color: AppColors.primary, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'Top 10',
                        style: TextStyle(
                          fontSize: 12,
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
            const SizedBox(height: 16),
            
            // Top 3 em tamanho compacto
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 140, // Altura fixa menor
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 2º Lugar
                      if (top3.length > 1)
                        _buildTopThreeCard(context, 2, top3[1], Colors.grey.shade400, animationDelay: 400),
                      // 1º Lugar - Maior e destacado
                      if (top3.isNotEmpty)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            _buildTopThreeCard(context, 1, top3[0], Colors.amber.shade600, isFirst: true, animationDelay: 0),
                            // Controlador de confete acima do primeiro lugar
                            Positioned(
                              top: -10,
                              child: ConfettiWidget(
                                confettiController: _confettiController,
                                blastDirection: math.pi / 2, // para baixo
                                emissionFrequency: 0.05,
                                numberOfParticles: 15,
                                maxBlastForce: 15,
                                minBlastForce: 8,
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
                      if (top3.length > 2)
                        _buildTopThreeCard(context, 3, top3[2], Colors.brown.shade300, animationDelay: 800),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Linha divisória compacta
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.grey.withAlpha(80),
                    Colors.grey.withAlpha(80),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.2, 0.8, 1.0],
                ),
              ),
            ).animate()
              .fadeIn(duration: 800.ms, delay: 1200.ms),
              
            const SizedBox(height: 12),
            
            // Lista de outros competidores - ocupa o resto do espaço
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: others.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final crianca = others[index];
                  return RankingItem(
                    position: index + 4,
                    name: getNomeCrianca(crianca.idUsuario),
                    points: crianca.ponto,
                    animationDelay: 100 + index * 150,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopThreeCard(
    BuildContext context,
    int position,
    Crianca crianca,
    Color medalColor, {
    bool isFirst = false,
    int animationDelay = 0,
  }) {
    final size = isFirst ? 85.0 : 70.0; // Tamanhos menores
    final fontSize = isFirst ? 14.0 : 12.0;
    final iconSize = isFirst ? 18.0 : 16.0;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Medal compacta
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
                border: Border.all(color: medalColor, width: isFirst ? 2.5 : 2),
                boxShadow: [
                  BoxShadow(
                    color: medalColor.withAlpha(isFirst ? 80 : 50),
                    blurRadius: isFirst ? 8 : 5,
                    spreadRadius: isFirst ? 1 : 0,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: size * 0.75,
                  height: size * 0.75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/default_avatar.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.person, size: size * 0.4);
                      },
                    ),
                  ),
                ),
              ),
            ),
            // Posição
            Positioned(
              bottom: -5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      medalColor,
                      medalColor.withAlpha(220),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  '#$position',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            // Troféu para o primeiro lugar
            if (isFirst)
              Positioned(
                top: 0,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withAlpha(80),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: Colors.amber.shade700,
                    size: 16,
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.7)),
          ],
        )
        .animate()
        .fade(duration: 600.ms, delay: Duration(milliseconds: animationDelay))
        .scale(begin: const Offset(0.7, 0.7)),
        
        const SizedBox(height: 8),
        
        // Nome compacto
        Text(
          getNomeCrianca(crianca.idUsuario),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 4),
        
        // Pontos
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              color: Colors.amber.shade500,
              size: iconSize,
            ),
            const SizedBox(width: 4),
            Text(
              _formatPoints(crianca.ponto),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.withAlpha(15),
            Colors.grey.withAlpha(25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Posição
          Container(
            width: 28,
            height: 28,
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
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ),
            
          const SizedBox(width: 12),
          
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.grey.withAlpha(100),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/default_avatar.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.person, size: 20);
                },
              ),
            ),
          ),
            
          const SizedBox(width: 12),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber.shade400,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$points pontos',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkText.withAlpha(150),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Pontuação destacada
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withAlpha(40),
                  AppColors.primary.withAlpha(80),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _formatPoints(points),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: Duration(milliseconds: animationDelay))
      .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuad, duration: 500.ms);
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