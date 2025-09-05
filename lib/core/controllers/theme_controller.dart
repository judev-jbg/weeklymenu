import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Controlador para manejar el tema de la aplicación
class ThemeController extends GetxController {
  final _isDarkMode = false.obs;
  final _followSystemTheme = true.obs;
  final _isInitialized = false.obs;

  bool get isDarkMode => _isDarkMode.value;
  bool get followSystemTheme => _followSystemTheme.value;
  bool get isInitialized => _isInitialized.value;

  @override
  void onInit() {
    super.onInit();
    _initializeTheme();
  }

  @override
  void onReady() {
    super.onReady();
    // Asegurarse de que esté completamente inicializado
    _isInitialized.value = true;
  }

  /// Inicializa el tema basado en las preferencias del sistema
  void _initializeTheme() {
    if (_followSystemTheme.value) {
      _updateThemeFromSystem();
      Get.changeThemeMode(ThemeMode.system);
    }
  }

  /// Actualiza el tema según el sistema operativo
  void _updateThemeFromSystem() {
    final brightness =
        Get.context?.mediaQuery.platformBrightness ?? Brightness.light;
    _isDarkMode.value = brightness == Brightness.dark;
  }

  /// Alterna entre tema claro y oscuro manualmente
  void toggleTheme() {
    _followSystemTheme.value = false;
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  /// Establece el tema para seguir el sistema operativo
  void followSystemThemeMode() {
    _followSystemTheme.value = true;
    _updateThemeFromSystem();
    Get.changeThemeMode(ThemeMode.system);
  }

  /// Establece tema claro manualmente
  void setLightTheme() {
    _followSystemTheme.value = false;
    _isDarkMode.value = false;
    Get.changeThemeMode(ThemeMode.light);
  }

  /// Establece tema oscuro manualmente
  void setDarkTheme() {
    _followSystemTheme.value = false;
    _isDarkMode.value = true;
    Get.changeThemeMode(ThemeMode.dark);
  }

  void handleThemeSelection(String selection) {
    switch (selection) {
      case 'Oscuro':
        setDarkTheme();
        break;
      case 'Claro':
        setLightTheme();
        break;
      case 'Automático':
        followSystemThemeMode();
        break;
    }
  }

  /// Obtiene el ícono apropiado para el toggle de tema
  IconData get themeIcon {
    if (_followSystemTheme.value) {
      return Icons.brightness_auto;
    }
    return _isDarkMode.value ? Icons.dark_mode : Icons.light_mode;
  }

  String get currentThemeOption {
    if (_followSystemTheme.value) {
      return 'Automático';
    }
    return _isDarkMode.value ? 'Oscuro' : 'Claro';
  }
}
