import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/home_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/daily_menu_model.dart';
import '../../data/models/menu_model.dart';
import '../../data/models/shopping_item_model.dart';
import '../../data/models/ingredient_model.dart';
import '../../data/models/user_model.dart';

/// Controlador principal para el home
class HomeController extends GetxController with GetTickerProviderStateMixin {
  // Controladores de tabs
  late TabController tabController;
  final currentTabIndex = 0.obs;

  // Estados de datos
  final dailyMenus = <DailyMenuModel>[].obs;
  final shoppingList = <ShoppingItemModel>[].obs;
  final isLoading = false.obs;
  final isReorderMode = false.obs;

  // Usuario actual
  final currentUser = Rx<UserModel?>(null);

  // Modales y búsquedas
  final showMenuModal = false.obs;
  final showEditMenuModal = false.obs;
  final showShoppingModal = false.obs;
  final menuSearchQuery = ''.obs;
  final ingredientSearchQuery = ''.obs;
  final menuSearchResults = <MenuModel>[].obs;
  final ingredientSearchResults = <IngredientModel>[].obs;
  final selectedMenu = Rx<MenuModel?>(null);
  final selectedIngredient = Rx<IngredientModel?>(null);
  final selectedDailyMenu = Rx<DailyMenuModel?>(null);

