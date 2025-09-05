import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../core/enums/connection_state.dart';
import '../../data/services/connection_service.dart';

/// Controlador responsable de manejar la lógica del splash screen
class SplashController extends GetxController with GetTickerProviderStateMixin {
  // Controladores de animación separados
  late AnimationController mainAnimationController; // Para animación inicial
  late AnimationController logoAnimationController; // Para logo intermitente

  late Animation<Offset> topSlideAnimation;
  late Animation<Offset> bottomSlideAnimation;
  late Animation<double> logoOpacityAnimation;

  // Estados observables
  final connectionStatus = ConnectionStatus.connecting.obs;
  final showConnectionMessages = false.obs;
  final isInitialAnimationComplete = false.obs;

  // Completers para sincronización
  Completer<void>? _animationCompleter;
  Completer<ConnectionStatus>? _connectionCompleter;

  // Duración de las animaciones
  static const Duration animationDuration = Duration(seconds: 2);
  static const Duration connectionTimeout = Duration(seconds: 8);

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _startSplashSequence();
  }

  /// Inicializa las animaciones del splash screen
  void _initializeAnimations() {
    // Controlador para animación inicial (una sola vez)
    mainAnimationController = AnimationController(
      duration: animationDuration,
      vsync: this,
    );

    // Controlador separado para logo intermitente
    logoAnimationController = AnimationController(
      duration: connectionTimeout,
      vsync: this,
    );

    // Animación para elementos que vienen desde arriba (Weekly Menu)
    topSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: mainAnimationController,
      curve: Curves.easeOut,
    ));

    // Animación para elementos que vienen desde abajo (imagen y texto)
    bottomSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: mainAnimationController,
      curve: Curves.easeOut,
    ));

    // Animación de opacidad para el logo intermitente (controlador separado)
    logoOpacityAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: logoAnimationController,
      curve: Curves.easeInOut,
    ));

    // Listener para detectar cuando termina la animación inicial
    mainAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isInitialAnimationComplete.value = true;
        _animationCompleter?.complete();
      }
    });
  }

  /// Inicia la secuencia completa del splash screen
  void _startSplashSequence() {
    // Inicializar completers
    _animationCompleter = Completer<void>();
    _connectionCompleter = Completer<ConnectionStatus>();

    // Iniciar animación principal (una sola vez)
    mainAnimationController.forward();

    // Intentar conexión en paralelo
    _attemptConnection();

    // Esperar a que ambos procesos terminen
    _waitForBothProcesses();
  }

  /// Espera a que tanto la animación como la conexión terminen
  void _waitForBothProcesses() async {
    try {
      // Esperar a que ambos procesos terminen usando Future.wait
      final results = await Future.wait([
        _animationCompleter!.future,
        _connectionCompleter!.future,
      ]);

      final connectionResult = results[1] as ConnectionStatus;

      if (connectionResult == ConnectionStatus.connected) {
        // Navegar inmediatamente si hay conexión
        _navigateToNextScreen();
      } else {
        // Manejar fallo de conexión
        _handleConnectionFailure();
      }
    } catch (e) {
      // En caso de error, esperar a que termine la animación y manejar fallo
      await _animationCompleter!.future;
      _handleConnectionFailure();
    }
  }

  /// Maneja el proceso de conexión al servidor
  void _attemptConnection() async {
    try {
      // Intentar conexión inicial
      final connectionService = ConnectionService();
      final result = await connectionService.initializeConnection();
      connectionStatus.value = result;

      // Completar inmediatamente cuando la conexión termine
      if (!_connectionCompleter!.isCompleted) {
        _connectionCompleter!.complete(result);
      }
    } catch (e) {
      // Completar con error si falla la conexión
      if (!_connectionCompleter!.isCompleted) {
        _connectionCompleter!.complete(ConnectionStatus.disconnected);
      }
    }
  }

  /// Maneja el escenario de fallo en la conexión
  void _handleConnectionFailure() async {
    showConnectionMessages.value = true;
    connectionStatus.value = ConnectionStatus.connecting;

    // Iniciar SOLO la animación intermitente del logo
    logoAnimationController.repeat(reverse: true);

    // Intentar reconectar por un tiempo determinado
    bool connectionSuccess = false;
    int attempts = 0;
    const maxAttempts = 3;

    while (!connectionSuccess && attempts < maxAttempts) {
      await Future.delayed(connectionTimeout);

      final connectionService = ConnectionService();
      final result = await connectionService.initializeConnection();
      if (result == ConnectionStatus.connected) {
        connectionSuccess = true;
        connectionStatus.value = ConnectionStatus.connected;
        logoAnimationController.stop(); // Detener animación intermitente
        _navigateToNextScreen();
      } else {
        attempts++;
      }
    }

    // Si no logró conectar después de los intentos
    if (!connectionSuccess) {
      connectionStatus.value = ConnectionStatus.timeout;
      logoAnimationController.stop(); // Detener animación intermitente
    }
  }

  /// Navega a la siguiente pantalla según el estado del usuario
  void _navigateToNextScreen() async {
    if (ConnectionService.isUserLoggedIn()) {
      Get.offNamed('/home');
    } else {
      Get.offNamed('/login');
    }
  }

  /// Obtiene el mensaje de conexión apropiado
  String getConnectionMessage() {
    switch (connectionStatus.value) {
      case ConnectionStatus.connecting:
        return "Intentando conectarse al servidor, por favor espere...";
      case ConnectionStatus.timeout:
      case ConnectionStatus.disconnected:
        return "Lo sentimos, no ha sido posible conectarse al servidor. Verifique su conexión o intente más tarde";
      default:
        return "";
    }
  }

  @override
  void onClose() {
    mainAnimationController.dispose();
    logoAnimationController.dispose();
    _animationCompleter?.complete();
    _connectionCompleter?.complete(ConnectionStatus.disconnected);
    super.onClose();
  }
}
