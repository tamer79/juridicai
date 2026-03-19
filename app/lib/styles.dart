import 'package:flutter/material.dart';

class AppStyles {
  AppStyles._();

  // App
  static const String appTitle = 'JuridicAI';
  static const Color seedColor = Color(0xFF0E5F6B);

  // Cor de Fundo
  // S000.dart
  static const Color s000Background = Color.fromARGB(255, 0, 1, 78);
  static const Color s000DimOverlay = Color(0xCC000000);

  // Cores
  // S000.dart
  static const Color s000PrimaryText = Color(0xFF0F1E2B);
  static const Color s000SecondaryText = Color(0xFF5B6B7A);
  static const Color s000CardBorder = Color(0xFFD6DEE6);
  static const Color s000CardFill = Color(0xFFFFFFFF);
  static const Color s000ButtonFill = Color(0xFF0E5F6B);
  static const Color s000ButtonText = Color(0xFFFFFFFF);

  // Tipografia
  // S000.dart
  static const TextStyle s000Title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: s000PrimaryText,
    letterSpacing: 0.2,
  );
  static const TextStyle s000Subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: s000SecondaryText,
    height: 1.4,
  );
  static const TextStyle s000ButtonLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: s000ButtonText,
    letterSpacing: 0.2,
  );

  // Espaçamento
  // S000.dart
  static const EdgeInsets s000PagePadding = EdgeInsets.all(24);
  static const EdgeInsets s000CardPadding = EdgeInsets.all(20);
  static const SizedBox s000GapSmall = SizedBox(height: 8);
  static const SizedBox s000GapMedium = SizedBox(height: 16);
  static const SizedBox s000GapLarge = SizedBox(height: 24);

  // Bordas
  // S000.dart
  static const double s000CardRadius = 16;
  static const double s000ButtonRadius = 10;
  static const double s000CardBorderWidth = 5;
  static const double s000CircleBorderWidth = 5;

  // Dimensoes
  // S000.dart
  static const double s000CircleDiameter = 600;

  // Cores
  // S000.dart
  static const Color s000CircleFill = Color(0xFFFFFFFF);
  static const Color s000CircleBorder = Color.fromARGB(255, 0, 12, 180);

  // Animacao
  // S000.dart
  static const Duration s000CircleDelay = Duration(seconds: 2);
  static const Duration s000CircleFadeDuration = Duration(milliseconds: 400);
}
