import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/theme_controller.dart';
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
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                // Header negro
                _buildHeader(context, controller),

                // Tabs
                _buildTabSection(context, controller),

                // Contenido de tabs
                Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: _buildTabContent(controller),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Construye el header negro superior
  Widget _buildHeader(BuildContext context, SettingsController controller) {
    final themeController = Get.find<ThemeController>();

    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.black,
      child: Row(
        children: [
          // Botón de regreso
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),

          const SizedBox(width: 8),

          // Título
          Expanded(
            child: Text(
              'Settings',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Toggle de tema
          IconButton(
            onPressed: themeController.toggleTheme,
            icon: Icon(
              themeController.themeIcon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la sección de tabs
  Widget _buildTabSection(BuildContext context, SettingsController controller) {
    return Container(
      color: Colors.black,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Obx(() => TabBar(
              controller: controller.tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: const Color(0xFF6366F1),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
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
