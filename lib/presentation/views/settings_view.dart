import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/theme_controller.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/settings_controller.dart';
import '../widgets/user_list_tab.dart';
import '../widgets/menu_list_tab.dart';
import '../widgets/ingredient_list_tab.dart';
import '../widgets/profile_tab.dart';

/// Vista principal de Settings
class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(
      init: SettingsController(),
      builder: (controller) {
        return Scaffold(
          body: Column(
            children: [
              // Header y tabs con esquinas redondeadas
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                child: Container(
                  color: Theme.of(Get.context!).primaryColor,
                  child: SafeArea(
                    bottom: false, // No aplicar SafeArea en la parte inferior
                    child: Column(
                      children: [
                        _buildHeader(context, controller),
                        _buildTabSection(context, controller),
                      ],
                    ),
                  ),
                ),
              ),

              // Contenido de tabs
              Expanded(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: _buildTabContent(controller),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construye el header superior
  Widget _buildHeader(BuildContext context, SettingsController controller) {
    final themeController = Get.find<ThemeController>();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Botón de regreso
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(Get.context!).colorScheme.onPrimary,
            ),
          ),

          const SizedBox(width: 8),

          // Título
          Expanded(
            child: Text(
              'Configuración',
              style: TextStyle(
                color: Theme.of(Get.context!).colorScheme.onPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Toggle de tema
          Obx(() {
            if (!themeController.isInitialized) {
              return Icon(
                Icons.brightness_auto,
                color: Theme.of(Get.context!).colorScheme.onPrimary,
                size: 24,
                semanticLabel: "Tema automatico",
              );
            }
            return PopupMenuButton<String>(
              onSelected: themeController.handleThemeSelection,
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'Oscuro',
                  child: Row(
                    children: [
                      Icon(
                        Icons.dark_mode,
                        color: themeController.currentThemeOption == 'Oscuro'
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        semanticLabel: "Tema oscuro",
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Oscuro',
                        style: TextStyle(
                          color: themeController.currentThemeOption == 'Oscuro'
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          fontWeight:
                              themeController.currentThemeOption == 'Oscuro'
                                  ? FontWeight.bold
                                  : null,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Claro',
                  child: Row(
                    children: [
                      Icon(
                        Icons.light_mode,
                        color: themeController.currentThemeOption == 'Claro'
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        semanticLabel: "Tema claro",
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Claro',
                        style: TextStyle(
                          color: themeController.currentThemeOption == 'Claro'
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          fontWeight:
                              themeController.currentThemeOption == 'Claro'
                                  ? FontWeight.bold
                                  : null,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Automático',
                  child: Row(
                    children: [
                      Icon(
                        Icons.brightness_auto,
                        color:
                            themeController.currentThemeOption == 'Automático'
                                ? Theme.of(context).colorScheme.primary
                                : null,
                        semanticLabel: "Tema automatico",
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Automático',
                        style: TextStyle(
                          color:
                              themeController.currentThemeOption == 'Automático'
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                          fontWeight:
                              themeController.currentThemeOption == 'Automático'
                                  ? FontWeight.bold
                                  : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              child: Icon(
                themeController.themeIcon,
                color: Theme.of(Get.context!).colorScheme.onPrimary,
                size: 24,
                semanticLabel: "Tema",
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Construye la sección de tabs
  Widget _buildTabSection(BuildContext context, SettingsController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20), // Más margen inferior
      decoration: BoxDecoration(
        color: AppColors.primaryAcent,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          // Eliminar líneas y divisores del TabBar
          dividerColor: Colors.transparent,
        ),
        child: Obx(() => TabBar(
              controller: controller.tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: AppColors.dark,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.onDark,
              unselectedLabelColor: AppColors.onTertiary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              // Eliminar líneas del TabBar
              dividerColor: Colors.transparent,
              indicatorWeight: 0,
              tabs: [
                Tab(text: 'Perfil'),
                if (controller.isAdmin.value) ...[
                  Tab(text: 'Usuarios'),
                  Tab(text: 'Menús'),
                  Tab(text: 'Ingredientes'),
                ],
              ],
            )),
      ),
    );
  }

  /// Construye el contenido de los tabs
  Widget _buildTabContent(SettingsController controller) {
    return Obx(() => TabBarView(
          controller: controller.tabController,
          children: [
            const ProfileTab(),
            if (controller.isAdmin.value) ...[
              const UserListTab(),
              const MenuListTab(),
              const IngredientListTab(),
            ],
          ],
        ));
  }
}
