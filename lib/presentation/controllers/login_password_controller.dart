import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/auth_service.dart';

/// Controlador para la pantalla de contraseña
class LoginPasswordController extends GetxController {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController resetEmailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> resetFormKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isPasswordVisible = false.obs;
  final showResetSheet = false.obs;
  final isResetLoading = false.obs;
  final resetMessage = ''.obs;
  final loginAttempts = 0.obs;
  final isBlocked = false.obs;

  late String userEmail;
  static const int maxAttempts = 3;

  @override
  void onInit() {
    super.onInit();
    // Obtener email del argumento anterior
    final args = Get.arguments as Map<String, dynamic>?;
    userEmail = args?['email'] ?? '';
    resetEmailController.text = userEmail;
    _checkIfUserBlocked();
  }

  @override
  void onClose() {
    passwordController.dispose();
    resetEmailController.dispose();
    super.onClose();
  }

  /// Verifica si el usuario está bloqueado
  Future<void> _checkIfUserBlocked() async {
    final blocked = await AuthService.isUserBlocked(userEmail);
    isBlocked.value = blocked;
    if (blocked) {
      errorMessage.value =
          'Debe esperar para realizar un nuevo intento por seguridad';
    }
  }

  /// Alterna la visibilidad de la contraseña
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Intenta iniciar sesión
  Future<void> signIn() async {
    if (!formKey.currentState!.validate() || isBlocked.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await AuthService.signInWithEmailPassword(
        email: userEmail,
        password: passwordController.text,
      );

      if (result.success) {
        // Login exitoso - navegar a Home
        Get.offAllNamed('/home');
      } else {
        // Incrementar intentos fallidos
        loginAttempts.value++;

        if (loginAttempts.value >= maxAttempts) {
          errorMessage.value =
              'Debe esperar para realizar un nuevo intento por seguridad';
          isBlocked.value = true;
        } else {
          final remainingAttempts = maxAttempts - loginAttempts.value;
          errorMessage.value =
              result.message ?? 'La contraseña ingresada es incorrecta';
          if (remainingAttempts == 1) {
            errorMessage.value += ' (1 intento restante)';
          }
        }
      }
    } catch (e) {
      errorMessage.value = 'Error de conexión. Intente nuevamente';
    } finally {
      isLoading.value = false;
    }
  }

  /// Muestra el sheet de reseteo de contraseña
  void showPasswordReset() {
    showResetSheet.value = true;
    resetMessage.value = '';
  }

  /// Oculta el sheet de reseteo de contraseña
  void hidePasswordReset() {
    showResetSheet.value = false;
    resetMessage.value = '';
  }

  /// Envía email para resetear contraseña
  Future<void> resetPassword() async {
    if (!resetFormKey.currentState!.validate()) return;

    isResetLoading.value = true;
    resetMessage.value = '';

    try {
      final success =
          await AuthService.resetPassword(resetEmailController.text);

      if (success) {
        resetMessage.value =
            'Se ha enviado un correo con instrucciones para restablecer su contraseña';
        await Future.delayed(const Duration(seconds: 3));
        hidePasswordReset();
      } else {
        resetMessage.value = 'Error al enviar el correo. Intente nuevamente';
      }
    } catch (e) {
      resetMessage.value = 'Error de conexión. Intente nuevamente';
    } finally {
      isResetLoading.value = false;
    }
  }

  /// Regresa a la pantalla anterior
  void goBack() {
    Get.back();
  }

  /// Validador para el campo contraseña
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su contraseña';
    }
    return null;
  }

  /// Validador para el campo email del reset
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Por favor ingrese un email válido';
    }
    return null;
  }
}
