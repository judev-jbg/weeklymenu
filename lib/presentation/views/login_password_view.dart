import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_password_controller.dart';
import '../widgets/animated_bottom_sheet.dart';
import '../../core/controllers/theme_controller.dart';
import '../../core/theme/app_theme.dart';

/// Vista para el ingreso de contraseña
class LoginPasswordView extends StatelessWidget {
  const LoginPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return GetBuilder<LoginPasswordController>(
      init: LoginPasswordController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.primary,
          body: Stack(
            children: [
              // Contenido principal
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(themeController, controller),
                    Expanded(
                      child: _buildBottomSection(context, controller),
                    ),
                  ],
                ),
              ),

              // Sheet de reset de contraseña
              Obx(() => controller.showResetSheet.value
                  ? _buildPasswordResetSheet(context, controller)
                  : const SizedBox.shrink()),
            ],
          ),
        );
      },
    );
  }

  /// Construye la sección superior con títulos
  Widget _buildHeader(
      ThemeController themeController, LoginPasswordController controller) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior con botón atrás y toggle de tema
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: controller.goBack,
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Contraseña',
                    style: Theme.of(Get.context!)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              IconButton(
                onPressed: themeController.toggleTheme,
                icon: Icon(
                  themeController.themeIcon,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Mensaje de bienvenida con email
          Text(
            'Ingrese su contraseña para acceder a su cuenta: ${controller.userEmail}',
            style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                ),
          ),
        ],
      ),
    );
  }

  /// Construye la sección inferior blanca con el formulario
  Widget _buildBottomSection(
      BuildContext context, LoginPasswordController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de la sección
              Text(
                'Ingrese los siguientes datos',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),

              const SizedBox(height: 24),

              // Campo de contraseña
              _buildPasswordField(controller),

              const SizedBox(height: 16),

              // Sección de mensajes de error
              _buildErrorMessage(context, controller),

              const Spacer(),

              // Texto de olvido de contraseña
              _buildForgotPasswordText(controller),

              const SizedBox(height: 16),

              // Botón ingresar
              _buildSignInButton(controller),

              // Espaciado para el teclado
              SizedBox(
                  height:
                      MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 0),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el campo de contraseña con toggle de visibilidad
  Widget _buildPasswordField(LoginPasswordController controller) {
    return Obx(() => TextFormField(
          controller: controller.passwordController,
          obscureText: !controller.isPasswordVisible.value,
          validator: controller.validatePassword,
          enabled: !controller.isBlocked.value,
          style: Theme.of(Get.context!).textTheme.labelMedium,
          decoration: InputDecoration(
            hintText: 'Ingrese su contraseña',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isPasswordVisible.value
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
          ),
        ));
  }

  /// Construye la sección de mensajes de error
  Widget _buildErrorMessage(
      BuildContext context, LoginPasswordController controller) {
    return Obx(() => controller.errorMessage.value.isNotEmpty
        ? Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: Theme.of(Get.context!).colorScheme.error),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline,
                    color: Theme.of(Get.context!).colorScheme.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.errorMessage.value,
                    style: TextStyle(
                        color: Theme.of(Get.context!).colorScheme.error,
                        fontSize: 14),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink());
  }

  /// Construye el texto para olvido de contraseña
  Widget _buildForgotPasswordText(LoginPasswordController controller) {
    return Center(
      child: TextButton(
        onPressed: controller.showPasswordReset,
        child: Text(
          '¿Has olvidado tu contraseña?',
          style: TextStyle(
            color: Theme.of(Get.context!).colorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Construye el botón de ingresar
  Widget _buildSignInButton(LoginPasswordController controller) {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                (controller.isLoading.value || controller.isBlocked.value)
                    ? null
                    : controller.signIn,
            child: controller.isLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Ingresar'),
          ),
        ));
  }

  /// Construye el sheet de reset de contraseña con animación suave
  Widget _buildPasswordResetSheet(
      BuildContext context, LoginPasswordController controller) {
    return Obx(() => AnimatedBottomSheet(
          isVisible: controller.showResetSheet.value,
          onDismiss: controller.hidePasswordReset,
          initialChildSize: 0.55,
          minChildSize: 0.4,
          maxChildSize: 0.6,
          animationDuration: const Duration(milliseconds: 450),
          child: Form(
            key: controller.resetFormKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título con animación de entrada
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, (1 - value) * 20),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Restablecer Contraseña',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ingrese su email para recibir instrucciones de restablecimiento',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Campo email con animación
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 700),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset((1 - value) * 30, 0),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: TextFormField(
                      controller: controller.resetEmailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: controller.validateEmail,
                      style: Theme.of(Get.context!).textTheme.labelMedium,
                      decoration: const InputDecoration(
                        hintText: 'Ingrese su email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Mensaje de estado del reset
                  _buildResetMessage(controller),

                  const Spacer(),

                  // Botones con animación
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, (1 - value) * 30),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: controller.hidePasswordReset,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey[400]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Obx(() => AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                child: ElevatedButton(
                                  onPressed: controller.isResetLoading.value
                                      ? null
                                      : controller.resetPassword,
                                  child: controller.isResetLoading.value
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Text('Reiniciar'),
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom > 0
                          ? 24
                          : 0),
                ],
              ),
            ),
          ),
        ));
  }

  /// Construye el mensaje de estado del reset
  Widget _buildResetMessage(LoginPasswordController controller) {
    return Obx(() => controller.resetMessage.value.isNotEmpty
        ? Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: controller.resetMessage.value.contains('enviado')
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: controller.resetMessage.value.contains('enviado')
                    ? AppColors.success.withOpacity(0.3)
                    : AppColors.error.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  controller.resetMessage.value.contains('enviado')
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                  color: controller.resetMessage.value.contains('enviado')
                      ? AppColors.success
                      : AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.resetMessage.value,
                    style: TextStyle(
                      color: controller.resetMessage.value.contains('enviado')
                          ? AppColors.success
                          : AppColors.error,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink());
  }
}
