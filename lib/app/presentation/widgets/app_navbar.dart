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
    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        margin: const EdgeInsets.all(20),
        height: 90, // Aumentado de 80 para 90
        child: Stack(
          children: [
            // Barra principal com entalhe
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 70, // Aumentado de 60 para 70
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
                        top: -30, // Ajustado de -25 para -30 para manter proporção
                        left: _getItemPosition(widget.currentIndex),
                        child: Container(
                          width: 65, // Aumentado de 60 para 65
                          height: 65, // Aumentado de 60 para 65
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
                left: _getFabPosition(widget.currentIndex),
                child: Container(
                  width: 55, // Aumentado de 50 para 55
                  height: 55, // Aumentado de 50 para 55
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
                    size: 30, // Aumentado de 28 para 30
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _getItemPosition(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    const sidePadding = 30.0;
    
    final availableWidth = screenWidth - (sidePadding * 2) - 40;
    final itemWidth = availableWidth / 4;
    
    final itemCenterPosition = sidePadding + (itemWidth * index) + (itemWidth / 2);
    
    return itemCenterPosition - 30;
  }

  double _getFabPosition(int index) {
    // Usar o mesmo cálculo do entalhe, mas com ajuste específico por aba
    double basePosition = _getItemPosition(index);
    
    // Ajuste fino para cada aba
    switch (index) {
      case 0: // Início
        return basePosition + 3.5; // Ajustado para o novo tamanho
      case 1: // Tarefas  
        return basePosition + 2.5 ; // Ajustado para o novo tamanho
      case 2: // Prêmios
        return basePosition + 5.5;
      case 3: // Config
        return basePosition + 5.5;
      default:
        return basePosition + 5.5;
    }
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