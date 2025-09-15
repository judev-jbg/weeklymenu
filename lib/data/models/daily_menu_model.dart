import 'package:weekly_menu/data/models/menu_model.dart';

/// Estados posibles de un menú diario
enum MenuStatus {
  pending('pending'),
  completed('completed'),
  notCompleted('not_completed'),
  unassigned('unassigned'),
  expired('expired');

  const MenuStatus(this.value);
  final String value;

  static MenuStatus fromString(String value) {
    switch (value) {
      case 'completed':
        return MenuStatus.completed;
      case 'not_completed':
        return MenuStatus.notCompleted;
      case 'pending':
        return MenuStatus.pending;
      case 'expired':
        return MenuStatus.expired;
      case 'unassigned':
      default:
        return MenuStatus.unassigned;
    }
  }
}

/// Modelo para los menús asignados por día
class DailyMenuModel {
  final String id;
  final String? userId;
  final String? menuId;
  final DateTime date;
  final int dayIndex;
  final MenuStatus status;
  final String? actualMenuId;
  final int orderPosition;
  final MenuModel? menu;
  final MenuModel? actualMenu;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyMenuModel({
    required this.id,
    this.userId,
    this.menuId,
    required this.date,
    required this.dayIndex,
    required this.status,
    this.actualMenuId,
    required this.orderPosition,
    this.menu,
    this.actualMenu,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyMenuModel.fromJson(Map<String, dynamic> json) {
    return DailyMenuModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      menuId: json['menu_id'] as String?,
      date: DateTime.parse(json['date'] as String),
      dayIndex: json['day_index'] as int,
      status: MenuStatus.fromString(json['status'] as String),
      actualMenuId: json['actual_menu_id'] as String?,
      orderPosition: json['order_position'] as int,
      menu: json['menu'] != null ? MenuModel.fromJson(json['menu']) : null,
      actualMenu: json['actual_menu'] != null
          ? MenuModel.fromJson(json['actual_menu'])
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  String? get assignedByUserId => userId;

  /// Obtiene el nombre del día de la semana en español
  String get dayName {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[dayIndex];
  }

  /// Obtiene la fecha formateada
  String get formattedDate {
    final months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];

    return '$dayName. ${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  /// Verifica si tiene menú asignado
  bool get hasMenuAssigned => menuId != null;

  /// Obtiene el título para mostrar
  String get displayTitle {
    if (!hasMenuAssigned && status == MenuStatus.unassigned) {
      return 'Toca 2 veces para asignar un menú a este día';
    }

    switch (status) {
      case MenuStatus.completed:
        return menu?.name ?? 'Menú completado';
      case MenuStatus.notCompleted:
        return actualMenu?.name ?? menu?.name ?? 'Menú no completado';
      case MenuStatus.pending:
        return menu?.name ?? 'Menú pendiente';
      case MenuStatus.expired:
        return menu?.name ?? 'No se asignó ningún menú';
      case MenuStatus.unassigned:
        return menu?.name ?? 'Asignar menú';
    }
  }
}
