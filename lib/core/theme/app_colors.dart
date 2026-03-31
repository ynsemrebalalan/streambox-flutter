import 'package:flutter/material.dart';

abstract final class AppColors {
  // Vurgu — sarı
  static const Color accent    = Color(0xFFF5C518);
  static const Color accentDim = Color(0x33F5C518); // %20 alpha
  static const Color accentGlow= Color(0x50F5C518); // %31 alpha

  // Canlı yayın badge
  static const Color live    = Color(0xFFE53935);
  static const Color liveDim = Color(0x26E53935); // %15 alpha

  // Durum
  static const Color success    = Color(0xFF2E7D32);
  static const Color successDim = Color(0x264CAF50);
  static const Color error      = Color(0xFFD32F2F);
  static const Color errorDim   = Color(0x26D32F2F);

  // Dark tema palette
  static const Color darkBg             = Color(0xFF0C1526);
  static const Color darkSurface        = Color(0xFF142038);
  static const Color darkSurfaceVariant = Color(0xFF1B2D4F);
  static const Color darkOnSurfaceVar   = Color(0xFF7390B8);

  // Light tema palette
  static const Color lightBg             = Color(0xFFFFFFFF);
  static const Color lightSurface        = Color(0xFFF4F6FB);
  static const Color lightSurfaceVariant = Color(0xFFE8EDF7);
  static const Color lightOnSurfaceVar   = Color(0xFF3A506B);
  static const Color lightOutline        = Color(0xFFB0C4DE);
}
