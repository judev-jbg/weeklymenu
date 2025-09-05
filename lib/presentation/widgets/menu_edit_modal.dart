import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../widgets/animated_bottom_sheet.dart';

/// Modal para crear/editar menús
class MenuEditModal extends StatelessWidget {
  const MenuEditModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return AnimatedBottomSheet(
      isVisible: true,
      onDismiss: controller.closeMenuModal,
      initialChildSize: 0.7,
      child: Form(
        key: controller.menuFormKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Obx(() => Text(
                    controller.isEditMode.value ? 'Editar Menú' : 'Nuevo Menú',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  )),

              const SizedBox(height: 24),

              // Nombre del menú
              TextFormField(
                controller: controller.menuNameController,
                validator: (value) =>
                    controller.validateRequired(value, 'el nombre del menú'),
                decoration: const InputDecoration(
                  labelText: 'Nombre del Menú',
                  hintText: 'Ej: Pasta con pollo',
                  prefixIcon: Icon(Icons.restaurant_menu),
                ),
              ),

              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: controller.menuDescriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  hintText: 'Describe los ingredientes o preparación...',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
              ),

              const Spacer(),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.closeMenuModal,
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
                              : controller.saveMenu,
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
