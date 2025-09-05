import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/notification_model.dart';

/// Controlador para la página de notificaciones
class NotificationsController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  /// Carga las notificaciones del usuario
  Future<void> _loadNotifications() async {
    isLoading.value = true;

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .order('sent_at', ascending: false);

      final notificationList =
          response.map((json) => NotificationModel.fromJson(json)).toList();
      notifications.value = notificationList;

      // Contar no leídas
      unreadCount.value = notificationList.where((n) => !n.isRead).length;
    } catch (e) {
      Get.snackbar('Error', 'Error cargando notificaciones: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Marca una notificación como leída
  Future<void> markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true}).eq('id', notification.id);

      // Actualizar localmente
      final index = notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        notifications[index] = notification.copyWith(isRead: true);
        unreadCount.value = notifications.where((n) => !n.isRead).length;
      }
    } catch (e) {
      print('Error marcando notificación como leída: $e');
    }
  }

  /// Marca todas las notificaciones como leídas
  Future<void> markAllAsRead() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      // Actualizar localmente
      notifications.value =
          notifications.map((n) => n.copyWith(isRead: true)).toList();
      unreadCount.value = 0;

      Get.snackbar(
        'Éxito',
        'Todas las notificaciones marcadas como leídas',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Error marcando notificaciones: $e');
    }
  }

  /// Maneja el tap en una notificación
  void handleNotificationTap(NotificationModel notification) {
    // Marcar como leída
    markAsRead(notification);

    // Navegar según el tipo
    if (notification.type == 'menu_reminder' &&
        notification.dailyMenuId != null) {
      Get.toNamed('/menu-management', arguments: {
        'dailyMenuId': notification.dailyMenuId,
      });
    }
  }

  /// Refresca las notificaciones
  Future<void> refresh() async {
    await _loadNotifications();
  }
}
