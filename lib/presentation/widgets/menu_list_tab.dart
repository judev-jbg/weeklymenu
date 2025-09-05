import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../widgets/menu_edit_modal.dart';
import '../../data/models/menu_model.dart';

/// Tab para gestionar menús (solo admin)
class MenuListTab extends StatelessWidget {
  const MenuListTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return Stack(
      children: [
        // Contenido principal
        Column(
          children: [
            // Header con botón de agregar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gestión de Menús',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  ElevatedButton.icon(
                    onPressed: controller.showCreateMenuModal,
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo Menú'),
                  ),
                ],
              ),
            ),

            // Lista de menús
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.menus.isEmpty) {
                  return const Center(
                    child: Text('No hay menús creados'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.menus.length,
                  itemBuilder: (context, index) {
                    final menu = controller.menus[index];
                    return _buildMenuCard(context, controller, menu);
                  },
                );
              }),
            ),
          ],
        ),

        // Modal de menú
        Obx(() => controller.showMenuModal.value
            ? const MenuEditModal()
            : const SizedBox.shrink()),
      ],
    );
  }

  /// Construye una card de menú
  Widget _buildMenuCard(
      BuildContext context, SettingsController controller, MenuModel menu) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Colors.orange,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Información del menú
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (menu.description != null &&
                        menu.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        menu.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Creado: ${_formatDate(menu.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              ),

              // Acciones
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      controller.showEditMenuModal(menu);
                      break;
                    case 'delete':
                      controller.deleteMenu(menu);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Editar'),
                      dense: true,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title:
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                      dense: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formatea una fecha
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
