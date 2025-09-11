import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../widgets/animated_bottom_sheet.dart';
import '../../data/models/user_model.dart';

/// Modal para crear/editar usuarios
class UserEditModal extends StatelessWidget {
  const UserEditModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return AnimatedBottomSheet(
      isVisible: true,
      onDismiss: controller.closeUserModal,
      initialChildSize: 0.9,
      child: Form(
        key: controller.userFormKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Obx(() => Text(
                    controller.isEditMode.value
                        ? 'Editar Usuario'
                        : 'Nuevo Usuario',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  )),

              const SizedBox(height: 24),

              // Email (solo para nuevos usuarios)
              Obx(() => controller.isEditMode.value
                  ? const SizedBox.shrink()
                  : Column(
                      children: [
                        TextFormField(
                          controller: controller.userEmailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: controller.validateEmail,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'usuario@ejemplo.com',
                            prefixIcon: Icon(Icons.email_outlined),
                            labelStyle:
                                Theme.of(Get.context!).textTheme.labelMedium,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    )),

              // Contraseña (solo para nuevos usuarios)
              Obx(() => controller.isEditMode.value
                  ? const SizedBox.shrink()
                  : Column(
                      children: [
                        TextFormField(
                          controller: controller.userPasswordController,
                          obscureText: true,
                          validator: controller.validatePassword,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            hintText: 'Mínimo 6 caracteres',
                            prefixIcon: Icon(Icons.lock_outlined),
                            labelStyle:
                                Theme.of(Get.context!).textTheme.labelMedium,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    )),

              // Primer nombre
              TextFormField(
                controller: controller.userFirstNameController,
                validator: (value) =>
                    controller.validateRequired(value, 'el primer nombre'),
                decoration: InputDecoration(
                  labelText: 'Primer Nombre',
                  prefixIcon: Icon(Icons.person_outlined),
                  labelStyle: Theme.of(Get.context!).textTheme.labelMedium,
                ),
              ),

              const SizedBox(height: 16),

              // Apellido
              TextFormField(
                controller: controller.userLastNameController,
                validator: (value) =>
                    controller.validateRequired(value, 'el apellido'),
                decoration: InputDecoration(
                  labelText: 'Apellido',
                  prefixIcon: Icon(Icons.person_outlined),
                  labelStyle: Theme.of(Get.context!).textTheme.labelMedium,
                ),
              ),

              const SizedBox(height: 16),

              // Rol
              Obx(() => DropdownButtonFormField<UserRole>(
                    value: controller.selectedUserRole.value,
                    onChanged: (role) =>
                        controller.selectedUserRole.value = role!,
                    decoration: const InputDecoration(
                      labelText: 'Rol',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    items: UserRole.values
                        .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(
                                role == UserRole.admin
                                    ? 'Administrador'
                                    : 'Usuario',
                                style: Theme.of(Get.context!)
                                    .textTheme
                                    .labelMedium,
                              ),
                            ))
                        .toList(),
                  )),

              const Spacer(),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.closeUserModal,
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
                              : controller.saveUser,
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
