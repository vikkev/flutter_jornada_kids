import 'package:flutter/material.dart';
import 'package:flutter_jornadakids/app/ui/utils/constants.dart';
import 'package:flutter_jornadakids/app/ui/widgets/app_navbar.dart';
import 'package:flutter_jornadakids/app/ui/widgets/create_task_widget.dart';
import 'package:flutter_jornadakids/app/ui/widgets/ranking_widget.dart';
import 'package:flutter_jornadakids/app/ui/widgets/score_widget.dart';


class HomePage extends StatelessWidget {
  final UserType userType;
  final String username;
  
  const HomePage({
    super.key, 
    required this.userType,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      bottomNavigationBar: const AppBottomNavbar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              // color: AppColors.secondary,
              child: Text(
                'Olá $username',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Conditional widget based on user type
                    if (userType == UserType.responsible)
                      const CreateTaskWidget()
                    else
                      const ScoreWidget(),
                    const SizedBox(height: 16),
                    const RankingWidget(),
                  ],
                ),
              ),
            ),
            // Bottom Navigation Bar
          ],
        ),
      ),
    );
  }
}