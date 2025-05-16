import 'package:flutter/material.dart';
import 'package:flutter_jornadakids/app/ui/pages/achievments/achievments_page.dart';
import 'package:flutter_jornadakids/app/ui/pages/settings/settings_page.dart';
import 'package:flutter_jornadakids/app/ui/utils/constants.dart' as constants;
import 'package:flutter_jornadakids/app/ui/widgets/app_navbar.dart';
import 'package:flutter_jornadakids/app/ui/widgets/create_task_widget.dart';
import 'package:flutter_jornadakids/app/ui/widgets/ranking_widget.dart';
import 'package:flutter_jornadakids/app/ui/widgets/score_widget.dart';
import 'package:flutter_jornadakids/app/ui/pages/tasks/tasks_page.dart';

class HomePage extends StatefulWidget {
  final constants.UserType userType;
  final String username;

  const HomePage({super.key, required this.userType, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constants.AppColors.primary,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildMainPage(),
          TasksPage(userType: widget.userType),
          AchievementsPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: AppBottomNavbar(
        onPageChanged: (index) {
          _pageController.jumpToPage(index);
        },
      ),
    );
  }

  Widget _buildMainPage() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Olá ${widget.username}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 1),
                    if (widget.userType == constants.UserType.responsible)
                      const CreateTaskWidget()
                    else
                      const ScoreWidget(),
                    const SizedBox(height: 6),
                    const RankingWidget(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
