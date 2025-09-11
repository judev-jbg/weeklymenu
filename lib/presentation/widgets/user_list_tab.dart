import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../widgets/user_edit_modal.dart';
import '../../data/models/user_model.dart';
import '../../core/theme/app_theme.dart';

/// Tab para gestionar usuarios (solo admin)
class UserListTab extends StatelessWidget {
  const UserListTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return Scaffold(
      // FAB solo visible en tab Lista
      floatingActionButton: Obx(() => controller.currentTabIndex.value > 0
          ? FloatingActionButton(
              onPressed: controller.showCreateUserModal,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.black),
            )
          : const SizedBox.shrink()),
      body: Stack(
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
                      'Gestión de Usuarios',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // ElevatedButton.icon(
                    //   onPressed: controller.showCreateUserModal,
                    //   icon: const Icon(Icons.add),
                    //   label: const Text('Nuevo Usuario'),
                    // ),
                  ],
                ),
              ),

              // Lista de usuarios
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.users.isEmpty) {
                    return const Center(
                      child: Text('No hay usuarios registrados'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.users.length,
                    itemBuilder: (context, index) {
                      final user = controller.users[index];
                      return _buildUserCard(context, controller, user);
                    },
                  );
                }),
              ),
            ],
          ),

          // Modal de usuario
          Obx(() => controller.showUserModal.value
              ? const UserEditModal()
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  /// Construye una card de usuario
  Widget _buildUserCard(
      BuildContext context, SettingsController controller, UserModel user) {
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
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: user.isAdmin
                      ? Colors.purple.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    user.fullName.isNotEmpty
                        ? user.fullName[0].toUpperCase()
                        : user.email[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: user.isAdmin ? Colors.purple : Colors.blue,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Información del usuario
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName.isNotEmpty
                          ? user.fullName
                          : user.email.split('@').first,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: user.isAdmin
                            ? Colors.purple.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.isAdmin ? 'Administrador' : 'Usuario',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: user.isAdmin ? Colors.purple : Colors.blue,
                        ),
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
                      controller.showEditUserModal(user);
                      break;
                    case 'delete':
                      controller.deleteUser(user);
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
}
