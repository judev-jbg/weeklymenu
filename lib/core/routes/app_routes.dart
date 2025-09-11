import 'package:get/get.dart';
import '../../presentation/views/splash_view.dart';
import '../../presentation/views/login_user_view.dart';
import '../../presentation/views/login_password_view.dart';
import '../../presentation/views/home_view.dart';
import '../../presentation/views/menu_management_view.dart';
import '../../presentation/views/notifications_view.dart';
import '../../presentation/views/settings_view.dart';
import 'custom_transitions.dart';

/// Configuración centralizada de las rutas de la aplicación
class AppRoutes {
  static const String splash = '/';
  static const String loginUser = '/login';
  static const String password = '/password';
  static const String home = '/home';
  static const String notifications = '/notifications';
  static const String menuManagement = '/menu-management';
  static const String settings = '/settings';

  /// Lista de páginas de la aplicación
  static List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: loginUser,
      page: () => const LoginUserView(),
      customTransition: CustomTransitions.fadeSlide,
    ),
    GetPage(
      name: password,
      page: () => const LoginPasswordView(),
      // transition: Transition.custom,
      customTransition: CustomTransitions.slideFromRight,
    ),
    GetPage(
      name: home,
      page: () => const HomeView(),
      // transition: Transition.custom,
      customTransition: CustomTransitions.fadeSlide,
    ),
    GetPage(
      name: menuManagement,
      page: () => const MenuManagementView(),
      // transition: Transition.custom,
      customTransition: CustomTransitions.slideFromRight,
    ),
    GetPage(
      name: notifications,
      page: () => const NotificationsView(),
      // transition: Transition.custom,
      customTransition: CustomTransitions.slideFromRight,
    ),
    GetPage(
      name: settings,
      page: () => const SettingsView(),
      // transition: Transition.custom,
      customTransition: CustomTransitions.slideFromRight,
    ),
  ];
}
