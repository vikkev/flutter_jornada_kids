import 'package:flutter/material.dart';
import 'package:flutter_jornadakids/app/ui/utils/constants.dart';

class AppBottomNavbar extends StatefulWidget {
  final Function(int) onPageChanged;
  
  const AppBottomNavbar({
    super.key,
    required this.onPageChanged,
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
        color: AppColors.darkBlue,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 35,top:10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home, _selectedIndex == 0),
            _buildNavItem(1, Icons.book, _selectedIndex == 1),
            _buildNavItem(2, Icons.star, _selectedIndex == 2),
            _buildNavItem(3, Icons.settings, _selectedIndex == 3),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNavItem(int index, IconData icon, bool isSelected) {
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Icon(
          icon,
          size: 28,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }
}