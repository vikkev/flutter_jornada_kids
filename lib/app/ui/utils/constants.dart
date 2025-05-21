import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF577BC1);
  static const Color secondary = Color(0xFF344CB7);
  static const Color darkText = Color(0xFF001858);
  static const Color darkBlue = Color(0xFF000957);

  // Tons de cinza
  static const Color lightGray = Color(0xFFF5F5F5);   // Bem claro
  static const Color gray100 = Color(0xFFE0E0E0);     // Um pouco mais escuro
  static const Color gray200 = Color(0xFFBDBDBD);     // Cinza médio
  static const Color gray300 = Color(0xFF9E9E9E);     // Cinza mais escuro
  static const Color gray400 = Color(0xFF757575);     // Próximo ao grafite
  static const Color grey = Color(0xFFCBCBCB);        // Cinza já existente
}

enum UserType { responsible, child }
