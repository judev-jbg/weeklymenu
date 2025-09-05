import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../widgets/animated_bottom_sheet.dart';

/// Modal para editar el perfil del usuario actual
class ProfileEditModal extends StatelessWidget {
  const ProfileEditModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return AnimatedBottomSheet(
      isVisible: true,
      onDismiss: controller.closeProfileModal,
      initialChildSize: 0.65,
      child: Form(
        key: controller.profileFormKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                'Editar Perfil',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),

              const SizedBox(height: 24),

              // Primer nombre
              TextFormField(
                controller: controller.profileFirstNameController,
                validator: (value) =>
                    controller.validateRequired(value, 'el primer nombre'),
                decoration: const InputDecoration(
                  labelText: 'Primer Nombre',
                  prefixIcon: Icon(Icons.person_outlined),
                ),
              ),

              const SizedBox(height: 16),

              // Apellido
              TextFormField(
                controller: controller.profileLastNameController,
                validator: (value) =>
                    controller.validateRequired(value, 'el apellido'),
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  prefixIcon: Icon(Icons.person_outlined),
                ),
              ),

              const Spacer(),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.closeProfileModal,
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
                              : controller.updateProfile,
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
                              : const Text('Actualizar'),
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
