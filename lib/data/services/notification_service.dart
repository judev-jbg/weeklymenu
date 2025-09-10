import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../models/daily_menu_model.dart';
import 'package:timezone/timezone.dart' as tz;
// import '../models/notification_model.dart';

/// Servicio para manejar notificaciones push y locales
class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Textos aleatorios para notificaciones
  static const List<String> _notificationTexts = [
    "Hoy tenías en mente un festín de {menu}… ¿Se hizo realidad o se quedó en sueño gastronómico?",
    "¡El plan del día era {menu}! ¿Lo conquistaste o cambiaste de rumbo culinario?",
    "Hoy tocaba {menu} en el menú… ¿cumpliste la misión o improvisaste como un chef rebelde?",
    "El menú decía {menu}, pero… ¿tu estómago estuvo de acuerdo?",
  ];

  /// Inicializa el servicio de notificaciones
  static Future<void> initialize() async {
    // Configurar notificaciones locales
    await _initializeLocalNotifications();

    // Configurar Firebase Messaging
    await _initializeFirebaseMessaging();

    // Programar notificaciones diarias
    await _scheduleDailyNotifications();
  }

  /// Inicializa las notificaciones locales
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Solicitar permisos
    await _requestNotificationPermissions();
  }

  /// Inicializa Firebase Messaging
  static Future<void> _initializeFirebaseMessaging() async {
    // Solicitar permisos
    await _firebaseMessaging.requestPermission();

    // Obtener token FCM
    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Manejar mensajes cuando la app está en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Manejar taps en notificaciones cuando la app está en background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);
  }

  /// Solicita permisos de notificación
  /// Solicita permisos de notificación
  static Future<bool> _requestNotificationPermissions() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? granted =
            await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }
      return false;
    } catch (e) {
      print('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Programa las notificaciones diarias a las 20:00
  static Future<void> _scheduleDailyNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Obtener menús del usuario para los próximos días
      final response = await _supabase
          .from('daily_menus')
          .select('''
            *,
            menu:menu_id(id, name, description)
          ''')
          .eq('status', 'pending')
          .gte('date', DateTime.now().toIso8601String().split('T')[0]);

      final dailyMenus =
          response.map((json) => DailyMenuModel.fromJson(json)).toList();

      // Programar notificación para cada menú
      for (final dailyMenu in dailyMenus) {
        if (dailyMenu.hasMenuAssigned) {
          await _scheduleDailyMenuNotification(dailyMenu);
        }
      }
    } catch (e) {
      print('Error programando notificaciones: $e');
    }
  }

  /// Programa una notificación para un menú específico
  static Future<void> _scheduleDailyMenuNotification(
      DailyMenuModel dailyMenu) async {
    if (!dailyMenu.hasMenuAssigned) return;

    // Programar notificación principal a las 20:00
    final scheduledDate = DateTime(
      dailyMenu.date.year,
      dailyMenu.date.month,
      dailyMenu.date.day,
      20, // 8 PM
      0,
    );

    // Solo programar si es en el futuro
    if (scheduledDate.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: dailyMenu.id.hashCode,
        title: 'Weekly Menu',
        body: _getRandomNotificationText(dailyMenu.menu!.name),
        scheduledDate: scheduledDate,
        payload: 'menu_reminder:${dailyMenu.id}',
      );
    }

    // Programar notificación de seguimiento (15 horas después)
    final followUpDate = scheduledDate.add(const Duration(hours: 15));
    if (followUpDate.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: dailyMenu.id.hashCode + 1000,
        title: 'Weekly Menu - Recordatorio',
        body:
            '¿Ya gestionaste tu menú de ${dailyMenu.menu!.name}? ¡No olvides registrar si lo cumpliste!',
        scheduledDate: followUpDate,
        payload: 'menu_followup:${dailyMenu.id}',
      );
    }
  }

  /// Programa una notificación específica
  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'menu_reminders',
          'Menu Reminders',
          channelDescription: 'Recordatorios de menús diarios',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Obtiene un texto aleatorio para la notificación
  static String _getRandomNotificationText(String menuName) {
    final random = Random();
    final template =
        _notificationTexts[random.nextInt(_notificationTexts.length)];
    return template.replaceAll('{menu}', menuName);
  }

  /// Maneja tap en notificación
  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      _handleNotificationPayload(payload);
    }
  }

  /// Maneja mensajes en foreground
  static void _handleForegroundMessage(RemoteMessage message) {
    print('Mensaje recibido en foreground: ${message.notification?.title}');
    // Mostrar notificación local
    _showLocalNotification(
      title: message.notification?.title ?? 'Weekly Menu',
      body: message.notification?.body ?? '',
      payload: message.data['payload'],
    );
  }

  /// Maneja tap en mensaje de background
  static void _handleBackgroundMessageTap(RemoteMessage message) {
    final payload = message.data['payload'];
    if (payload != null) {
      _handleNotificationPayload(payload);
    }
  }

  /// Procesa el payload de la notificación
  static void _handleNotificationPayload(String payload) {
    final parts = payload.split(':');
    if (parts.length != 2) return;

    final type = parts[0];
    final menuId = parts[1];

    switch (type) {
      case 'menu_reminder':
      case 'menu_followup':
        // Navegar a gestión de menú pendiente
        Get.toNamed('/menu-management', arguments: {'dailyMenuId': menuId});
        break;
    }
  }

  /// Muestra una notificación local
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'menu_reminders',
          'Menu Reminders',
          channelDescription: 'Recordatorios de menús diarios',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  /// Guarda una notificación en la base de datos
  static Future<void> saveNotificationToDatabase({
    required String title,
    required String body,
    required String type,
    String? dailyMenuId,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'daily_menu_id': dailyMenuId,
      });
    } catch (e) {
      print('Error guardando notificación: $e');
    }
  }

  /// Cancela todas las notificaciones programadas
  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Cancela notificaciones para un menú específico
  static Future<void> cancelMenuNotifications(String dailyMenuId) async {
    final id = dailyMenuId.hashCode;
    await _localNotifications.cancel(id);
    await _localNotifications.cancel(id + 1000);
  }

  /// Programa auto-completado de menú después de 20 horas
  static Future<void> scheduleAutoComplete(DailyMenuModel dailyMenu) async {
    final autoCompleteDate = DateTime(
      dailyMenu.date.year,
      dailyMenu.date.month,
      dailyMenu.date.day,
      20, // 8 PM del día
    ).add(const Duration(hours: 20)); // 20 horas después

    if (autoCompleteDate.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: dailyMenu.id.hashCode + 2000,
        title: 'Weekly Menu - Auto Completado',
        body: 'Menú marcado como completado automáticamente',
        scheduledDate: autoCompleteDate,
        payload: 'auto_complete:${dailyMenu.id}',
      );
    }
  }
}
