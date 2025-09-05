import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/auth_service.dart';

/// Controlador para la pantalla de ingreso de usuario
class LoginUserController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final showRegisterSheet = false.obs;

  // Controladores para registro
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerPasswordController =
      TextEditingController();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final isRegisterLoading = false.obs;
  final registerMessage = ''.obs;

  @override
  void onClose() {
    emailController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    super.onClose();
  }

  /// Valida y continúa al siguiente paso del login
  Future<void> continueToPassword() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await AuthService.validateUserExists(emailController.text);

      if (result.isValid && result.exists) {
        // Navegar a pantalla de contraseña
        Get.toNamed('/password', arguments: {'email': emailController.text});
      } else {
        errorMessage.value = result.message ?? 'Error al validar usuario';
      }
    } catch (e) {
      errorMessage.value = 'Error de conexión. Intente nuevamente';
    } finally {
      isLoading.value = false;
    }
  }

  /// Muestra el sheet de registro
  void showRegister() {
    showRegisterSheet.value = true;
    registerMessage.value = '';
    registerEmailController.clear();
    registerPasswordController.clear();
  }

  /// Oculta el sheet de registro
  void hideRegister() {
    showRegisterSheet.value = false;
    registerMessage.value = '';
  }

  /// Registra un nuevo usuario
  Future<void> registerUser() async {
    if (!registerFormKey.currentState!.validate()) return;

    isRegisterLoading.value = true;
    registerMessage.value = '';

    try {
      final result = await AuthService.registerUser(
        email: registerEmailController.text,
        password: registerPasswordController.text,
      );

      if (result.success) {
        registerMessage.value =
            result.message ?? 'Usuario registrado exitosamente';
        // Esperar un momento antes de ocultar el sheet
        await Future.delayed(const Duration(seconds: 2));
        hideRegister();
        // Llenar automáticamente el email en el login
        emailController.text = registerEmailController.text;
      } else {
        registerMessage.value = result.message ?? 'Error al registrar usuario';
      }
    } catch (e) {
      registerMessage.value = 'Error de conexión. Intente nuevamente';
    } finally {
      isRegisterLoading.value = false;
    }
  }

  /// Navega directamente al login si el usuario ya existe
  void navigateToLogin() {
    hideRegister();
    if (registerEmailController.text.isNotEmpty) {
      emailController.text = registerEmailController.text;
    }
  }

  /// Validador para el campo email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Por favor ingrese un email válido';
    }
    return null;
  }

  /// Validador para el campo contraseña (registro)
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese una contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }
}
