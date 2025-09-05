import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../widgets/ingredient_edit_modal.dart';
import '../../data/models/ingredient_model.dart';

/// Tab para gestionar ingredientes (solo admin)
class IngredientListTab extends StatelessWidget {
  const IngredientListTab({Key? key}) : super(key: key);

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
                    'Gestión de Ingredientes',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  ElevatedButton.icon(
                    onPressed: controller.showCreateIngredientModal,
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo Ingrediente'),
                  ),
                ],
              ),
            ),

            // Lista de ingredientes agrupados por categoría
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.ingredients.isEmpty) {
                  return const Center(
                    child: Text('No hay ingredientes creados'),
                  );
                }

                // Agrupar por categoría
                final groupedIngredients = <String, List<IngredientModel>>{};
                for (final ingredient in controller.ingredients) {
                  final category = ingredient.category ?? 'Sin categoría';
                  groupedIngredients
                      .putIfAbsent(category, () => [])
                      .add(ingredient);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: groupedIngredients.length,
                  itemBuilder: (context, index) {
                    final category = groupedIngredients.keys.elementAt(index);
                    final ingredients = groupedIngredients[category]!;

                    return _buildCategorySection(
                        context, controller, category, ingredients);
                  },
                );
              }),
            ),
          ],
        ),

        // Modal de ingrediente
        Obx(() => controller.showIngredientModal.value
            ? const IngredientEditModal()
            : const SizedBox.shrink()),
      ],
    );
  }

  /// Construye una sección por categoría
  Widget _buildCategorySection(
      BuildContext context,
      SettingsController controller,
      String category,
      List<IngredientModel> ingredients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de categoría
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            category,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
          ),
        ),

        // Lista de ingredientes en la categoría
        ...ingredients.map((ingredient) =>
            _buildIngredientCard(context, controller, ingredient)),

        const SizedBox(height: 8),
      ],
    );
  }

  /// Construye una card de ingrediente
  Widget _buildIngredientCard(BuildContext context,
      SettingsController controller, IngredientModel ingredient) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getCategoryColor(ingredient.category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(ingredient.category),
              color: _getCategoryColor(ingredient.category),
              size: 20,
            ),
          ),
          title: Text(
            ingredient.name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle:
              ingredient.category != null ? Text(ingredient.category!) : null,
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  controller.showEditIngredientModal(ingredient);
                  break;
                case 'delete':
                  controller.deleteIngredient(ingredient);
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
                  title: Text('Eliminar', style: TextStyle(color: Colors.red)),
                  dense: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Obtiene el color según la categoría
  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'verduras':
        return Colors.green;
      case 'proteínas':
        return Colors.red;
      case 'carbohidratos':
        return Colors.orange;
      case 'lácteos':
        return Colors.blue;
      case 'legumbres':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  /// Obtiene el icono según la categoría
  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'verduras':
        return Icons.eco;
      case 'proteínas':
        return Icons.restaurant;
      case 'carbohidratos':
        return Icons.grain;
      case 'lácteos':
        return Icons.local_drink;
      case 'legumbres':
        return Icons.scatter_plot;
      default:
        return Icons.fastfood;
    }
  }
}
