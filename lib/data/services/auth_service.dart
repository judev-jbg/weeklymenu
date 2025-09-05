import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

/// Resultado de validación de usuario
class UserValidationResult {
  final bool exists;
  final bool isValid;
  final String? message;

  UserValidationResult({
    required this.exists,
    required this.isValid,
    this.message,
  });
}

/// Resultado de autenticación
class AuthResult {
  final bool success;
  final String? message;
  final UserModel? user;

  AuthResult({
    required this.success,
    this.message,
    this.user,
  });
}

/// Servicio de autenticación con Supabase
class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Valida si un email/usuario existe en el sistema
  static Future<UserValidationResult> validateUserExists(String email) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select('email')
          .eq('email', email.toLowerCase().trim())
          .maybeSingle();

      if (response == null) {
        return UserValidationResult(
          exists: false,
          isValid: false,
          message: 'El usuario es incorrecto o no existe',
        );
      }

      return UserValidationResult(
        exists: true,
        isValid: true,
      );
    } catch (e) {
      print('Error validando usuario: $e');
      return UserValidationResult(
        exists: false,
        isValid: false,
        message: 'Error al validar usuario',
      );
    }
  }

  /// Registra un nuevo usuario
  static Future<AuthResult> registerUser({
    required String email,
    required String password,
  }) async {
    try {
      // Verificar si el usuario ya existe
      final existsResult = await validateUserExists(email);
      if (existsResult.exists) {
        return AuthResult(
          success: false,
          message: 'El usuario ingresado ya está registrado. Inicie sesión',
        );
      }

      // Crear usuario en Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email.toLowerCase().trim(),
        password: password,
      );

      if (response.user == null) {
        return AuthResult(
          success: false,
          message: 'Error al crear la cuenta',
        );
      }

      return AuthResult(
        success: true,
        message: 'Usuario creado exitosamente. Por favor inicie sesión',
      );
    } catch (e) {
      print('Error registrando usuario: $e');
      return AuthResult(
        success: false,
        message: 'Error al crear la cuenta. Intente nuevamente',
      );
    }
  }

  /// Inicia sesión con email y contraseña
  static Future<AuthResult> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.toLowerCase().trim(),
        password: password,
      );

      if (response.user == null) {
        return AuthResult(
          success: false,
          message: 'La contraseña ingresada es incorrecta',
        );
      }

      // Obtener perfil del usuario
      final profileResponse = await _supabase
          .from('user_profiles')
          .select('*')
          .eq('id', response.user!.id)
          .single();

      final user = UserModel.fromJson(profileResponse);

      return AuthResult(
        success: true,
        user: user,
      );
    } catch (e) {
      print('Error iniciando sesión: $e');
      return AuthResult(
        success: false,
        message: 'La contraseña ingresada es incorrecta',
      );
    }
  }

  /// Restablece la contraseña
  static Future<bool> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email.toLowerCase().trim(),
        redirectTo: 'com.example.weeklyMenu://reset-password',
      );
      return true;
    } catch (e) {
      print('Error restableciendo contraseña: $e');
      return false;
    }
  }

  /// Cierra sesión
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('Error cerrando sesión: $e');
    }
  }

  /// Obtiene el usuario actual
  static UserModel? getCurrentUser() {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    // Este método necesitaría obtener el perfil desde la base de datos
    // Para simplificar, retornamos null aquí y manejamos en el splash
    return null;
  }

  /// Verifica si hay un usuario autenticado
  static bool get isUserLoggedIn => _supabase.auth.currentUser != null;

  /// Registra un intento de login fallido
  static Future<void> _recordFailedAttempt(String email) async {
    try {
      // Verificar intentos existentes
      final existing = await _supabase
          .from('login_attempts')
          .select('*')
          .eq('email', email.toLowerCase().trim())
          .maybeSingle();

      if (existing == null) {
        // Crear nuevo registro
        await _supabase.from('login_attempts').insert({
          'email': email.toLowerCase().trim(),
          'failed_attempts': 1,
          'last_attempt': DateTime.now().toIso8601String(),
        });
      } else {
        // Actualizar intentos existentes
        final attempts = existing['failed_attempts'] as int;
        DateTime? blockedUntil;

        if (attempts >= 2) {
          // Después del tercer intento
          blockedUntil = DateTime.now().add(const Duration(minutes: 15));
        }

        await _supabase.from('login_attempts').update({
          'failed_attempts': attempts + 1,
          'last_attempt': DateTime.now().toIso8601String(),
          'blocked_until': blockedUntil?.toIso8601String(),
        }).eq('email', email.toLowerCase().trim());
      }
    } catch (e) {
      print('Error registrando intento fallido: $e');
    }
  }

  /// Verifica si un usuario está bloqueado
  static Future<bool> isUserBlocked(String email) async {
    try {
      final response = await _supabase
          .from('login_attempts')
          .select('blocked_until, failed_attempts')
          .eq('email', email.toLowerCase().trim())
          .maybeSingle();

      if (response == null) return false;

      final blockedUntil = response['blocked_until'] as String?;
      if (blockedUntil == null) return false;

      final blockedDateTime = DateTime.parse(blockedUntil);
      return DateTime.now().isBefore(blockedDateTime);
    } catch (e) {
      print('Error verificando bloqueo: $e');
      return false;
    }
  }

  /// Limpia los intentos fallidos después de un login exitoso
  static Future<void> _clearFailedAttempts(String email) async {
    try {
      await _supabase
          .from('login_attempts')
          .delete()
          .eq('email', email.toLowerCase().trim());
    } catch (e) {
      print('Error limpiando intentos: $e');
    }
  }
}
