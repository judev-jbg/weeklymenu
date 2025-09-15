import 'package:flutter/material.dart';
import '../../data/models/daily_menu_model.dart';

/// Card que muestra un menú diario
class DailyMenuCard extends StatelessWidget {
  final DailyMenuModel dailyMenu;
  final VoidCallback onDoubleTap;
  final bool isReorderable;

  const DailyMenuCard({
    Key? key,
    required this.dailyMenu,
    required this.onDoubleTap,
    this.isReorderable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCompleted = dailyMenu.status != MenuStatus.unassigned;
    final hasMenuAssigned = dailyMenu.hasMenuAssigned;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onDoubleTap: (dailyMenu.status == MenuStatus.expired ||
                dailyMenu.status == MenuStatus.completed)
            ? null
            : onDoubleTap,
        child: Card(
          elevation: dailyMenu.status == MenuStatus.completed ||
                  dailyMenu.status == MenuStatus.expired
              ? 1.0
              : 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: dailyMenu.status == MenuStatus.completed ||
                  dailyMenu.status == MenuStatus.expired
              ? Theme.of(context).cardTheme.surfaceTintColor
              : Theme.of(context).cardTheme.color,
          child: Container(
            padding: const EdgeInsets.all(16),
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.circular(16),
            //   color: dailyMenu.status == MenuStatus.completed ||
            //           dailyMenu.status == MenuStatus.expired
            //       ? Theme.of(context).cardTheme.color
            //       : Theme.of(context).cardTheme.color?.withOpacity(0.2),
            // ),
            child: Row(
              children: [
                // Indicador de día
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: dailyMenu.status == MenuStatus.completed ||
                            dailyMenu.status == MenuStatus.expired
                        ? _getDayColor().withOpacity(0.2)
                        : _getDayColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      dailyMenu.dayName,
                      style: TextStyle(
                        color: dailyMenu.status == MenuStatus.completed ||
                                dailyMenu.status == MenuStatus.expired
                            ? Colors.white.withOpacity(0.5)
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Contenido principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título del menú
                      Text(
                        dailyMenu.displayTitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration:
                                  dailyMenu.status == MenuStatus.completed ||
                                          dailyMenu.status == MenuStatus.expired
                                      ? TextDecoration.lineThrough
                                      : null,
                              decorationColor:
                                  dailyMenu.status == MenuStatus.completed ||
                                          dailyMenu.status == MenuStatus.expired
                                      ? Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color
                                          ?.withOpacity(0.8)
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                              color: dailyMenu.status == MenuStatus.completed ||
                                      dailyMenu.status == MenuStatus.expired
                                  ? Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color
                                      ?.withOpacity(0.5)
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Fecha
                      Text(
                        dailyMenu.formattedDate,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity((dailyMenu.status ==
                                                  MenuStatus.completed ||
                                              dailyMenu.status ==
                                                  MenuStatus.expired)
                                          ? 0.6 // Opacidad reducida para estados completed/expired
                                          : 1.0 // Opacidad completa para otros estados
                                      ),
                            ),
                      ),

                      // Estado si está completado
                      if (isCompleted && hasMenuAssigned) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                                dailyMenu.status == MenuStatus.completed
                                    ? Icons.check_circle
                                    : Icons.watch_later_outlined,
                                size: 16,
                                color: dailyMenu.status == MenuStatus.completed
                                    ? Theme.of(context)
                                        .colorScheme
                                        .scrim
                                        .withOpacity(0.5)
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              () {
                                switch (dailyMenu.status) {
                                  case MenuStatus.completed:
                                    return 'Cumplido';
                                  case MenuStatus.notCompleted:
                                    return 'No cumplido';
                                  case MenuStatus.pending:
                                    return 'Pendiente';
                                  case MenuStatus.expired:
                                    return '';
                                  default:
                                    return 'Desconocido';
                                }
                              }(),
                              style: TextStyle(
                                fontSize: 12,
                                color: dailyMenu.status == MenuStatus.completed
                                    ? Theme.of(context)
                                        .colorScheme
                                        .scrim
                                        .withOpacity(0.5)
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Icono de reordenamiento si está activo
                if (isReorderable)
                  Icon(
                    Icons.drag_handle,
                    color: Colors.grey[400],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Obtiene el color según el día de la semana
  Color _getDayColor() {
    switch (dailyMenu.dayIndex) {
      case 0: // Sábado anterior
        return const Color(0xFFBA52CC);
      case 1: // Domingo
        return const Color(0xFFCA4C43);
      case 2: // Lunes
        return const Color(0xFF3D96DF);
      case 3: // Martes
        return const Color(0xFF5EB961);
      case 4: // Miércoles
        return const Color(0xFFE9A034);
      case 5: // Jueves
        return const Color(0xFF2AAC9F);
      case 6: // Viernes
        return const Color(0xFF5B6EDD);
      case 7: // Viernes
        return const Color(0xFFA14582);
      case 8: // Viernes
        return const Color(0xFFD3D14F);
      default:
        return Colors.grey;
    }
  }
}
