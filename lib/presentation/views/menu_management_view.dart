import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/menu_management_controller.dart';
import '../widgets/alternative_menu_modal.dart';
import '../../core/theme/app_theme.dart';

/// Vista para gestionar menús pendientes
class MenuManagementView extends StatelessWidget {
  const MenuManagementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MenuManagementController>(
      init: MenuManagementController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Gestión de Menús'),
            centerTitle: true,
            actions: [
              // Contador de menús pendientes
              Obx(() => controller.hasPendingMenus
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          controller.currentMenuIndex,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
          body: Stack(
            children: [
              // Contenido principal
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!controller.hasPendingMenus) {
                  return _buildEmptyState(context);
                }

                return _buildMenuManagementContent(context, controller);
              }),

              // Modal de menú alternativo
              Obx(() => controller.showAlternativeMenuModal.value
                  ? const AlternativeMenuModal()
                  : const SizedBox.shrink()),
            ],
          ),
        );
      },
    );
  }

  /// Construye el estado vacío cuando no hay menús pendientes
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SVG o icono placeholder
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 60,
              color: Colors.green[400],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'No hay menús pendientes de gestionar',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            '¡Excelente! Has gestionado todos tus menús',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Volver al Inicio'),
          ),
        ],
      ),
    );
  }

  /// Construye el contenido de gestión de menús
  Widget _buildMenuManagementContent(
      BuildContext context, MenuManagementController controller) {
    return Obx(() {
      final currentMenu = controller.currentMenuManagement.value;
      if (currentMenu == null) return const SizedBox.shrink();

      return Column(
        children: [
          // Navegación entre menús
          if (controller.pendingMenus.length > 1)
            _buildMenuNavigation(context, controller),

          // Contenido principal del menú
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card del menú
                  _buildMenuCard(context, currentMenu),

                  const SizedBox(height: 32),

                  // Pregunta principal
                  _buildMainQuestion(context),

                  const SizedBox(height: 24),

                  // Botones de acción
                  _buildActionButtons(context, controller),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  /// Construye la navegación entre menús
  Widget _buildMenuNavigation(
      BuildContext context, MenuManagementController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón anterior
          IconButton(
            onPressed: controller.goToPreviousMenu,
            icon: const Icon(Icons.arrow_back_ios),
            tooltip: 'Menú anterior',
          ),

          // Indicador de posición
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Obx(() => Text(
                  controller.currentMenuIndex,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                )),
          ),

          // Botón siguiente
          IconButton(
            onPressed: controller.goToNextMenu,
            icon: const Icon(Icons.arrow_forward_ios),
            tooltip: 'Menú siguiente',
          ),
        ],
      ),
    );
  }

  /// Construye la card del menú actual
  Widget _buildMenuCard(BuildContext context, dynamic currentMenu) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fecha
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  currentMenu.formattedDate,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Nombre del menú
            Text(
              currentMenu.menu?.name ?? 'Menú sin nombre',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
            ),

            const SizedBox(height: 8),

            // Descripción si existe
            if (currentMenu.menu?.description != null) ...[
              Text(
                currentMenu.menu!.description!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 16),
            ],

            // Estado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.orange[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Pendiente de gestión',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la pregunta principal
  Widget _buildMainQuestion(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Cumpliste con este menú?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona una opción para gestionar este menú del día',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  /// Construye los botones de acción
  Widget _buildActionButtons(
      BuildContext context, MenuManagementController controller) {
    return Column(
      children: [
        // Botón Cumplido
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.markAsCompleted,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text(
              'Sí, lo cumplí',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Botón No Cumplido
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: controller.showAlternativeMenuSelection,
            icon: Icon(Icons.restaurant, color: Colors.orange[700]),
            label: Text(
              'No, comí algo diferente',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.orange[700],
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.orange[700]!),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
