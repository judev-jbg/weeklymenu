import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../../core/theme/app_theme.dart';

/// Vista principal del splash screen
/// Muestra la animación de entrada y maneja los estados de conexión
class SplashView extends StatelessWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      init: SplashController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.primary, // Fondo sólido por ahora
          // TODO: Descomentar cuando se agregue la imagen de fondo
          // body: Container(
          //   decoration: const BoxDecoration(
          //     image: DecorationImage(
          //       image: AssetImage('assets/images/background.png'),
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          //   child: _buildContent(controller),
          // ),
          body: _buildContent(context, controller),
        );
      },
    );
  }

  /// Construye el contenido principal del splash screen
  Widget _buildContent(BuildContext context, SplashController controller) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity, // Forzar ancho completo para centrado
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.center, // Asegurar centrado horizontal
          children: [
            // Título principal "Weekly Menu" con animación desde arriba
            SlideTransition(
              position: controller.topSlideAnimation,
              child: _buildTitle(context),
            ),

            const SizedBox(height: 40),

            // Imagen y textos inferiores con animación desde abajo
            SlideTransition(
              position: controller.bottomSlideAnimation,
              child: _buildBottomContent(context, controller),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el título principal "Weekly Menu"
  Widget _buildTitle(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Weekly',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
                height: 0.8,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 0),
        Text(
          'Menu',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
                height: 0.9,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Construye la imagen principal con transición suave entre plato y logo
  Widget _buildMainImage(SplashController controller) {
    return Obx(() {
      return AnimatedSwitcher(
        duration:
            const Duration(milliseconds: 800), // Duración de la transición
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Transición de fade combinada con escala
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            ),
          );
        },
        child: controller.showConnectionMessages.value
            ? _buildLogoWithAnimation(controller)
            : _buildSaladPlateImage(),
      );
    });
  }

  /// Construye la imagen del plato de ensaladas
  Widget _buildSaladPlateImage() {
    return Image.asset(
      'assets/images/salad_plate.png',
      key: const ValueKey('salad_plate'), // Key única para AnimatedSwitcher
      width: 350,
      height: 200,
      fit: BoxFit.contain,
    );
  }

  /// Construye el logo con animación intermitente
  Widget _buildLogoWithAnimation(SplashController controller) {
    return AnimatedBuilder(
      animation: controller.logoOpacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: controller.logoOpacityAnimation.value,
          child: Image.asset(
            'assets/images/app_logo.png',
            key: const ValueKey('app_logo'), // Key única para AnimatedSwitcher
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }

  /// Construye el texto del eslogan principal
  Widget _buildSloganText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        '¡Sabor planificado, caos eliminado!',
        style: Theme.of(context)
            .textTheme
            .displaySmall
            ?.copyWith(color: Colors.grey[600]),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Construye el contenido inferior (imagen, eslogan y mensajes de conexión)
  Widget _buildBottomContent(
      BuildContext context, SplashController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildMainImage(controller),
        const SizedBox(height: 30),
        _buildSloganText(context),
        const SizedBox(height: 60),
        _buildConnectionStatus(controller),
      ],
    );
  }

  /// Construye los mensajes de estado de conexión
  Widget _buildConnectionStatus(SplashController controller) {
    return Obx(() {
      if (controller.showConnectionMessages.value) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            controller.getConnectionMessage(),
            style: const TextStyle(color: AppColors.error, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        );
      }
      return const SizedBox.shrink(); // No mostrar nada si no hay mensajes
    });
  }
}
