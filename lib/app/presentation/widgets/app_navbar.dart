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
  void _onItemTapped(int index) {
    widget.onPageChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 80,
      child: Stack(
        children: [
          // Barra principal com entalhe
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Entalhe circular onde está o ícone selecionado
                  if (widget.currentIndex >= 0)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutBack,
                      top: -25,
                      left: _getItemPosition(widget.currentIndex),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 0),
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Ícones da navbar
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(0, Icons.home, "Início", widget.currentIndex == 0),
                          _buildNavItem(1, Icons.check, "Tarefas", widget.currentIndex == 1),
                          _buildNavItem(2, Icons.star, "Prêmios", widget.currentIndex == 2),
                          _buildNavItem(3, Icons.settings, "Config", widget.currentIndex == 3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // FAB com ícone da aba selecionada
          if (widget.currentIndex >= 0)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              top: 0,
              left: _getItemPosition(widget.currentIndex) + 5,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A90E2).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                      spreadRadius: -1,
                    ),
                  ],
                ),
                child: Icon(
                  _getSelectedIcon(widget.currentIndex),
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _getItemPosition(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    const sidePadding = 30.0; // padding horizontal da Row
    
    // Largura disponível para os itens (sem considerar margin pois o Stack já está dentro do Container)
    final availableWidth = screenWidth - (sidePadding * 2) - 40; // 40 = margin total (20*2)
    final itemWidth = availableWidth / 4;
    
    // Posição do centro do item
    final itemCenterPosition = sidePadding + (itemWidth * index) + (itemWidth / 2);
    
    // Ajustar para centralizar o círculo de 60px de largura
    return itemCenterPosition - 30;
  }

  IconData _getSelectedIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.check;
      case 2:
        return Icons.star;
      case 3:
        return Icons.settings;
      default:
        return Icons.home;
    }
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedOpacity(
            opacity: isSelected ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              icon,
              size: 24,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? const Color(0xFF4A90E2) : Colors.grey.shade400,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}