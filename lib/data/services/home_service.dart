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
      // Calcular los 9 días de la vista actual
      final viewDates = _getCurrentWeekViewDates();

      final response = await _supabase
          .from('daily_menus')
          .select('''
          *,
          menu:menu_id(id, name, description, created_at, updated_at),
          actual_menu:actual_menu_id(id, name, description, created_at, updated_at)
        ''')
          .gte('date', viewDates.start.toIso8601String().split('T')[0])
          .lte('date', viewDates.end.toIso8601String().split('T')[0])
          .order('day_index', ascending: true);

      return response.map((json) => DailyMenuModel.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo menús diarios: $e');
      throw e;
    }
  }

  /// Calcula las fechas de la vista actual (9 días: sábado a domingo siguiente)
  static _WeekViewDates _getCurrentWeekViewDates() {
    final now = DateTime.now();
    final currentWeekday = now.weekday;

    // Encontrar el sábado de esta semana
    final saturdayThisWeek =
        now.subtract(Duration(days: (currentWeekday + 1) % 7));
    final startDate = DateTime(
        saturdayThisWeek.year, saturdayThisWeek.month, saturdayThisWeek.day);
    final endDate = startDate.add(const Duration(days: 8)); // 9 días total

    return _WeekViewDates(start: startDate, end: endDate);
  }

  /// Asigna un menú a un día específico
  static Future<void> assignMenuToDay(String dailyMenuId, String menuId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      await _supabase.from('daily_menus').update({
        'user_id': userId, // Registrar quién hizo la asignación
        'menu_id': menuId,
        'status': 'pending',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', dailyMenuId);
    } catch (e) {
      print('Error asignando menú: $e');
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

  /// Reordena los menús diarios
  static Future<void> reorderDailyMenus(
      int oldIndex, int newIndex, List<DailyMenuModel> dailyMenus) async {
    try {
      if (oldIndex == newIndex) return;

      final oldMenu = dailyMenus[oldIndex];
      final newMenu = dailyMenus[newIndex];

      // Intercambiar solo los menu_id, manteniendo las fechas fijas
      await _supabase.from('daily_menus').update({
        'menu_id': newMenu.menuId,
      }).eq('id', oldMenu.id);

      await _supabase.from('daily_menus').update({
        'menu_id': oldMenu.menuId,
      }).eq('id', newMenu.id);
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
          ''').order('created_at', ascending: false);

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

class _WeekViewDates {
  final DateTime start;
  final DateTime end;

  _WeekViewDates({required this.start, required this.end});
}
