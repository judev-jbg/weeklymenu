import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/daily_menu_model.dart';
// import '../models/menu_model.dart';
import 'notification_service.dart';

/// Servicio para manejar la gestión de menús pendientes
class MenuManagementService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtiene un menú diario por ID
  static Future<DailyMenuModel?> getDailyMenuById(String id) async {
    try {
      final response = await _supabase.from('daily_menus').select('''
            *,
            menu:menu_id(id, name, description, created_at, updated_at),
            actual_menu:actual_menu_id(id, name, description, created_at, updated_at)
          ''').eq('id', id).maybeSingle();

      if (response == null) return null;
      return DailyMenuModel.fromJson(response);
    } catch (e) {
      print('Error obteniendo menú diario: $e');
      return null;
    }
  }

  /// Marca un menú como completado
  static Future<bool> markMenuAsCompleted(String dailyMenuId) async {
    try {
      await _supabase
          .from('daily_menus')
          .update({'status': 'completed'}).eq('id', dailyMenuId);

      // Cancelar notificaciones futuras para este menú
      await NotificationService.cancelMenuNotifications(dailyMenuId);

      return true;
    } catch (e) {
      print('Error marcando menú como completado: $e');
      return false;
    }
  }

  /// Marca un menú como no completado y permite asignar menú alternativo
  static Future<bool> markMenuAsNotCompleted({
    required String dailyMenuId,
    required String actualMenuId,
    bool recycleForNextWeek = false,
  }) async {
    try {
      // Actualizar el menú diario
      await _supabase.from('daily_menus').update({
        'status': 'not_completed',
        'actual_menu_id': actualMenuId,
      }).eq('id', dailyMenuId);

      // Si se debe reciclar para la siguiente semana
      if (recycleForNextWeek) {
        await _recycleMenuForNextWeek(dailyMenuId);
      }

      // Cancelar notificaciones futuras para este menú
      await NotificationService.cancelMenuNotifications(dailyMenuId);

      return true;
    } catch (e) {
      print('Error marcando menú como no completado: $e');
      return false;
    }
  }

  /// Recicla un menú para la siguiente semana
  static Future<void> _recycleMenuForNextWeek(String dailyMenuId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Obtener el menú original
      final dailyMenu = await getDailyMenuById(dailyMenuId);
      if (dailyMenu?.menuId == null) return;

      // Encontrar la siguiente semana disponible
      final nextWeekStart = _getNextWeekStart();

      // Buscar el primer día disponible de la siguiente semana
      final availableSlot =
          await _findAvailableSlotNextWeek(userId, nextWeekStart);
      if (availableSlot == null) return;

      // Asignar el menú al slot disponible
      await _supabase
          .from('daily_menus')
          .update({'menu_id': dailyMenu!.menuId}).eq('id', availableSlot['id']);

      print('Menú reciclado para la siguiente semana');
    } catch (e) {
      print('Error reciclando menú: $e');
    }
  }

  /// Obtiene el inicio de la siguiente semana (sábado)
  static DateTime _getNextWeekStart() {
    final now = DateTime.now();
    final currentWeekday = now.weekday;

    // Calcular días hasta el próximo sábado
    int daysToAdd;
    if (currentWeekday == DateTime.saturday) {
      daysToAdd = 7; // Si es sábado, ir al siguiente sábado
    } else {
      daysToAdd = (DateTime.saturday - currentWeekday + 7) % 7;
      if (daysToAdd == 0) daysToAdd = 7;
    }

    return DateTime(now.year, now.month, now.day)
        .add(Duration(days: daysToAdd));
  }

  /// Encuentra un slot disponible en la siguiente semana
  static Future<Map<String, dynamic>?> _findAvailableSlotNextWeek(
      String userId, DateTime nextWeekStart) async {
    try {
      // Buscar menús de la siguiente semana que no tengan asignación
      final response = await _supabase
          .from('daily_menus')
          .select('*')
          .gte('date', nextWeekStart.toIso8601String().split('T')[0])
          .lt(
              'date',
              nextWeekStart
                  .add(const Duration(days: 9))
                  .toIso8601String()
                  .split('T')[0])
          .filter('menu_id', 'is', null)
          .order('day_index')
          .limit(1);

      return response.isNotEmpty ? response.first : null;
    } catch (e) {
      print('Error buscando slot disponible: $e');
      return null;
    }
  }

  /// Obtiene menús pendientes de gestión
  static Future<List<DailyMenuModel>> getPendingMenusToManage() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      final response = await _supabase
          .from('daily_menus')
          .select('''
            *,
            menu:menu_id(id, name, description, created_at, updated_at),
            actual_menu:actual_menu_id(id, name, description, created_at, updated_at)
          ''')
          .eq('user_id', userId)
          .eq('status', 'pending')
          .lte('date', yesterday.toIso8601String().split('T')[0])
          .not('menu_id', 'is', null)
          .order('date', ascending: false);

      return response.map((json) => DailyMenuModel.fromJson(json)).toList();
    } catch (e) {
      print('Error obteniendo menús pendientes: $e');
      return [];
    }
  }

  /// Auto-completa menús después de 20 horas
  static Future<void> autoCompleteExpiredMenus() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final cutoffDate = DateTime.now().subtract(const Duration(hours: 20));

      final response = await _supabase
          .from('daily_menus')
          .select('id, date')
          .eq('user_id', userId)
          .eq('status', 'pending')
          .lte('date', cutoffDate.toIso8601String().split('T')[0]);

      for (final menu in response) {
        await markMenuAsCompleted(menu['id']);
        print('Auto-completado menú: ${menu['id']}');
      }
    } catch (e) {
      print('Error auto-completando menús: $e');
    }
  }
}
