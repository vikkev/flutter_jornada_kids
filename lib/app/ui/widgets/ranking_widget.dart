import 'package:flutter/material.dart';
import 'package:flutter_jornadakids/app/ui/utils/constants.dart';

class RankingWidget extends StatelessWidget {
  const RankingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Ranking',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  RankingItem(
                    position: 1,
                    name: '{nomecrianca}',
                    points: 323232,
                  ),
                  SizedBox(height: 8),
                  RankingItem(
                    position: 2,
                    name: '{nomecrianca}',
                    points: 23232,
                  ),
                  SizedBox(height: 8),
                  RankingItem(
                    position: 3,
                    name: '{nomecrianca}',
                    points: 12114,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
    return Row(
      children: [
        Text(
          '$position',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 22),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade300,
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
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 25,
                ),
                const SizedBox(width: 4),
                Text(
                  '$points',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        if (position == 1)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(
              Icons.emoji_events,
              color: Colors.amber.shade700,
              size: 25,
            ),
          ),
      ],
    );
  }
}
