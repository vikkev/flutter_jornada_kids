import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_jornadakids/app/presentation/pages/achievments/achievments_page.dart';
import 'package:flutter_jornadakids/app/presentation/pages/settings/settings_page.dart';
import 'package:flutter_jornadakids/app/models/enums.dart';
import 'package:flutter_jornadakids/app/models/usuario.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart' as constants;
import 'package:flutter_jornadakids/app/presentation/widgets/app_navbar.dart';
import 'package:flutter_jornadakids/app/presentation/widgets/create_task_widget.dart';
import 'package:flutter_jornadakids/app/presentation/widgets/ranking_widget.dart';
import 'package:flutter_jornadakids/app/presentation/widgets/score_widget.dart';
import 'package:flutter_jornadakids/app/presentation/pages/tasks/tasks_page.dart';

class HomePage extends StatefulWidget {
  final Usuario usuario;

  const HomePage({super.key, required this.usuario});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

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
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          _buildMainPage(),
          TasksPage(userType: widget.usuario.tipoUsuario),
          AchievementsPage(userType: widget.usuario.tipoUsuario),
          SettingsPage(usuario: widget.usuario),
        ],
      ),
      bottomNavigationBar: AppBottomNavbar(
        onPageChanged: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  Widget _buildMainPage() {
    return SafeArea(
      child: Column(
        children: [
          // Header azul decorativo (opcional, pode ser removido ou deixado só como topo)
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  constants.AppColors.primary,
                  constants.AppColors.primary.withOpacity(0.8),
                ],
              ),
            ),
          ),
          // Conteúdo principal
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card compacto para avatar e saudação centralizado
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Avatar menor
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    constants.AppColors.primary.withOpacity(0.18),
                                    constants.AppColors.primary.withOpacity(0.08),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: constants.AppColors.primary.withOpacity(0.18),
                                  width: 2,
                                ),
                              ),
                              child: widget.usuario.avatar != null
                                  ? ClipOval(child: Image.memory(widget.usuario.avatar!, fit: BoxFit.cover))
                                  : Icon(
                                      widget.usuario.tipoUsuario == TipoUsuario.responsavel
                                          ? Icons.supervisor_account
                                          : Icons.child_care,
                                      color: constants.AppColors.primary,
                                      size: 24,
                                    ),
                            ),
                            const SizedBox(width: 16),
                            // Saudação e nome centralizados
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _getGreeting(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: constants.AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.usuario.nomeCompleto,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Widget principal (CreateTask ou Score)
                      if (widget.usuario.tipoUsuario == TipoUsuario.responsavel)
                        const CreateTaskWidget()
                            .animate()
                            .fadeIn(delay: 700.ms, duration: 600.ms)
                            .slideY(begin: 0.3, end: 0)
                      else
                        const ScoreWidget()
                            .animate()
                            .fadeIn(delay: 700.ms, duration: 600.ms)
                            .slideY(begin: 0.3, end: 0),
                      const SizedBox(height: 20),
                      // Ranking
                      SizedBox(
                        height: 600,
                        child: const RankingWidget()
                            .animate()
                            .fadeIn(delay: 900.ms, duration: 600.ms)
                            .slideY(begin: 0.3, end: 0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bom dia,';
    } else if (hour < 18) {
      return 'Boa tarde,';
    } else {
      return 'Boa noite,';
    }
  }
}