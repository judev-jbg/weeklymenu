import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_user_controller.dart';
import '../widgets/animated_bottom_sheet.dart';
import '../../core/controllers/theme_controller.dart';
import '../../core/theme/app_theme.dart';

/// Vista para el ingreso de usuario/email
class LoginUserView extends StatelessWidget {
  const LoginUserView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return GetBuilder<LoginUserController>(
      init: LoginUserController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.primary,
          body: Stack(
            children: [
              // Contenido principal
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(themeController),
                    Expanded(
                      child: _buildBottomSection(context, controller),
                    ),
                  ],
                ),
              ),

              // Sheet de registro superpuesto
              Obx(() => controller.showRegisterSheet.value
                  ? _buildRegisterSheet(context, controller)
                  : const SizedBox.shrink()),
            ],
          ),
        );
      },
    );
  }

  /// Construye la sección superior con títulos
  Widget _buildHeader(ThemeController themeController) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior con títulos y toggle de tema
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Iniciar sesión',
                style: Theme.of(Get.context!).textTheme.headlineLarge?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              // Toggle de tema
              const SizedBox(height: 16),
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
          // Mensaje de bienvenida
          Text(
            '¡Hola, bienvenido de nuevo! Entra en tu cuenta y planifica tu menú',
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
      BuildContext context, LoginUserController controller) {
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

              // Campo de email
              _buildEmailField(controller),

              const SizedBox(height: 16),

              // Sección de mensajes de error
              _buildErrorMessage(context, controller),

              const Spacer(),

              // Texto de registro
              _buildRegisterText(controller),

              const SizedBox(height: 16),

              // Botón continuar
              _buildContinueButton(controller),

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

  /// Construye el campo de email con icono
  Widget _buildEmailField(LoginUserController controller) {
    return TextFormField(
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
      validator: controller.validateEmail,
      style: Theme.of(Get.context!).textTheme.labelMedium,
      decoration: const InputDecoration(
        hintText: 'Ingrese su email',
        prefixIcon: Icon(Icons.email_outlined),
      ),
    );
  }

  /// Construye la sección de mensajes de error
  Widget _buildErrorMessage(
      BuildContext context, LoginUserController controller) {
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

  /// Construye el texto para registro
  Widget _buildRegisterText(LoginUserController controller) {
    return Center(
      child: TextButton(
        onPressed: controller.showRegister,
        child: RichText(
          text: TextSpan(
            style: Theme.of(Get.context!).textTheme.bodyMedium,
            children: [
              const TextSpan(text: '¿No tienes una cuenta? '),
              TextSpan(
                text: 'Regístrate',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(Get.context!).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el botón de continuar
  Widget _buildContinueButton(LoginUserController controller) {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : controller.continueToPassword,
            child: controller.isLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Continuar'),
          ),
        ));
  }

  /// Construye el sheet de registro que aparece desde abajo
  Widget _buildRegisterSheet(
      BuildContext context, LoginUserController controller) {
    return Obx(() {
      return AnimatedBottomSheet(
        isVisible: controller.showRegisterSheet.value,
        onDismiss: controller.hideRegister,
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        animationDuration: const Duration(milliseconds: 500),
        child: SingleChildScrollView(
          // El scroll controller se pasa desde el DraggableScrollableSheet automáticamente
          child: Form(
            key: controller.registerFormKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize:
                    MainAxisSize.min, // Importante para evitar overflow
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
                          'Regístrate',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '¡Crea tu cuenta y comienza a planificar tus menús!',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Ingrese los siguientes datos',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),

                  const SizedBox(height: 24),

                  // Campos con animación escalonada
                  _buildAnimatedFormFields(controller),

                  const SizedBox(height: 16),

                  // Mensaje de estado del registro
                  _buildRegisterMessage(controller),

                  const SizedBox(height: 32), // Espaciado antes de botones

                  // Botones con animación
                  _buildAnimatedButtons(controller),

                  // Espacio extra para el teclado
                  SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom + 24),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  /// Construye los campos del formulario con animación escalonada
  Widget _buildAnimatedFormFields(LoginUserController controller) {
    return Column(
      children: [
        // Campo email con retraso de animación
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
            controller: controller.registerEmailController,
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

        // Campo contraseña con más retraso
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
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
            controller: controller.registerPasswordController,
            obscureText: true,
            validator: controller.validatePassword,
            style: Theme.of(Get.context!).textTheme.labelMedium,
            decoration: const InputDecoration(
              hintText: 'Ingrese su contraseña',
              prefixIcon: Icon(Icons.lock_outlined),
            ),
          ),
        ),
      ],
    );
  }

  /// Construye los botones con animación
  Widget _buildAnimatedButtons(LoginUserController controller) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 900),
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
              onPressed: controller.hideRegister,
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
                    onPressed: controller.isRegisterLoading.value
                        ? null
                        : controller.registerUser,
                    child: controller.isRegisterLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Crear'),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  /// Construye el mensaje de estado del registro
  Widget _buildRegisterMessage(LoginUserController controller) {
    return Obx(() => controller.registerMessage.value.isNotEmpty
        ? Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: controller.registerMessage.value.contains('exitosamente')
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: controller.registerMessage.value.contains('exitosamente')
                    ? AppColors.success.withOpacity(0.3)
                    : AppColors.error.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  controller.registerMessage.value.contains('exitosamente')
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                  color:
                      controller.registerMessage.value.contains('exitosamente')
                          ? AppColors.success
                          : AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.registerMessage.value,
                    style: TextStyle(
                      color: controller.registerMessage.value
                              .contains('exitosamente')
                          ? AppColors.success
                          : AppColors.error,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (controller.registerMessage.value.contains('Inicie sesión'))
                  TextButton(
                    onPressed: controller.navigateToLogin,
                    child: const Text(
                      'Iniciar sesión',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          )
        : const SizedBox.shrink());
  }
}
