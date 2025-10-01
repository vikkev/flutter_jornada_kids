import 'package:flutter/material.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_jornadakids/app/services/api_config.dart';
import 'package:flutter_jornadakids/app/services/responsible_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_jornadakids/app/models/usuario.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';

class RankingWidget extends StatefulWidget {
  final Usuario? usuario;

  const RankingWidget({super.key, this.usuario});

  @override
  State<RankingWidget> createState() => _RankingWidgetState();
}

class _RankingWidgetState extends State<RankingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late ConfettiController _confettiController;

  List<ChildInfo> ranking = [];
  bool isLoading = true;
  String? errorMsg;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });

    _loadRanking();
  }

  Future<void> _loadRanking() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      int? idResponsavel;
      int? idCrianca;

      // Obtenha o usuário do widget ou de outro local conforme sua arquitetura
      final usuario = widget.usuario;
      if (usuario != null) {
        if (usuario.tipoUsuario == TipoUsuario.responsavel) {
          idResponsavel = usuario.idExterno ?? usuario.id;
        } else {
          idCrianca = usuario.idExterno ?? usuario.id;
        }
      }

      if (idResponsavel != null) {
        ranking = await ResponsibleService().fetchChildren(idResponsavel);
      } else if (idCrianca != null) {
        final dio = Dio();
        final url = '${ApiConfig.api}/criancas/$idCrianca';
        final response = await dio.get(url);
        if (response.statusCode == 200 && response.data != null) {
          final responsavel = response.data['responsavel'];
          if (responsavel != null && responsavel['id'] != null) {
            idResponsavel = responsavel['id'];
            ranking = await ResponsibleService().fetchChildren(idResponsavel!);
          } else {
            throw Exception(
              'Responsável não encontrado para esta criança/adolescente',
            );
          }
        } else {
          throw Exception('Erro ao buscar dados da criança/adolescente');
        }
      } else {
        throw Exception('Usuário não identificado');
      }
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMsg = e.toString();
      });
    }
  }

  String getNomeCrianca(ChildInfo crianca) {
    return crianca.nome;
  }

  @override
  void dispose() {
    // Adicione este check para evitar scheduleFrameCallback após dispose
    if (_shimmerController.isAnimating) {
      _shimmerController.stop();
    }
    _confettiController.stop();
    _shimmerController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMsg != null) {
      return Center(
        child: Text(errorMsg!, style: const TextStyle(color: Colors.red)),
      );
    }
    // Ordena por pontos decrescentes
    final sortedRanking = List<ChildInfo>.from(ranking)
      ..sort((a, b) => (b.ponto ?? 0).compareTo(a.ponto ?? 0));
    final top3 = sortedRanking.take(3).toList();
    final others = sortedRanking.skip(3).toList();

    // Preenche o top3 com placeholders se houver menos de 3 crianças
    final List<Widget> podium = [];
    for (int i = 0; i < 3; i++) {
      if (i < top3.length) {
        podium.add(
          _buildTopThreeCard(
            context,
            i + 1,
            top3[i],
            i == 0
                ? Colors.amber.shade600
                : (i == 1 ? Colors.grey.shade400 : Colors.brown.shade300),
            isFirst: i == 0,
            animationDelay: i * 400,
          ),
        );
      } else {
        podium.add(_buildPodiumPlaceholder(i + 1));
      }
    }

    // Remover todas as animações e confetti para garantir compatibilidade em dispositivos físicos
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
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
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
                    children: const [
                      Icon(
                        Icons.people_alt_outlined,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Top 10',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Top 3 em tamanho compacto (sem confetti e sem animate)
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: podium,
                  ),
                ),
                // Removido ConfettiWidget
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
            ),

            const SizedBox(height: 12),

            // Lista de outros competidores - ocupa o resto do espaço
            Expanded(
              child: others.isEmpty
                  ? Center(
                      child: Text(
                        ranking.length == 1
                            ? 'Só há uma criança/adolescente vinculada ao responsável.'
                            : 'Nenhum competidor extra no ranking.',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: others.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final crianca = others[index];
                        return RankingItem(
                          position: index + 4,
                          name: getNomeCrianca(crianca),
                          points: crianca.ponto ?? 0,
                          animationDelay: 0,
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
    ChildInfo crianca,
    Color medalColor, {
    bool isFirst = false,
    int animationDelay = 0,
  }) {
    final size = isFirst ? 85.0 : 70.0;
    final fontSize = isFirst ? 14.0 : 12.0;
    final iconSize = isFirst ? 18.0 : 16.0;

    IconData? customIcon;
    if (position == 1) {
      customIcon = Icons.emoji_events;
    } else if (position == 2) {
      customIcon = Icons.star;
    } else if (position == 3) {
      customIcon = Icons.military_tech;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
                border: Border.all(
                  color: medalColor,
                  width: isFirst ? 2.5 : 2,
                ),
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
            if (customIcon != null)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: medalColor.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Icon(customIcon, color: medalColor, size: 18),
                ),
              ),
            Positioned(
              bottom: -5,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [medalColor, medalColor.withAlpha(220)],
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
            // Removido shimmer/troféu animado
          ],
        ),
        const SizedBox(height: 8),
        Text(
          getNomeCrianca(crianca),
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events,
              color: Colors.orange.shade400,
              size: iconSize,
            ),
            const SizedBox(width: 4),
            Text(
              '${_formatPoints(crianca.ponto ?? 0)} pontos',
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

  Widget _buildPodiumPlaceholder(int position) {
    Color medalColor;
    switch (position) {
      case 1:
        medalColor = Colors.amber.shade200;
        break;
      case 2:
        medalColor = Colors.grey.shade300;
        break;
      case 3:
        medalColor = Colors.brown.shade100;
        break;
      default:
        medalColor = Colors.grey.shade200;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: position == 1 ? 85.0 : 70.0,
          height: position == 1 ? 85.0 : 70.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: medalColor,
            border: Border.all(
              color: medalColor,
              width: position == 1 ? 2.5 : 2,
            ),
          ),
          child: Icon(
            Icons.person_outline,
            color: Colors.white54,
            size: position == 1 ? 38 : 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Vazio',
          style: TextStyle(
            fontSize: position == 1 ? 14.0 : 12.0,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              color: Colors.grey.shade300,
              size: position == 1 ? 18.0 : 16.0,
            ),
            const SizedBox(width: 4),
            Text(
              '--',
              style: TextStyle(
                fontSize: position == 1 ? 14.0 : 12.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade300,
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
          colors: [Colors.grey.withAlpha(15), Colors.grey.withAlpha(25)],
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
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
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
            child: Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.orange.shade400,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_formatPoints(points)} pontos',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

// CORREÇÃO: 
// Se você estiver usando `.animate(onPlay: (controller) => controller.repeat(reverse: true))` ou `.shimmer(...)` 
// em algum widget, certifique-se de que o parâmetro `opacity` passado para qualquer widget (por exemplo, `Opacity` ou `AnimatedOpacity`) 
// nunca seja menor que 0.0 ou maior que 1.0. 
// 
// Se você estiver usando TweenAnimationBuilder, Tween<double>(begin: 0.0, end: 1.0) é seguro.
// 
// Se você estiver usando `.opacity(value)` ou `.fadeIn()`, garanta que o valor nunca seja negativo ou acima de 1.0.
//
// Se o erro persistir, revise se algum valor de animação customizada está fora do intervalo [0.0, 1.0].
//
// Exemplo de ajuste defensivo:
// Opacity(opacity: value.clamp(0.0, 1.0).toDouble(), child: ...)