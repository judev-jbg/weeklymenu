import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/menu_management_controller.dart';
import '../widgets/animated_bottom_sheet.dart';

/// Modal para seleccionar menú alternativo
class AlternativeMenuModal extends StatelessWidget {
  const AlternativeMenuModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MenuManagementController>();

    return AnimatedBottomSheet(
      isVisible: true,
      onDismiss: controller.closeAlternativeMenuModal,
      initialChildSize: 0.85,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              '¿Qué comiste en su lugar?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              'Selecciona el menú que realmente consumiste',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),

            const SizedBox(height: 24),

            // Barra de búsqueda
            TextField(
              controller: controller.menuSearchController,
              onChanged: controller.searchAlternativeMenus,
              decoration: InputDecoration(
                hintText: 'Buscar el menú que comiste...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              autofocus: true,
            ),

            const SizedBox(height: 16),

            // Lista de resultados
            Expanded(
              child: Obx(() {
                if (controller.menuSearchQuery.value.isEmpty) {
                  return const Center(
                    child: Text(
                      'Ingrese el nombre del menú que consumió',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return Column(
                  children: [
                    // Opción para crear nuevo menú
                    if (controller.menuSearchResults.isEmpty ||
                        !controller.menuSearchResults.any((menu) =>
                            menu.name.toLowerCase() ==
                            controller.menuSearchQuery.value.toLowerCase()))
                      _buildCreateOption(context, controller),

                    // Lista de menús existentes
                    Expanded(
                      child: ListView.builder(
                        itemCount: controller.menuSearchResults.length,
                        itemBuilder: (context, index) {
                          final menu = controller.menuSearchResults[index];
                          final isSelected =
                              controller.selectedAlternativeMenu.value?.id ==
                                  menu.id;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(menu.name),
                              subtitle: menu.description != null
                                  ? Text(menu.description!)
                                  : null,
                              selected: isSelected,
                              selectedTileColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              onTap: () => controller
                                  .selectedAlternativeMenu.value = menu,
                              trailing:
                                  isSelected ? const Icon(Icons.check) : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),

            const SizedBox(height: 16),

            // Switch para reciclar menú
            Obx(() => controller.selectedAlternativeMenu.value != null
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¿Reciclar menú original?',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Programar el menú original para la siguiente semana',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: controller.recycleForNextWeek.value,
                          onChanged: (value) =>
                              controller.recycleForNextWeek.value = value,
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink()),

            const SizedBox(height: 16),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.closeAlternativeMenuModal,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => ElevatedButton(
                        onPressed:
                            controller.selectedAlternativeMenu.value != null
                                ? controller.confirmAlternativeMenu
                                : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Confirmar'),
                      )),
                ),
              ],
            ),

            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 24),
          ],
        ),
      ),
    );
  }

  /// Construye la opción para crear un nuevo menú
  Widget _buildCreateOption(
      BuildContext context, MenuManagementController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.add,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Obx(() => Text('+ Crear "${controller.menuSearchQuery.value}"')),
        subtitle: const Text('Agregar nuevo menú a la lista'),
        onTap: () => controller
            .createAndSelectAlternativeMenu(controller.menuSearchQuery.value),
        tileColor: Colors.grey[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
