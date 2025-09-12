import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../widgets/animated_bottom_sheet.dart';

/// Modal para asignar o editar menú
class AssignMenuModal extends StatelessWidget {
  final bool isEdit;
  final VoidCallback onClose;

  const AssignMenuModal({
    Key? key,
    required this.isEdit,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return AnimatedBottomSheet(
      isVisible: true,
      onDismiss: onClose,
      initialChildSize: 0.9,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              isEdit ? 'Editar menú' : 'Asigna un menú',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),

            const SizedBox(height: 24),

            // Barra de búsqueda
            TextField(
              controller: controller.menuSearchController,
              onChanged: controller.searchMenus,
              decoration: InputDecoration(
                hintText: 'Buscar menú...',
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
                  return Center(
                    child: Text(
                      'Ingrese el nombre del menú para buscar',
                      style: Theme.of(Get.context!).textTheme.labelMedium,
                    ),
                  );
                }

                return Column(
                  children: [
                    // Opción para crear nuevo menú si no hay coincidencias exactas
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
                              controller.selectedMenu.value?.id == menu.id;

                          return Column(children: [
                            ListTile(
                              title: Text(menu.name,
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)),
                              subtitle: menu.description != null
                                  ? Text(menu.description!)
                                  : null,
                              selected: isSelected,
                              selectedTileColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              onTap: () => controller.selectedMenu.value = menu,
                              trailing:
                                  isSelected ? const Icon(Icons.check) : null,
                            ),
                            Divider(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.5), // Color de la línea
                              height: 20, // Espacio vertical total
                              thickness: 1, // Grosor de la línea
                              indent: 20, // Sangría izquierda
                              endIndent: 20, // Sangría derecha
                            ),
                          ]);
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),

            const SizedBox(height: 16),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onClose,
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
                        onPressed: controller.selectedMenu.value != null
                            ? controller.assignMenuToDay
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Asignar'),
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
  Widget _buildCreateOption(BuildContext context, HomeController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
        title: Obx(() => Text(
            '+ Crear "${controller.menuSearchQuery.value}" en la lista de menús y asignarlo al día')),
        onTap: () =>
            controller.createAndAssignMenu(controller.menuSearchQuery.value),
        tileColor: Colors.grey[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
