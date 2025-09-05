import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../widgets/animated_bottom_sheet.dart';

/// Modal para crear/editar ingredientes
class IngredientEditModal extends StatelessWidget {
  const IngredientEditModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return AnimatedBottomSheet(
      isVisible: true,
      onDismiss: controller.closeIngredientModal,
      initialChildSize: 0.65,
      child: Form(
        key: controller.ingredientFormKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Obx(() => Text(
                    controller.isEditMode.value
                        ? 'Editar Ingrediente'
                        : 'Nuevo Ingrediente',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  )),

              const SizedBox(height: 24),

              // Nombre del ingrediente
              TextFormField(
                controller: controller.ingredientNameController,
                validator: (value) => controller.validateRequired(
                    value, 'el nombre del ingrediente'),
                decoration: const InputDecoration(
                  labelText: 'Nombre del Ingrediente',
                  hintText: 'Ej: Tomate',
                  prefixIcon: Icon(Icons.fastfood),
                ),
              ),

              const SizedBox(height: 16),

              // Categoría
              TextFormField(
                controller: controller.ingredientCategoryController,
                decoration: const InputDecoration(
                  labelText: 'Categoría (Opcional)',
                  hintText: 'Ej: Verduras, Proteínas, Lácteos',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
              ),

              const Spacer(),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.closeIngredientModal,
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
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.saveIngredient,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Obx(() => Text(controller.isEditMode.value
                                  ? 'Actualizar'
                                  : 'Crear')),
                        )),
                  ),
                ],
              ),

              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 24),
            ],
          ),
        ),
      ),
    );
  }
}
