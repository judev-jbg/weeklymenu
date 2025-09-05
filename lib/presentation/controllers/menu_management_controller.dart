import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/menu_management_service.dart';
import '../../data/services/home_service.dart';
import '../../data/models/daily_menu_model.dart';
import '../../data/models/menu_model.dart';

/// Controlador para la gestión de menús pendientes
class MenuManagementController extends GetxController {
  // Estado principal
  final pendingMenus = <DailyMenuModel>[].obs;
  final isLoading = false.obs;
  final currentMenuManagement = Rx<DailyMenuModel?>(null);

  // Modal de menú alternativo
  final showAlternativeMenuModal = false.obs;
  final menuSearchQuery = ''.obs;
  final menuSearchResults = <MenuModel>[].obs;
  final selectedAlternativeMenu = Rx<MenuModel?>(null);
  final recycleForNextWeek = false.obs;

  // Controladores de texto
  final menuSearchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _checkForDirectNavigation();
    _loadPendingMenus();
  }

  @override
  void onClose() {
    menuSearchController.dispose();
    super.onClose();
  }

  /// Verifica si se navegó directamente desde una notificación
  void _checkForDirectNavigation() {
    final args = Get.arguments as Map<String, dynamic>?;
    final dailyMenuId = args?['dailyMenuId'] as String?;

    if (dailyMenuId != null) {
      _loadSpecificMenu(dailyMenuId);
    }
  }

  /// Carga un menú específico para gestión
  Future<void> _loadSpecificMenu(String dailyMenuId) async {
    isLoading.value = true;

    try {
      final menu = await MenuManagementService.getDailyMenuById(dailyMenuId);
      if (menu != null) {
        currentMenuManagement.value = menu;
      }
    } catch (e) {
      Get.snackbar('Error', 'Error cargando menú: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Carga los menús pendientes de gestión
  Future<void> _loadPendingMenus() async {
    isLoading.value = true;

    try {
      final menus = await MenuManagementService.getPendingMenusToManage();
      pendingMenus.value = menus;

      // Si hay menús pendientes y no hay uno específico seleccionado
      if (menus.isNotEmpty && currentMenuManagement.value == null) {
        currentMenuManagement.value = menus.first;
      }
    } catch (e) {
      Get.snackbar('Error', 'Error cargando menús pendientes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Marca el menú actual como completado
  Future<void> markAsCompleted() async {
    final menu = currentMenuManagement.value;
    if (menu == null) return;

    isLoading.value = true;

    try {
      final success = await MenuManagementService.markMenuAsCompleted(menu.id);

      if (success) {
        Get.snackbar(
          'Éxito',
          'Menú marcado como completado',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        // Remover de la lista y navegar al siguiente
        _removeCurrentAndMoveNext();
      } else {
        Get.snackbar('Error', 'Error marcando menú como completado');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Muestra el modal para seleccionar menú alternativo
  void showAlternativeMenuSelection() {
    selectedAlternativeMenu.value = null;
    menuSearchQuery.value = '';
    menuSearchController.clear();
    menuSearchResults.clear();
    recycleForNextWeek.value = false;
    showAlternativeMenuModal.value = true;
  }

  /// Busca menús alternativos
  void searchAlternativeMenus(String query) async {
    menuSearchQuery.value = query;

    if (query.isEmpty) {
      menuSearchResults.clear();
      selectedAlternativeMenu.value = null;
      return;
    }

    try {
      final results = await HomeService.searchMenus(query);
      menuSearchResults.value = results;

      // Auto-seleccionar si hay coincidencia exacta
      final exactMatch = results.firstWhereOrNull(
          (menu) => menu.name.toLowerCase() == query.toLowerCase());
      selectedAlternativeMenu.value = exactMatch;
    } catch (e) {
      print('Error buscando menús alternativos: $e');
    }
  }

  /// Crea y selecciona un nuevo menú alternativo
  Future<void> createAndSelectAlternativeMenu(String name) async {
    try {
      final menu = await HomeService.createMenu(name, null);
      selectedAlternativeMenu.value = menu;
    } catch (e) {
      Get.snackbar('Error', 'Error creando menú: $e');
    }
  }

  /// Confirma la selección de menú alternativo
  Future<void> confirmAlternativeMenu() async {
    final menu = currentMenuManagement.value;
    final alternativeMenu = selectedAlternativeMenu.value;

    if (menu == null || alternativeMenu == null) return;

    isLoading.value = true;

    try {
      final success = await MenuManagementService.markMenuAsNotCompleted(
        dailyMenuId: menu.id,
        actualMenuId: alternativeMenu.id,
        recycleForNextWeek: recycleForNextWeek.value,
      );

      if (success) {
        showAlternativeMenuModal.value = false;

        String message = 'Menú actualizado correctamente';
        if (recycleForNextWeek.value) {
          message += ' y programado para la siguiente semana';
        }

        Get.snackbar(
          'Éxito',
          message,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        // Remover de la lista y navegar al siguiente
        _removeCurrentAndMoveNext();
      } else {
        Get.snackbar('Error', 'Error actualizando menú');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Remueve el menú actual y navega al siguiente
  void _removeCurrentAndMoveNext() {
    final currentMenu = currentMenuManagement.value;
    if (currentMenu != null) {
      // Remover de la lista
      pendingMenus.removeWhere((menu) => menu.id == currentMenu.id);

      // Seleccionar el siguiente menú
      if (pendingMenus.isNotEmpty) {
        currentMenuManagement.value = pendingMenus.first;
      } else {
        currentMenuManagement.value = null;
      }
    }
  }

  /// Navega al menú anterior en la lista
  void goToPreviousMenu() {
    final currentMenu = currentMenuManagement.value;
    if (currentMenu == null || pendingMenus.isEmpty) return;

    final currentIndex =
        pendingMenus.indexWhere((menu) => menu.id == currentMenu.id);
    if (currentIndex > 0) {
      currentMenuManagement.value = pendingMenus[currentIndex - 1];
    }
  }

  /// Navega al menú siguiente en la lista
  void goToNextMenu() {
    final currentMenu = currentMenuManagement.value;
    if (currentMenu == null || pendingMenus.isEmpty) return;

    final currentIndex =
        pendingMenus.indexWhere((menu) => menu.id == currentMenu.id);
    if (currentIndex < pendingMenus.length - 1) {
      currentMenuManagement.value = pendingMenus[currentIndex + 1];
    }
  }

  /// Cierra el modal de menú alternativo
  void closeAlternativeMenuModal() {
    showAlternativeMenuModal.value = false;
  }

  /// Verifica si hay menús pendientes
  bool get hasPendingMenus => pendingMenus.isNotEmpty;

  /// Obtiene el índice del menú actual
  String get currentMenuIndex {
    final currentMenu = currentMenuManagement.value;
    if (currentMenu == null || pendingMenus.isEmpty) return '0/0';

    final currentIndex =
        pendingMenus.indexWhere((menu) => menu.id == currentMenu.id);
    return '${currentIndex + 1}/${pendingMenus.length}';
  }
}
