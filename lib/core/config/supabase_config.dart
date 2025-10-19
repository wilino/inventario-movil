import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuración global de Supabase
class SupabaseConfig {
  static SupabaseClient? _client;

  /// Inicializa Supabase con las credenciales
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: '', // TODO: Agregar URL por defecto o configurar en .env
      ),
      anonKey: const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: '', // TODO: Agregar KEY por defecto o configurar en .env
      ),
    );
    _client = Supabase.instance.client;
  }

  /// Retorna el cliente de Supabase
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase no ha sido inicializado. Llama a initialize() primero.',
      );
    }
    return _client!;
  }

  /// Shortcut para obtener el cliente
  static SupabaseClient get supabase => client;
}
