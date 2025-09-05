import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/settings_service.dart';
import '../../data/models/user_model.dart';
import '../../data/models/menu_model.dart';
import '../../data/models/ingredient_model.dart';

/// Controlador para la página de Settings
class SettingsController extends GetxController
    with GetTickerProviderStateMixin {
  // Controladores de tabs
  late TabController tabController;
  final currentTabIndex = 0.obs;

  // Estados de datos
  final users = <UserModel>[].obs;
  final menus = <MenuModel>[].obs;
  final ingredients = <IngredientModel>[].obs;
  final currentUserProfile = Rx<UserModel?>(null);
  final isLoading = false.obs;
  final isAdmin = false.obs;

  // Modales
  final showUserModal = false.obs;
  final showMenuModal = false.obs;
  final showIngredientModal = false.obs;
  final showProfileModal = false.obs;
  final showPasswordModal = false.obs;

  // Edición
  final editingUser = Rx<UserModel?>(null);
  final editingMenu = Rx<MenuModel?>(null);
  final editingIngredient = Rx<IngredientModel?>(null);
  final isEditMode = false.obs;

  // Controladores de formularios
  final userEmailController = TextEditingController();
  final userPasswordController = TextEditingController();
  final userFirstNameController = TextEditingController();
  final userLastNameController = TextEditingController();
  final selectedUserRole = UserRole.user.obs;

  final menuNameController = TextEditingController();
  final menuDescriptionController = TextEditingController();

  final ingredientNameController = TextEditingController();
  final ingredientCategoryController = TextEditingController();

  final profileFirstNameController = TextEditingController();
  final profileLastNameController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Formularios
  final userFormKey = GlobalKey<FormState>();
  final menuFormKey = GlobalKey<FormState>();
  final ingredientFormKey = GlobalKey<FormState>();
  final profileFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(() {
      currentTabIndex.value = tabController.index;
    });

    _initializeData();
  }

  @override
  void onClose() {
    tabController.dispose();
    _disposeControllers();
    super.onClose();
  }

  void _disposeControllers() {
    userEmailController.dispose();
    userPasswordController.dispose();
    userFirstNameController.dispose();
    userLastNameController.dispose();
    menuNameController.dispose();
    menuDescriptionController.dispose();
    ingredientNameController.dispose();
    ingredientCategoryController.dispose();
    profileFirstNameController.dispose();
    profileLastNameController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }

  /// Inicializa los datos de la página
  Future<void> _initializeData() async {
    isLoading.value = true;

    try {
      // Verificar si es admin
      final adminStatus = await SettingsService.isCurrentUserAdmin();
      isAdmin.value = adminStatus;

      // Cargar perfil del usuario actual
      await _loadCurrentUserProfile();

      if (adminStatus) {
        // Cargar todos los datos si es admin
        await Future.wait([
          _loadUsers(),
          _loadMenus(),
          _loadIngredients(),
        ]);
      }
    } catch (e) {
      Get.snackbar('Error', 'Error cargando datos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Carga el perfil del usuario actual
  Future<void> _loadCurrentUserProfile() async {
    try {
      final profile = await SettingsService.getCurrentUserProfile();
      currentUserProfile.value = profile;

      // Llenar controladores del perfil
      profileFirstNameController.text = profile.firstName ?? '';
      profileLastNameController.text = profile.lastName ?? '';
    } catch (e) {
      print('Error cargando perfil: $e');
    }
  }

  /// Carga todos los usuarios
  Future<void> _loadUsers() async {
    try {
      final userList = await SettingsService.getAllUsers();
      users.value = userList;
    } catch (e) {
      print('Error cargando usuarios: $e');
    }
  }

  /// Carga todos los menús
  Future<void> _loadMenus() async {
    try {
      final menuList = await SettingsService.getAllMenus();
      menus.value = menuList;
    } catch (e) {
      print('Error cargando menús: $e');
    }
  }

  /// Carga todos los ingredientes
  Future<void> _loadIngredients() async {
    try {
      final ingredientList = await SettingsService.getAllIngredients();
      ingredients.value = ingredientList;
    } catch (e) {
      print('Error cargando ingredientes: $e');
    }
  }

  // =============== GESTIÓN DE USUARIOS ===============

  /// Muestra el modal para crear usuario
  void showCreateUserModal() {
    _clearUserForm();
    isEditMode.value = false;
    editingUser.value = null;
    showUserModal.value = true;
  }

  /// Muestra el modal para editar usuario
  void showEditUserModal(UserModel user) {
    _clearUserForm();
    isEditMode.value = true;
    editingUser.value = user;

    userEmailController.text = user.email;
    userFirstNameController.text = user.firstName ?? '';
    userLastNameController.text = user.lastName ?? '';
    selectedUserRole.value = user.role;

    showUserModal.value = true;
  }

  /// Guarda o actualiza usuario
  Future<void> saveUser() async {
    if (!userFormKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      if (isEditMode.value && editingUser.value != null) {
        // Actualizar usuario existente
        await SettingsService.updateUser(
          userId: editingUser.value!.id,
          firstName: userFirstNameController.text,
          lastName: userLastNameController.text,
          role: selectedUserRole.value,
        );

        Get.snackbar('Éxito', 'Usuario actualizado correctamente');
      } else {
        // Crear nuevo usuario
        await SettingsService.createUser(
          email: userEmailController.text,
          password: userPasswordController.text,
          firstName: userFirstNameController.text,
          lastName: userLastNameController.text,
          role: selectedUserRole.value,
        );

        Get.snackbar('Éxito', 'Usuario creado correctamente');
      }

      showUserModal.value = false;
      await _loadUsers();
    } catch (e) {
      Get.snackbar('Error', 'Error guardando usuario: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Elimina un usuario
  Future<void> deleteUser(UserModel user) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
            '¿Estás seguro de que deseas eliminar el usuario ${user.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await SettingsService.deleteUser(user.id);
        Get.snackbar('Éxito', 'Usuario eliminado correctamente');
        await _loadUsers();
      } catch (e) {
        Get.snackbar('Error', 'Error eliminando usuario: $e');
      }
    }
  }

  // =============== GESTIÓN DE MENÚS ===============

  /// Muestra el modal para crear menú
  void showCreateMenuModal() {
    _clearMenuForm();
    isEditMode.value = false;
    editingMenu.value = null;
    showMenuModal.value = true;
  }

  /// Muestra el modal para editar menú
  void showEditMenuModal(MenuModel menu) {
    _clearMenuForm();
    isEditMode.value = true;
    editingMenu.value = menu;

    menuNameController.text = menu.name;
    menuDescriptionController.text = menu.description ?? '';

    showMenuModal.value = true;
  }

  /// Guarda o actualiza menú
  Future<void> saveMenu() async {
    if (!menuFormKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      if (isEditMode.value && editingMenu.value != null) {
        // Actualizar menú existente
        await SettingsService.updateMenu(
          menuId: editingMenu.value!.id,
          name: menuNameController.text,
          description: menuDescriptionController.text.isEmpty
              ? null
              : menuDescriptionController.text,
        );

        Get.snackbar('Éxito', 'Menú actualizado correctamente');
      } else {
        // Crear nuevo menú (usar el servicio existente de HomeService)
        await SettingsService.createMenu(
          menuNameController.text,
          menuDescriptionController.text.isEmpty
              ? null
              : menuDescriptionController.text,
        );

        Get.snackbar('Éxito', 'Menú creado correctamente');
      }

      showMenuModal.value = false;
      await _loadMenus();
    } catch (e) {
      Get.snackbar('Error', 'Error guardando menú: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Elimina un menú
  Future<void> deleteMenu(MenuModel menu) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
            '¿Estás seguro de que deseas eliminar el menú "${menu.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await SettingsService.deleteMenu(menu.id);
        Get.snackbar('Éxito', 'Menú eliminado correctamente');
        await _loadMenus();
      } catch (e) {
        Get.snackbar('Error', 'Error eliminando menú: $e');
      }
    }
  }

  // =============== GESTIÓN DE INGREDIENTES ===============

  /// Muestra el modal para crear ingrediente
  void showCreateIngredientModal() {
    _clearIngredientForm();
    isEditMode.value = false;
    editingIngredient.value = null;
    showIngredientModal.value = true;
  }

  /// Muestra el modal para editar ingrediente
  void showEditIngredientModal(IngredientModel ingredient) {
    _clearIngredientForm();
    isEditMode.value = true;
    editingIngredient.value = ingredient;

    ingredientNameController.text = ingredient.name;
    ingredientCategoryController.text = ingredient.category ?? '';

    showIngredientModal.value = true;
  }

  /// Guarda o actualiza ingrediente
  Future<void> saveIngredient() async {
    if (!ingredientFormKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      if (isEditMode.value && editingIngredient.value != null) {
        // Actualizar ingrediente existente
        await SettingsService.updateIngredient(
          ingredientId: editingIngredient.value!.id,
          name: ingredientNameController.text,
          category: ingredientCategoryController.text.isEmpty
              ? null
              : ingredientCategoryController.text,
        );

        Get.snackbar('Éxito', 'Ingrediente actualizado correctamente');
      } else {
        // Crear nuevo ingrediente (usar el servicio existente de HomeService)
        await SettingsService.createIngredient(ingredientNameController.text);

        Get.snackbar('Éxito', 'Ingrediente creado correctamente');
      }

      showIngredientModal.value = false;
      await _loadIngredients();
    } catch (e) {
      Get.snackbar('Error', 'Error guardando ingrediente: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Elimina un ingrediente
  Future<void> deleteIngredient(IngredientModel ingredient) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
            '¿Estás seguro de que deseas eliminar el ingrediente "${ingredient.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await SettingsService.deleteIngredient(ingredient.id);
        Get.snackbar('Éxito', 'Ingrediente eliminado correctamente');
        await _loadIngredients();
      } catch (e) {
        Get.snackbar('Error', 'Error eliminando ingrediente: $e');
      }
    }
  }

  // =============== GESTIÓN DE PERFIL ===============

  /// Muestra el modal de edición de perfil
  void _showProfileModal() {
    showProfileModal.value = true;
  }

  /// Actualiza el perfil del usuario
  Future<void> updateProfile() async {
    if (!profileFormKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      await SettingsService.updateCurrentUserProfile(
        firstName: profileFirstNameController.text,
        lastName: profileLastNameController.text,
      );

      showProfileModal.value = false;
      await _loadCurrentUserProfile();

      Get.snackbar('Éxito', 'Perfil actualizado correctamente');
    } catch (e) {
      Get.snackbar('Error', 'Error actualizando perfil: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Muestra el modal de cambio de contraseña
  void showPasswordChangeModal() {
    _clearPasswordForm();
    showPasswordModal.value = true;
  }

  /// Cambia la contraseña del usuario
  Future<void> changePassword() async {
    if (!passwordFormKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      await SettingsService.changePassword(newPasswordController.text);

      showPasswordModal.value = false;
      _clearPasswordForm();

      Get.snackbar('Éxito', 'Contraseña cambiada correctamente');
    } catch (e) {
      Get.snackbar('Error', 'Error cambiando contraseña: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // =============== MÉTODOS AUXILIARES ===============

  void _clearUserForm() {
    userEmailController.clear();
    userPasswordController.clear();
    userFirstNameController.clear();
    userLastNameController.clear();
    selectedUserRole.value = UserRole.user;
  }

  void _clearMenuForm() {
    menuNameController.clear();
    menuDescriptionController.clear();
  }

  void _clearIngredientForm() {
    ingredientNameController.clear();
    ingredientCategoryController.clear();
  }

  void _clearPasswordForm() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  void closeUserModal() => showUserModal.value = false;
  void closeMenuModal() => showMenuModal.value = false;
  void closeIngredientModal() => showIngredientModal.value = false;
  void closeProfileModal() => showProfileModal.value = false;
  void closePasswordModal() => showPasswordModal.value = false;

  // =============== VALIDADORES ===============

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese un email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Por favor ingrese un email válido';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese una contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese $fieldName';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor confirme la contraseña';
    }
    if (value != newPasswordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }
}
