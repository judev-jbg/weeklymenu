import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/home_controller.dart';
import '../../core/controllers/theme_controller.dart';
import '../widgets/daily_menu_card.dart';
import '../widgets/shopping_item_card.dart';
import '../widgets/assign_menu_modal.dart';
import '../widgets/add_ingredient_modal.dart';
import '../../core/theme/app_theme.dart';

/// Vista principal de la aplicación
class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          // FAB solo visible en tab Lista
          floatingActionButton: Obx(() => controller.currentTabIndex.value == 1
              ? FloatingActionButton(
                  onPressed: controller.showAddToShoppingList,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.add, color: Colors.black),
                )
              : const SizedBox.shrink()),

          // Un solo body con Stack para todo el contenido
          body: Stack(
            children: [
              // Contenido principal
              Column(
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
                        bottom:
                            false, // No aplicar SafeArea en la parte inferior
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
                      child: _buildTabContent(context, controller),
                    ),
                  ),
                ],
              ),

              // Modal de asignar menú
              Obx(() => controller.showMenuModal.value ||
                      controller.showEditMenuModal.value
                  ? AssignMenuModal(
                      isEdit: controller.showEditMenuModal.value,
                      onClose: () {
                        controller.showMenuModal.value = false;
                        controller.showEditMenuModal.value = false;
                      },
                    )
                  : const SizedBox.shrink()),

              // Modal de agregar ingrediente
              Obx(() => controller.showShoppingModal.value
                  ? const AddIngredientModal()
                  : const SizedBox.shrink()),
            ],
          ),
        );
      },
    );
  }

  /// Construye el header superior
  Widget _buildHeader(BuildContext context, HomeController controller) {
    final themeController = Get.find<ThemeController>();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Saludo personalizado
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenido,',
                  style: TextStyle(
                    color: Theme.of(Get.context!).colorScheme.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Obx(
                  () => Text(
                    controller.firstName,
                    style: TextStyle(
                      color: Theme.of(Get.context!).colorScheme.onPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              ],
            ),
          ),

          // Iconos del header
          Row(
            children: [
              // Icono de notificaciones
              IconButton(
                onPressed: controller.goToNotifications,
                icon: Icon(
                  Icons.notifications_outlined,
                  color: Theme.of(Get.context!).colorScheme.onPrimary,
                  size: 24,
                  semanticLabel: "Notificaciones",
                ),
              ),

              const SizedBox(width: 8),

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
                            color:
                                themeController.currentThemeOption == 'Oscuro'
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                            semanticLabel: "Tema oscuro",
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Oscuro',
                            style: TextStyle(
                              color:
                                  themeController.currentThemeOption == 'Oscuro'
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
                              color:
                                  themeController.currentThemeOption == 'Claro'
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
                            color: themeController.currentThemeOption ==
                                    'Automático'
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            semanticLabel: "Tema automatico",
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Automático',
                            style: TextStyle(
                              color: themeController.currentThemeOption ==
                                      'Automático'
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              fontWeight: themeController.currentThemeOption ==
                                      'Automático'
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

              const SizedBox(width: 8),

              // Menú dropdown
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.menu,
                  color: Theme.of(Get.context!).colorScheme.onPrimary,
                  size: 24,
                  semanticLabel: "Menu",
                ),
                color: Theme.of(context).cardColor,
                onSelected: (value) {
                  switch (value) {
                    case 'settings':
                      controller.goToSettings();
                      break;
                    case 'logout':
                      _showLogoutDialog(context, controller);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  // Opción Settings solo para admin
                  if (controller.currentUser.value?.isAdmin ?? false)
                    const PopupMenuItem<String>(
                      value: 'settings',
                      child: ListTile(
                        leading: Icon(
                          Icons.settings,
                          semanticLabel: "Configuración",
                        ),
                        title: Text('Configuración'),
                        dense: true,
                      ),
                    ),

                  PopupMenuItem<String>(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(
                        Icons.logout,
                        color: Theme.of(Get.context!).colorScheme.error,
                        semanticLabel: "Cerrar sesión",
                      ),
                      title: Text('Cerrar sesión',
                          style: TextStyle(
                              color: Theme.of(Get.context!).colorScheme.error)),
                      dense: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye la sección de tabs
  Widget _buildTabSection(BuildContext context, HomeController controller) {
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
        child: TabBar(
          controller: controller.tabController,
          indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(25), color: AppColors.dark),
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
          tabs: const [
            Tab(text: 'Menú'),
            Tab(text: 'Lista'),
          ],
        ),
      ),
    );
  }

  /// Construye el contenido de los tabs
  Widget _buildTabContent(BuildContext context, HomeController controller) {
    return TabBarView(
      controller: controller.tabController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMenuTab(context, controller),
        _buildShoppingTab(context, controller),
      ],
    );
  }

  /// Construye el tab de menús
  Widget _buildMenuTab(BuildContext context, HomeController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          // Switch para modo reordenamiento
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Menús',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Reordenar',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: controller.isReorderMode.value,
                      onChanged: (_) => controller.toggleReorderMode(),
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de menús diarios
          Expanded(
            child: controller.isReorderMode.value
                ? _buildReorderableMenuList(controller)
                : _buildMenuList(controller),
          ),
        ],
      );
    });
  }

  /// Construye la lista normal de menús
  Widget _buildMenuList(HomeController controller) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: controller.dailyMenus.length,
      itemBuilder: (context, index) {
        final dailyMenu = controller.dailyMenus[index];
        return DailyMenuCard(
          dailyMenu: dailyMenu,
          onDoubleTap: () => controller.handleDailyMenuDoubleTap(dailyMenu),
        );
      },
    );
  }

  /// Construye la lista reordenable de menús
  Widget _buildReorderableMenuList(HomeController controller) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: controller.dailyMenus.length,
      onReorder: controller.reorderMenus,
      itemBuilder: (context, index) {
        final dailyMenu = controller.dailyMenus[index];
        return DailyMenuCard(
          key: ValueKey(dailyMenu.id),
          dailyMenu: dailyMenu,
          isReorderable: true,
          onDoubleTap: () => controller.handleDailyMenuDoubleTap(dailyMenu),
        );
      },
    );
  }

  /// Construye el tab de lista de compras
  Widget _buildShoppingTab(BuildContext context, HomeController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.shoppingList.isEmpty) {
        return _buildEmptyShoppingList(context);
      }

      return Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lista de Compras',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${controller.shoppingList.where((item) => !item.isPurchased).length} pendientes',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Lista de items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.shoppingList.length,
              itemBuilder: (context, index) {
                final item = controller.shoppingList[index];
                return ShoppingItemCard(
                  item: item,
                  onRemove: () => controller.removeShoppingItem(item),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  /// Construye el estado vacío de la lista de compras
  Widget _buildEmptyShoppingList(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/svg/empty_shopping.svg',
              width: 200, height: 200),
          const SizedBox(height: 24),
          Text(
            '¡Parece que tu despensa está llena!',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Nada por comprar, solo queda disfrutar',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Muestra el diálogo de confirmación para cerrar sesión
  void _showLogoutDialog(BuildContext context, HomeController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.signOut();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsetsGeometry.only(left: 10, right: 10)),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
