import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuración global de Supabase
class SupabaseConfig {
  static SupabaseClient? _client;

  /// Inicializa Supabase con las credenciales
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: 'https://ywgxdgblymmnmgjvivvh.supabase.co',
      ),
      anonKey: const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl3Z3hkZ2JseW1tbm1nanZpdnZoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA4ODg0NDYsImV4cCI6MjA3NjQ2NDQ0Nn0.uKdmmA6n7oAzYn-ZoMv94NNajR9I_QOiNMbQHhZOYmQ',
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
