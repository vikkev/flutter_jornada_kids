import 'package:flutter/material.dart';
import 'package:flutter_jornadakids/app/ui/utils/constants.dart';

class ScoreWidget extends StatelessWidget {
  const ScoreWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Minha pontuação',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nível 324',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.secondary,
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                child: Text(
                  '323232/400000',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white, // ou qualquer outra cor
                  ),
                ),
              ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '325',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}