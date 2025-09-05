import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:weekly_menu/core/enums/connection_state.dart';
import 'package:weekly_menu/data/services/connection_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'package:weekly_menu/core/routes/custom_transitions.dart';
import 'core/controllers/theme_controller.dart';
import 'data/services/notification_service.dart';
import 'data/services/menu_management_service.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientación de pantalla
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    // Inicializar Firebase
    await Firebase.initializeApp();
    print('✅ Firebase inicializado correctamente');

    // Inicializar Supabase
    final connectionService = ConnectionService();
    final result = await connectionService.initializeConnection();
    if (result == ConnectionStatus.connected) {
      print('✅ Supabase inicializado correctamente');
    }

    // Inicializar dependencias globales
    Get.put(ThemeController(), permanent: true);
    print('✅ Controladores globales inicializados');

    // Inicializar servicios
    await NotificationService.initialize();
    print('✅ Servicio de notificaciones inicializado');

    // Programar auto-completado de menús expirados
    await MenuManagementService.autoCompleteExpiredMenus();
    print('✅ Verificación de menús expirados completada');

    print('🚀 Aplicación lista para ejecutar');
  } catch (e) {
    print('❌ Error durante la inicialización: $e');
  }

  runApp(const WeeklyMenuApp());
}

/// Aplicación principal de Weekly Menu
class WeeklyMenuApp extends StatelessWidget {
  const WeeklyMenuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Weekly Menu',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Seguir el tema del sistema por defecto
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
      debugShowCheckedModeBanner: false,
      customTransition: CustomTransitions.fadeSlide,
      transitionDuration: const Duration(milliseconds: 400),

      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}
