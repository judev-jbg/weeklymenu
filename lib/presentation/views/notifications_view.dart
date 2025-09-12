import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/notifications_controller.dart';
import '../../data/models/notification_model.dart';

/// Vista para mostrar las notificaciones del usuario
class NotificationsView extends StatelessWidget {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationsController>(
      init: NotificationsController(),
      builder: (controller) {
        return Scaffold(
          body: Column(
            children: [
              AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  statusBarColor: Theme.of(Get.context!)
                      .primaryColor, // Mismo color que tu container
                  statusBarBrightness: Brightness.dark, // Para iOS
                  statusBarIconBrightness: Brightness
                      .dark, // Color de los iconos (claro sobre fondo dorado)
                ),
                // Header con fondo y esquinas redondeadas
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    color: Theme.of(Get.context!).primaryColor,
                    child: SafeArea(
                      bottom: false, // No aplicar SafeArea en la parte inferior

                      child: _buildHeader(context, controller),
                    ),
                  ),
                ),
              ),

              // Contenido de notificaciones
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.notifications.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return RefreshIndicator(
                    onRefresh: controller.refresh,
                    child: ListView.builder(
                      itemCount: controller.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = controller.notifications[index];
                        return _buildNotificationCard(
                            context, notification, controller);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construye el header superior
  Widget _buildHeader(
      BuildContext context, NotificationsController controller) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 30, bottom: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón de regreso
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(Get.context!).colorScheme.onPrimary,
              size: 24,
            ),
          ),

          // Título
          Expanded(
            child: Text(
              'Notificaciones',
              style: TextStyle(
                color: Theme.of(Get.context!).colorScheme.onPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Botón marcar todas como leídas
          Obx(() => controller.unreadCount.value > 0
              ? TextButton(
                  onPressed: controller.markAllAsRead,
                  child: Text(
                    'Marcar todas',
                    style: TextStyle(
                      color: Theme.of(Get.context!).colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : const SizedBox(
                  width: 48)), // Espaciado para mantener centrado el título
        ],
      ),
    );
  }

  /// Construye el estado vacío
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay notificaciones',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Te notificaremos cuando tengas algo nuevo.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Construye una card de notificación
  Widget _buildNotificationCard(BuildContext context,
      NotificationModel notification, NotificationsController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: notification.isRead ? 1 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: notification.isRead
                  ? Colors.grey[100]
                  : Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: notification.isRead
                  ? Colors.grey[600]
                  : Theme.of(context).primaryColor,
            ),
          ),
          title: Text(
            notification.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight:
                      notification.isRead ? FontWeight.w500 : FontWeight.w600,
                  color: notification.isRead ? Colors.grey[700] : null,
                ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.body,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: notification.isRead
                          ? Colors.grey[600]
                          : Colors.grey[700],
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                notification.timeAgo,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
            ],
          ),
          trailing: !notification.isRead
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
              : null,
          onTap: () => controller.handleNotificationTap(notification),
        ),
      ),
    );
  }

  /// Obtiene el icono según el tipo de notificación
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'menu_reminder':
        return Icons.restaurant_menu;
      case 'menu_followup':
        return Icons.schedule;
      default:
        return Icons.notifications;
    }
  }
}
