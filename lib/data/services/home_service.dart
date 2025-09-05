import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/menu_model.dart';
import '../models/daily_menu_model.dart';
import '../models/ingredient_model.dart';
import '../models/shopping_item_model.dart';

/// Servicio para manejar datos del home y funcionalidades principales
class HomeService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Inicializa los menús semanales para el usuario actual
  static Future<void> initializeWeeklyMenus() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      await _supabase
          .rpc('initialize_user_weekly_menus', params: {'user_uuid': userId});
    } catch (e) {
      print('Error inicializando menús semanales: $e');
      throw e;
    }
  }

  /// Obtiene los menús diarios del usuario
  static Future<List<DailyMenuModel>> getDailyMenus() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      final response = await _supabase.from('daily_menus').select('''
            *,
            menu:menu_id(id, name, description, created_at, updated_at),
            actual_menu:actual_menu_id(id, name, description, created_at, updated_at)
          ''').eq('user_id', userId).order('order_position');

      return response.map((json) => DailyMenuModel.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo menús diarios: $e');
      throw e;
    }
  }

  /// Busca menús disponibles
  static Future<List<MenuModel>> searchMenus(String query) async {
    try {
      final response = await _supabase
          .from('menus')
          .select('*')
          .ilike('name', '%$query%')
          .order('name');

      return response.map((json) => MenuModel.fromJson(json)).toList();
    } catch (e) {
      print('Error buscando menús: $e');
      throw e;
    }
  }

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

  /// Asigna un menú a un día específico
  static Future<void> assignMenuToDay(String dailyMenuId, String menuId) async {
    try {
      await _supabase
          .from('daily_menus')
          .update({'menu_id': menuId}).eq('id', dailyMenuId);
    } catch (e) {
      print('Error asignando menú: $e');
      throw e;
    }
  }

  /// Reordena los menús diarios
  static Future<void> reorderDailyMenus(
      List<DailyMenuModel> reorderedMenus) async {
    try {
      final updates = reorderedMenus.asMap().entries.map((entry) {
        final index = entry.key;
        final menu = entry.value;

        return {
          'id': menu.id,
          'order_position': index,
        };
      }).toList();

      for (final update in updates) {
        await _supabase
            .from('daily_menus')
            .update({'order_position': update['order_position']}).eq(
                'id', update['id']!);
      }
    } catch (e) {
      print('Error reordenando menús: $e');
      throw e;
    }
  }

  /// Obtiene la lista de compras del usuario
  static Future<List<ShoppingItemModel>> getShoppingList() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      final response = await _supabase.from('shopping_list').select('''
            *,
            ingredient:ingredient_id(id, name, category, created_at)
          ''').eq('user_id', userId).order('created_at', ascending: false);

      return response.map((json) => ShoppingItemModel.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo lista de compras: $e');
      throw e;
    }
  }

  /// Busca ingredientes
  static Future<List<IngredientModel>> searchIngredients(String query) async {
    try {
      final response = await _supabase
          .from('ingredients')
          .select('*')
          .ilike('name', '%$query%')
          .order('name');

      return response.map((json) => IngredientModel.fromJson(json)).toList();
    } catch (e) {
      print('Error buscando ingredientes: $e');
      throw e;
    }
  }

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

  /// Agrega un ingrediente a la lista de compras
  static Future<void> addToShoppingList(
      String ingredientId, String? quantity) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      await _supabase.from('shopping_list').insert({
        'user_id': userId,
        'ingredient_id': ingredientId,
        'quantity': quantity,
      });
    } catch (e) {
      print('Error agregando a lista de compras: $e');
      throw e;
    }
  }

  /// Marca un item como comprado/no comprado
  static Future<void> toggleShoppingItemPurchased(
      String itemId, bool isPurchased) async {
    try {
      await _supabase
          .from('shopping_list')
          .update({'is_purchased': isPurchased}).eq('id', itemId);
    } catch (e) {
      print('Error actualizando item: $e');
      throw e;
    }
  }

  /// Elimina un item de la lista de compras
  static Future<void> removeFromShoppingList(String itemId) async {
    try {
      await _supabase.from('shopping_list').delete().eq('id', itemId);
    } catch (e) {
      print('Error eliminando item: $e');
      throw e;
    }
  }
}
