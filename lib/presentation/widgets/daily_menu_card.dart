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
    final isCompleted = dailyMenu.status != MenuStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onDoubleTap: isCompleted ? null : onDoubleTap,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isCompleted
                  ? Theme.of(context).cardColor.withOpacity(0.5)
                  : Theme.of(context).cardColor,
            ),
            child: Row(
              children: [
                // Indicador de día
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getDayColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      dailyMenu.dayName,
                      style: const TextStyle(
                        color: Colors.white,
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
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCompleted
                                  ? Colors.grey[600]
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
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                      ),

                      // Estado si está completado
                      if (isCompleted) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              dailyMenu.status == MenuStatus.completed
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              size: 16,
                              color: dailyMenu.status == MenuStatus.completed
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dailyMenu.status == MenuStatus.completed
                                  ? 'Cumplido'
                                  : 'No cumplido',
                              style: TextStyle(
                                fontSize: 12,
                                color: dailyMenu.status == MenuStatus.completed
                                    ? Colors.green
                                    : Colors.orange,
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
      case 0: // Sábado
      case 8: // Domingo siguiente
        return Colors.purple;
      case 1: // Domingo
        return Colors.red;
      case 2: // Lunes
        return Colors.blue;
      case 3: // Martes
        return Colors.green;
      case 4: // Miércoles
        return Colors.orange;
      case 5: // Jueves
        return Colors.teal;
      case 6: // Viernes
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}
