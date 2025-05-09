import 'package:flutter/material.dart';
import 'package:flutter_jornadakids/app/ui/utils/constants.dart';

class RankingWidget extends StatelessWidget {
  const RankingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ranking',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.people_alt_outlined, color: AppColors.primary, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Top 10',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),// Top 3 cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 2º Lugar
              _buildTopThreeCard(context, 2, '{nomecrianca}', 23232, Colors.grey.shade400),
              
              // 1º Lugar - Maior e destacado
              _buildTopThreeCard(context, 1, '{nomecrianca}', 323232, Colors.amber.shade600, isFirst: true),
              
              // 3º Lugar
              _buildTopThreeCard(context, 3, '{nomecrianca}', 12114, Colors.brown.shade300),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Linha divisória
          Container(
            height: 1,
            color: Colors.grey.withAlpha(51),
          ),
          
          const SizedBox(height: 16),
          
          // Lista de outros competidores
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: const [
                RankingItem(
                  position: 4,
                  name: '{nomecrianca}',
                  points: 10000,
                ),
                SizedBox(height: 12),
                RankingItem(
                  position: 5,
                  name: '{nomecrianca}',
                  points: 9850,
                ),
                SizedBox(height: 12),
                RankingItem(
                  position: 6,
                  name: '{nomecrianca}',
                  points: 8720,
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
  }) {
    final size = isFirst ? 100.0 : 85.0;
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
                color: medalColor.withAlpha(51),
                border: Border.all(color: medalColor, width: 2),
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
                        color: Colors.black.withAlpha(26),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: medalColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
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
            // Troféu para o primeiro lugar
            if (isFirst)
              Positioned(
                top: 0,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: Colors.amber.shade700,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              color: Colors.amber,
              size: iconSize,
            ),
            const SizedBox(width: 4),
            Text(
              _formatPoints(points),
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

  const RankingItem({
    super.key,
    required this.position,
    required this.name,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Posição
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary.withAlpha(26),
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
          ),
          const SizedBox(width: 16),
          
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.grey.withAlpha(77),
                width: 2,
              ),
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
          ),
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
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatPoints(points),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
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