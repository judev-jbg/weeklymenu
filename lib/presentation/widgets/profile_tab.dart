import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../widgets/profile_edit_modal.dart';
import '../widgets/password_change_modal.dart';
import '../../core/theme/app_theme.dart';

/// Tab para gestionar el perfil del usuario
class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return Stack(
      children: [
        // Contenido principal
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = controller.currentUserProfile.value;
          if (profile == null) {
            return const Center(
              child: Text('Error cargando perfil'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card de información personal
                _buildPersonalInfoCard(context, controller, profile),

                const SizedBox(height: 24),

                // Card de seguridad
                _buildSecurityCard(context, controller),

                const SizedBox(height: 24),

                // Card de información de cuenta
                _buildAccountInfoCard(context, profile),
              ],
            ),
          );
        }),

        // Modales superpuestos
        Obx(() => controller.showProfileModal.value
            ? const ProfileEditModal()
            : const SizedBox.shrink()),

        Obx(() => controller.showPasswordModal.value
            ? const PasswordChangeModal()
            : const SizedBox.shrink()),
      ],
    );
  }

  /// Construye la card de información personal
  Widget _buildPersonalInfoCard(
      BuildContext context, SettingsController controller, dynamic profile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de la sección
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Información Personal',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                IconButton(
                  onPressed: () => controller.showProfileModal.value = true,
                  icon: Icon(
                    Icons.edit,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Avatar y nombre
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      profile.fullName.isNotEmpty
                          ? profile.fullName[0].toUpperCase()
                          : profile.email[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.fullName.isNotEmpty
                            ? profile.fullName
                            : 'Sin nombre',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Información adicional
            _buildInfoRow(
              context,
              'Primer Nombre',
              profile.firstName ?? 'No especificado',
              Icons.person_outline,
            ),

            const SizedBox(height: 16),

            _buildInfoRow(
              context,
              'Apellido',
              profile.lastName ?? 'No especificado',
              Icons.person_outline,
            ),

            const SizedBox(height: 16),

            _buildInfoRow(
              context,
              'Rol',
              profile.isAdmin ? 'Administrador' : 'Usuario',
              Icons.badge_outlined,
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la card de seguridad
  Widget _buildSecurityCard(
      BuildContext context, SettingsController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seguridad',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),

            const SizedBox(height: 20),

            // Cambiar contraseña
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Colors.orange,
                ),
              ),
              title: const Text('Cambiar Contraseña'),
              subtitle: const Text('Actualiza tu contraseña de acceso'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => controller.showPasswordChangeModal(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la card de información de cuenta
  Widget _buildAccountInfoCard(BuildContext context, dynamic profile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información de Cuenta',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              context,
              'Fecha de Registro',
              _formatDate(profile.createdAt),
              Icons.calendar_today_outlined,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              'Última Actualización',
              _formatDate(profile.updatedAt),
              Icons.update_outlined,
            ),
          ],
        ),
      ),
    );
  }

  /// Construye una fila de información
  Widget _buildInfoRow(
      BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Formatea una fecha
  String _formatDate(DateTime date) {
    final months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];

    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}
