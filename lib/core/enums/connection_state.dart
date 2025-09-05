/// Enumeración para los diferentes estados de conexión al servidor
enum ConnectionStatus {
  connecting, // Intentando conectar
  connected, // Conectado exitosamente
  disconnected, // Error de conexión
  timeout, // Tiempo de conexión agotado
}
