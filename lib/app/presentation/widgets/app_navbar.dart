import 'package:flutter/material.dart';
import 'package:flutter_jornadakids/app/core/utils/constants.dart';

class AppBottomNavbar extends StatefulWidget {
  final Function(int) onPageChanged;
  final int currentIndex;

  const AppBottomNavbar({
    super.key,
    required this.onPageChanged,
    required this.currentIndex,
  });

  @override
  State<AppBottomNavbar> createState() => _AppBottomNavbarState();
}

class _AppBottomNavbarState extends State<AppBottomNavbar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onPageChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkBlue,
            const Color.fromARGB(255, 30, 51, 146),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home, widget.currentIndex == 0),
            _buildNavItem(1, Icons.book, widget.currentIndex == 1),
            _buildNavItem(2, Icons.star, widget.currentIndex == 2),
            _buildNavItem(3, Icons.settings, widget.currentIndex == 3),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNavItem(int index, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Círculo de fundo animado
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isSelected ? 44 : 0,
                  height: isSelected ? 44 : 0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.38),
                              AppColors.primary.withOpacity(0.18),
                              AppColors.secondary.withOpacity(0.22),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                  ),
                ),
                // Ícone com animação de escala
                AnimatedScale(
                  scale: isSelected ? 1.18 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    icon,
                    size: 28,
                    color: isSelected ? Colors.white : Colors.white.withAlpha(179),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Indicador circular abaixo do ícone selecionado
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSelected ? 8 : 0,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}