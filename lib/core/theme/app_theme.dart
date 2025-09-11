import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Configuración centralizada de colores para temas claro y oscuro
class AppColors {
  // Colores principales
  static const Color primary = Color(0xFFE0BD55);
  static const Color primaryDark = Color(0xFFE0BD55);
  static const Color primaryAcent = Color(0xFFB89B43);
  static const Color dark = Color(0xFF121212);
  static const Color onDark = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF757575);
  static const Color tertiary = Color(0xFFE0E0E0);
  static const Color onTertiary = Color(0xFF121212);

  // Tema claro
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF8F9FA);
  static const Color lightCardBackground = Color(0xFFF1F1F1);
  static const Color lightCardBackgroundFaint = Color(0xFFFAFAFA);
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightTextHint = Color(0xFF9E9E9E);
  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightInputBackground = Color(0xFFF5F5F5);
  static const Color lightInputBorder = Color(0xFFE0E0E0);

  // Tema oscuro
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCardBackground = Color(0xFF424242);
  static const Color darkCardBackgroundFaint = Color(0xFF333333);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFADADAD);
  static const Color darkTextHint = Color(0xFF666666);
  static const Color darkDivider = Color(0xFF333333);
  static const Color darkInputBackground = Color(0xFF2C2C2C);
  static const Color darkInputBorder = Color(0xFF404040);
  static const Color darkError = Color(0xFFFF7369);
  static const Color lightError = Color(0xFFF44336);
  static const Color darkSuccess = Color(0xFF70D373);
  static const Color lightSuccess = Color(0xFF4CAA4F);
  static const Color darkWarning = Color(0xFFFFB649);
  static const Color lightWarning = Color(0xFFE28800);

  // Colores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
}

/// Configuración centralizada de tipografías
class AppFonts {
  // Fuentes principales
  static const String catleyaSignature = 'CatleyaSignature';
  static const String oswald = 'Oswald';
  static const String montserrat = 'Montserrat';

