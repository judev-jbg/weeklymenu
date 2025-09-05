import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/enums/connection_state.dart';

/// Servicio responsable de manejar la conexión con Supabase
class ConnectionService {
  final String _supabaseUrl = dotenv.get('SUPABASE_BASE_URL');
  // final String _supabaseKey = 'TOKEN-FAKE'; //Para causar error de conexion intencial
  final String _supabaseKey = dotenv.get('SUPABASE_KEY');

  /// Inicializa la conexión con Supabase
  /// Retorna el estado de la conexión después del intento
  Future<ConnectionStatus> initializeConnection() async {
    try {
      // Inicializar Supabase
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseKey,
      );

      // Intentar una operación simple para validar conexión
      await Supabase.instance.client
          .from('test') // Tabla de prueba o cualquier operación mínima
          .select('*')
          .limit(1);

      return ConnectionStatus.connected;
    } catch (e) {
      print('Error de conexión: $e');
      return ConnectionStatus.disconnected;
    }
  }

  /// Verifica si hay un usuario autenticado
  static bool isUserLoggedIn() {
    return Supabase.instance.client.auth.currentUser != null;
  }
}
