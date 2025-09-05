import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/menu_model.dart';
import '../models/ingredient_model.dart';

/// Servicio para manejar la funcionalidad de Settings
class SettingsService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // =============== USUARIOS ===============

  /// Obtiene todos los usuarios (solo admin)
  static Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select('*')
          .order('created_at', ascending: false);

      return response.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo usuarios: $e');
      throw e;
    }
  }

  /// Crea un nuevo usuario
  static Future<UserModel> createUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
  }) async {
    try {
      // Crear usuario en auth.users
      final authResponse =
          await _supabase.auth.admin.createUser(AdminUserAttributes(
        email: email,
        password: password,
        emailConfirm: true,
      ));

      if (authResponse.user == null) {
        throw Exception('Error creando usuario en auth');
      }

      // Actualizar perfil con datos adicionales
      await _supabase.from('user_profiles').update({
        'first_name': firstName,
        'last_name': lastName,
        'role': role.value,
        'updated_by': _supabase.auth.currentUser?.id,
      }).eq('id', authResponse.user!.id);

      // Obtener el usuario completo
      final response = await _supabase
          .from('user_profiles')
          .select('*')
          .eq('id', authResponse.user!.id)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error creando usuario: $e');
      throw e;
    }
  }

  /// Actualiza un usuario existente
  static Future<UserModel> updateUser({
    required String userId,
    String? firstName,
    String? lastName,
    UserRole? role,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_by': _supabase.auth.currentUser?.id,
      };

      if (firstName != null) updates['first_name'] = firstName;
      if (lastName != null) updates['last_name'] = lastName;
      if (role != null) updates['role'] = role.value;

      await _supabase.from('user_profiles').update(updates).eq('id', userId);

      // Obtener el usuario actualizado
      final response = await _supabase
          .from('user_profiles')
          .select('*')
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error actualizando usuario: $e');
      throw e;
    }
  }

  /// Elimina un usuario
  static Future<bool> deleteUser(String userId) async {
    try {
      // Eliminar de user_profiles (auth.users se elimina en cascada)
      await _supabase.from('user_profiles').delete().eq('id', userId);

      return true;
    } catch (e) {
      print('Error eliminando usuario: $e');
      throw e;
    }
  }

  // =============== PERFIL ===============

  /// Obtiene el perfil del usuario actual
  static Future<UserModel> getCurrentUserProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      final response = await _supabase
          .from('user_profiles')
          .select('*')
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error obteniendo perfil: $e');
      throw e;
    }
  }

  /// Actualiza el perfil del usuario actual
  static Future<UserModel> updateCurrentUserProfile({
    required String firstName,
    required String lastName,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      await _supabase.from('user_profiles').update({
        'first_name': firstName,
        'last_name': lastName,
      }).eq('id', userId);

      return await getCurrentUserProfile();
    } catch (e) {
      print('Error actualizando perfil: $e');
      throw e;
    }
  }

  /// Cambia la contraseña del usuario actual
  static Future<bool> changePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      return true;
    } catch (e) {
      print('Error cambiando contraseña: $e');
      throw e;
    }
  }

  // =============== MENÚS ===============

  /// Crea un nuevo menú
  static Future<MenuModel> createMenu(String name, String? description) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      final response = await _supabase
          .from('menus')
          .insert({
            'name': name,
            'description': description,
            'created_by': userId,
          })
          .select()
          .single();

      return MenuModel.fromJson(response);
    } catch (e) {
      print('Error creando menú: $e');
      throw e;
    }
  }

  /// Obtiene todos los menús
  static Future<List<MenuModel>> getAllMenus() async {
    try {
      final response = await _supabase
          .from('menus')
          .select('*')
          .order('created_at', ascending: false);

      return response.map((json) => MenuModel.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo menús: $e');
      throw e;
    }
  }

  /// Actualiza un menú existente
  static Future<MenuModel> updateMenu({
    required String menuId,
    required String name,
    String? description,
  }) async {
    try {
      await _supabase.from('menus').update({
        'name': name,
        'description': description,
      }).eq('id', menuId);

      // Obtener el menú actualizado
      final response =
          await _supabase.from('menus').select('*').eq('id', menuId).single();

      return MenuModel.fromJson(response);
    } catch (e) {
      print('Error actualizando menú: $e');
      throw e;
    }
  }

  /// Elimina un menú
  static Future<bool> deleteMenu(String menuId) async {
    try {
      await _supabase.from('menus').delete().eq('id', menuId);

      return true;
    } catch (e) {
      print('Error eliminando menú: $e');
      throw e;
    }
  }

  // =============== INGREDIENTES ===============

  /// Crea un nuevo ingrediente
  static Future<IngredientModel> createIngredient(String name) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      final response = await _supabase
          .from('ingredients')
          .insert({
            'name': name,
            'created_by': userId,
          })
          .select()
          .single();

      return IngredientModel.fromJson(response);
    } catch (e) {
      print('Error creando ingrediente: $e');
      throw e;
    }
  }

  /// Obtiene todos los ingredientes
  static Future<List<IngredientModel>> getAllIngredients() async {
    try {
      final response = await _supabase
          .from('ingredients')
          .select('*')
          .order('created_at', ascending: false);

      return response.map((json) => IngredientModel.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo ingredientes: $e');
      throw e;
    }
  }

  /// Actualiza un ingrediente existente
  static Future<IngredientModel> updateIngredient({
    required String ingredientId,
    required String name,
    String? category,
  }) async {
    try {
      await _supabase.from('ingredients').update({
        'name': name,
        'category': category,
      }).eq('id', ingredientId);

      // Obtener el ingrediente actualizado
      final response = await _supabase
          .from('ingredients')
          .select('*')
          .eq('id', ingredientId)
          .single();

      return IngredientModel.fromJson(response);
    } catch (e) {
      print('Error actualizando ingrediente: $e');
      throw e;
    }
  }

  /// Elimina un ingrediente
  static Future<bool> deleteIngredient(String ingredientId) async {
    try {
      await _supabase.from('ingredients').delete().eq('id', ingredientId);

      return true;
    } catch (e) {
      print('Error eliminando ingrediente: $e');
      throw e;
    }
  }

  /// Verifica si el usuario actual es admin
  static Future<bool> isCurrentUserAdmin() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response =
          await _supabase.rpc('is_admin', params: {'user_uuid': userId});
      return response as bool;
    } catch (e) {
      print('Error verificando rol admin: $e');
      return false;
    }
  }
}