  // Controladores de texto
  final menuSearchController = TextEditingController();
  final ingredientSearchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      currentTabIndex.value = tabController.index;
    });

    _initializeData();
  }

  @override
  void onClose() {
    tabController.dispose();
    menuSearchController.dispose();
    ingredientSearchController.dispose();
    super.onClose();
  }

  /// Inicializa los datos del home
  Future<void> _initializeData() async {
    isLoading.value = true;

    try {
      await _loadCurrentUserProfile();

      // Cargar datos
      await Future.wait([
        loadDailyMenus(),
        loadShoppingList(),
      ]);
    } catch (e) {
      Get.snackbar('Error', 'Error cargando datos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Carga el perfil del usuario actual
  Future<void> _loadCurrentUserProfile() async {
    try {
      final userId = AuthService.supabaseClient.auth.currentUser?.id;

      if (userId == null) return;

      final response = await AuthService.supabaseClient
          .from('user_profiles')
          .select('*')
          .eq('id', userId)
          .single();

      currentUser.value = UserModel.fromJson(response);
    } catch (e) {
      print('Error cargando perfil del usuario: $e');
    }
  }

  /// Carga los menús diarios
  Future<void> loadDailyMenus() async {
    try {
      final menus = await HomeService.getDailyMenus();
      dailyMenus.value = menus;
    } catch (e) {
      print('Error cargando menús diarios: $e');
    }
  }

  /// Carga la lista de compras
  Future<void> loadShoppingList() async {
    try {
      final items = await HomeService.getShoppingList();
      shoppingList.value = items;
    } catch (e) {
      print('Error cargando lista de compras: $e');
    }
  }

  /// Maneja el doble tap en un menú diario
  void handleDailyMenuDoubleTap(DailyMenuModel dailyMenu) {
    selectedDailyMenu.value = dailyMenu;

    if (dailyMenu.status == MenuStatus.pending) {
      _showEditMenuDialog();
    } else if (dailyMenu.status == MenuStatus.unassigned) {
      _showAssignMenuModal();
    }
  }

  /// Muestra el modal para asignar menú
  void _showAssignMenuModal() {
    selectedMenu.value = null;
    menuSearchQuery.value = '';
    menuSearchController.clear();
    menuSearchResults.clear();
    showMenuModal.value = true;
  }

  /// Muestra el dialog de confirmación para editar menú
  void _showEditMenuDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Menú Asignado'),
        content: const Text(
            'Ya existe un menú asignado para este día ¿Desea cambiar de menú?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showEditMenuModal();
            },
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  /// Muestra el modal para editar menú
  void _showEditMenuModal() {
    selectedMenu.value = selectedDailyMenu.value?.menu;
    menuSearchQuery.value = selectedMenu.value?.name ?? '';
    menuSearchController.text = menuSearchQuery.value;
    menuSearchResults.clear();
    showEditMenuModal.value = true;
  }

  /// Busca menús según la query
  void searchMenus(String query) async {
    menuSearchQuery.value = query;

    if (query.isEmpty) {
      menuSearchResults.clear();
      selectedMenu.value = null;
      return;
    }

    try {
      final results = await HomeService.searchMenus(query);
      menuSearchResults.value = results;

      // Auto-seleccionar si hay coincidencia exacta
      final exactMatch = results.firstWhereOrNull(
          (menu) => menu.name.toLowerCase() == query.toLowerCase());
      selectedMenu.value = exactMatch;
    } catch (e) {
      print('Error buscando menús: $e');
    }
  }

  /// Crea y asigna un nuevo menú
  Future<void> createAndAssignMenu(String name) async {
    try {
      final menu = await HomeService.createMenu(name, null);
      selectedMenu.value = menu;
      await assignMenuToDay();
    } catch (e) {
      Get.snackbar('Error', 'Error creando menú: $e');
    }
  }

  /// Asigna el menú seleccionado al día
  Future<void> assignMenuToDay() async {
    if (selectedMenu.value == null || selectedDailyMenu.value == null) return;

    try {
      await HomeService.assignMenuToDay(
        selectedDailyMenu.value!.id,
        selectedMenu.value!.id,
      );

      // Cerrar modales
      showMenuModal.value = false;
      showEditMenuModal.value = false;

      // Recargar datos
      await loadDailyMenus();

      Get.snackbar(
        'Éxito',
        'Menú asignado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Error asignando menú: $e');
    }
  }

  /// Alterna el modo de reordenamiento
  void toggleReorderMode() {
    isReorderMode.value = !isReorderMode.value;
  }

  /// Reordena los menús diarios
  Future<void> reorderMenus(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;

    // Reordenar localmente
    final item = dailyMenus.removeAt(oldIndex);
    dailyMenus.insert(newIndex, item);

    try {
      // Guardar en base de datos
      await HomeService.reorderDailyMenus(oldIndex, newIndex, dailyMenus);
    } catch (e) {
      // Revertir si falla
      final item = dailyMenus.removeAt(newIndex);
      dailyMenus.insert(oldIndex, item);
      Get.snackbar('Error', 'Error reordenando menús: $e');
    }
  }

  /// Muestra el modal para agregar a lista de compras
  void showAddToShoppingList() {
    selectedIngredient.value = null;
    ingredientSearchQuery.value = '';
    ingredientSearchController.clear();
    ingredientSearchResults.clear();
    showShoppingModal.value = true;
  }

  /// Busca ingredientes según la query
  void searchIngredients(String query) async {
    ingredientSearchQuery.value = query;

    if (query.isEmpty) {
      ingredientSearchResults.clear();
      selectedIngredient.value = null;
      return;
    }

    try {
      final results = await HomeService.searchIngredients(query);
      ingredientSearchResults.value = results;

      // Auto-seleccionar si hay coincidencia exacta
      final exactMatch = results.firstWhereOrNull(
          (ingredient) => ingredient.name.toLowerCase() == query.toLowerCase());
      selectedIngredient.value = exactMatch;
    } catch (e) {
      print('Error buscando ingredientes: $e');
    }
  }

  /// Crea y agrega un nuevo ingrediente
  Future<void> createAndAddIngredient(String name) async {
    try {
      final ingredient = await HomeService.createIngredient(name);
      selectedIngredient.value = ingredient;
      await addToShoppingList();
    } catch (e) {
      Get.snackbar('Error', 'Error creando ingrediente: $e');
    }
  }

  /// Agrega el ingrediente seleccionado a la lista
  Future<void> addToShoppingList() async {
    if (selectedIngredient.value == null) return;

    try {
      await HomeService.addToShoppingList(selectedIngredient.value!.id, null);

      showShoppingModal.value = false;
      await loadShoppingList();

      Get.snackbar(
        'Éxito',
        'Ingrediente agregado a la lista',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Error agregando ingrediente: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Elimina un item de la lista de compras
  Future<void> removeShoppingItem(ShoppingItemModel item) async {
    try {
      await HomeService.removeFromShoppingList(item.id);
      await loadShoppingList();

      Get.snackbar(
        'Éxito',
        'Item eliminado de la lista',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Error eliminando item: $e');
    }
  }

  /// Cierra sesión
  Future<void> signOut() async {
    try {
      await AuthService.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', 'Error cerrando sesión: $e');
    }
  }

  /// Navega a notificaciones
  void goToNotifications() {
    Get.toNamed('/notifications');
    // Get.snackbar("INFO", "Notificaciones", snackPosition: SnackPosition.BOTTOM);
  }

  /// Navega a configuración
  void goToSettings() {
    Get.toNamed('/settings');
  }

  /// Obtiene el primer nombre del usuario
  String get firstName {
    final user = currentUser.value;
    if (user?.firstName?.isNotEmpty == true) {
      return user!.firstName!;
    }

    // Fallback al email si no hay nombre
    final email = user?.email ?? 'Usuario';
    return StringExtension(email.split('@').first.split('.').first)
            .capitalize ??
        'Usuario';
  }
}

/// Extensión para capitalizar strings
extension StringExtension on String {
  String? get capitalize {
    if (isEmpty) return null;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
