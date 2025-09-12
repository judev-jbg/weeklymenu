import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../widgets/animated_bottom_sheet.dart';

/// Modal para agregar ingrediente a la lista de compras
class AddIngredientModal extends StatelessWidget {
  const AddIngredientModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return AnimatedBottomSheet(
      isVisible: true,
      onDismiss: () => controller.showShoppingModal.value = false,
      initialChildSize: 0.9,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              'Agregar a la lista',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),

            const SizedBox(height: 24),

            // Barra de búsqueda
            TextField(
              controller: controller.ingredientSearchController,
              onChanged: controller.searchIngredients,
              style: Theme.of(Get.context!).textTheme.labelMedium,
              decoration: InputDecoration(
                hintText: 'Buscar ingrediente...',
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
                return Column(
                  verticalDirection: VerticalDirection.up,
                  children: [
                    // Opción para crear nuevo ingrediente
                    if (controller.ingredientSearchQuery.value.isNotEmpty &&
                        (controller.ingredientSearchResults.isEmpty ||
                            !controller.ingredientSearchResults.any(
                                (ingredient) =>
                                    ingredient.name.toLowerCase() ==
                                    controller.ingredientSearchQuery.value
                                        .toLowerCase())))
                      _buildCreateOption(context, controller),

                    // Lista de ingredientes existentes
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(0),
                        itemCount: controller.ingredientSearchResults.length,
                        itemBuilder: (context, index) {
                          final ingredient =
                              controller.ingredientSearchResults[index];
                          final isSelected =
                              controller.selectedIngredient.value?.id ==
                                  ingredient.id;

                          return Column(children: [
                            Material(
                              color: Theme.of(context)
                                  .cardTheme
                                  .color
                                  ?.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                              child: ListTile(
                                title: Text(ingredient.name,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                                subtitle: ingredient.category != null
                                    ? Text(ingredient.category!)
                                    : null,
                                selected: isSelected,
                                selectedTileColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                onTap: () => controller
                                    .selectedIngredient.value = ingredient,
                                trailing:
                                    isSelected ? const Icon(Icons.check) : null,
                              ),
                            ),
                            Divider(
                              color: Theme.of(context)
                                  .colorScheme
                                  .background, // Color de la línea
                              height: 10, // Espacio vertical total
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
                    onPressed: () => controller.showShoppingModal.value = false,
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
                        onPressed: controller.selectedIngredient.value != null
                            ? controller.addToShoppingList
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Agregar'),
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

  /// Construye la opción para crear un nuevo ingrediente
  Widget _buildCreateOption(BuildContext context, HomeController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5, top: 8),
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
            'Crear "${controller.ingredientSearchQuery.value}" y agregar a la lista')),
        onTap: () => controller
            .createAndAddIngredient(controller.ingredientSearchQuery.value),
      ),
    );
  }
}