  // Estilos para splash screen
  static const TextStyle weeklyTextLight = TextStyle(
    fontFamily: catleyaSignature,
    fontSize: 120,
    color: AppColors.lightTextSecondary,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle weeklyTextDark = TextStyle(
    fontFamily: catleyaSignature,
    fontSize: 120,
    color: AppColors.darkTextSecondary,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle menuTextLight = TextStyle(
    fontFamily: oswald,
    fontSize: 60,
    color: AppColors.lightTextSecondary,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle menuTextDark = TextStyle(
    fontFamily: oswald,
    fontSize: 60,
    color: AppColors.darkTextSecondary,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle sloganTextLight = TextStyle(
    fontFamily: oswald,
    fontSize: 22,
    color: AppColors.lightTextSecondary,
    fontWeight: FontWeight.w300,
  );

  static const TextStyle sloganTextDark = TextStyle(
    fontFamily: oswald,
    fontSize: 22,
    color: AppColors.darkTextSecondary,
    fontWeight: FontWeight.w300,
  );

  // Estilos para login y resto de la app con Montserrat
  static const TextStyle headlineLargeLight = TextStyle(
    fontFamily: montserrat,
    fontSize: 32,
    color: AppColors.lightTextPrimary,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headlineLargeDark = TextStyle(
    fontFamily: montserrat,
    fontSize: 32,
    color: AppColors.darkTextPrimary,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headlineMediumLight = TextStyle(
    fontFamily: montserrat,
    fontSize: 28,
    color: AppColors.lightTextPrimary,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headlineMediumDark = TextStyle(
    fontFamily: montserrat,
    fontSize: 28,
    color: AppColors.darkTextPrimary,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLargeLight = TextStyle(
    fontFamily: montserrat,
    fontSize: 16,
    color: AppColors.lightTextSecondary,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyLargeDark = TextStyle(
    fontFamily: montserrat,
    fontSize: 16,
    color: AppColors.darkTextSecondary,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyMediumLight = TextStyle(
    fontFamily: montserrat,
    fontSize: 14,
    color: AppColors.lightTextSecondary,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyMediumDark = TextStyle(
    fontFamily: montserrat,
    fontSize: 14,
    color: AppColors.darkTextSecondary,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle buttonTextLight = TextStyle(
    fontFamily: montserrat,
    fontSize: 16,
    color: AppColors.lightTextPrimary,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle buttonTextDark = TextStyle(
    fontFamily: montserrat,
    fontSize: 16,
    color: AppColors.darkTextPrimary,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle inputTextDark = TextStyle(
    fontFamily: montserrat,
    fontSize: 16,
    color: AppColors.darkTextPrimary,
  );

  static const TextStyle inputTextLight = TextStyle(
    fontFamily: montserrat,
    fontSize: 16,
    color: AppColors.lightTextPrimary,
  );

  static const TextStyle errorTextLight = TextStyle(
    fontFamily: montserrat,
    fontSize: 16,
    color: AppColors.lightError,
  );

  static const TextStyle errorTextDark = TextStyle(
    fontFamily: montserrat,
    fontSize: 16,
    color: AppColors.darkError,
  );
}

/// Configuración de temas de la aplicación
class AppTheme {
  /// Tema claro
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.lightTextSecondary,
        surface: AppColors.lightSurface,
        background: AppColors.lightBackground,
        error: AppColors.lightError,
        scrim: AppColors.lightSuccess,
        surfaceVariant: AppColors.lightWarning,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
        onBackground: AppColors.lightTextPrimary,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCardBackground,
        surfaceTintColor: AppColors.lightCardBackgroundFaint,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textSelectionTheme:
          const TextSelectionThemeData(cursorColor: AppColors.lightTextPrimary),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightInputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightInputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightInputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.lightTextPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: AppColors.lightTextHint),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: AppFonts.buttonTextLight.copyWith(color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightTextSecondary,
          side: const BorderSide(color: AppColors.lightTextSecondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: TextStyle(color: AppColors.lightTextSecondary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightTextPrimary,
          textStyle: AppFonts.bodyMediumLight,
        ),
      ),
      textTheme: const TextTheme(
          headlineLarge: AppFonts.headlineLargeLight,
          headlineMedium: AppFonts.headlineMediumLight,
          bodyLarge: AppFonts.bodyLargeLight,
          bodyMedium: AppFonts.bodyMediumLight,
          titleLarge: AppFonts.weeklyTextLight,
          titleMedium: AppFonts.menuTextLight,
          displaySmall: AppFonts.sloganTextLight,
          labelMedium: AppFonts.inputTextLight),
    );
  }

  /// Tema oscuro
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.darkTextSecondary,
        surface: AppColors.darkSurface,
        background: AppColors.darkBackground,
        error: AppColors.darkError,
        scrim: AppColors.darkSuccess,
        surfaceVariant: AppColors.darkWarning,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: AppColors.darkTextPrimary,
        onBackground: AppColors.darkTextPrimary,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCardBackground,
        surfaceTintColor: AppColors.darkCardBackgroundFaint,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textSelectionTheme:
          const TextSelectionThemeData(cursorColor: AppColors.darkTextPrimary),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkInputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkInputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkInputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.darkTextPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: AppColors.darkTextHint),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: AppFonts.buttonTextDark.copyWith(color: Colors.black),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkTextSecondary,
          side: const BorderSide(color: AppColors.darkTextSecondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: TextStyle(color: AppColors.darkTextSecondary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkTextPrimary,
          textStyle: AppFonts.bodyMediumDark,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: AppFonts.headlineLargeDark,
        headlineMedium: AppFonts.headlineMediumDark,
        bodyLarge: AppFonts.bodyLargeDark,
        bodyMedium: AppFonts.bodyMediumDark,
        titleLarge: AppFonts.weeklyTextDark,
        titleMedium: AppFonts.menuTextDark,
        displaySmall: AppFonts.sloganTextDark,
        labelMedium: AppFonts.inputTextDark,
      ),
    );
  }
}
