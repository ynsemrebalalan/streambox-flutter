import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary:                    AppColors.accent,
          onPrimary:                  AppColors.darkBg,
          primaryContainer:           AppColors.darkSurfaceVariant,
          secondary:                  Color(0xFFE8A800),
          onSecondary:                AppColors.darkBg,
          surface:                    AppColors.darkSurface,
          surfaceContainerHighest:    AppColors.darkSurfaceVariant,
          onSurface:                  Colors.white,
          onSurfaceVariant:           AppColors.darkOnSurfaceVar,
          outline:                    AppColors.darkSurfaceVariant,
          error:                      Color(0xFFFF6B6B),
        ),
        scaffoldBackgroundColor: AppColors.darkBg,
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary:                    AppColors.darkBg,
          onPrimary:                  Colors.white,
          primaryContainer:           AppColors.darkSurfaceVariant,
          onPrimaryContainer:         Colors.white,
          secondary:                  Color(0xFF3A506B),
          onSecondary:                Colors.white,
          surface:                    AppColors.lightSurface,
          surfaceContainerHighest:    AppColors.lightSurfaceVariant,
          onSurface:                  AppColors.darkBg,
          onSurfaceVariant:           AppColors.lightOnSurfaceVar,
          outline:                    AppColors.lightOutline,
          error:                      AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.lightBg,
      );
}
