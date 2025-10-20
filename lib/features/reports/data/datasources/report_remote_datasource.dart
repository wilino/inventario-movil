import 'package:supabase_flutter/supabase_flutter.dart';

/// Fuente de datos remota para reportes
///
/// Nota: Los reportes se generan localmente desde la base de datos SQLite.
/// Esta clase está preparada para futuras funcionalidades como:
/// - Exportar reportes a servidor
/// - Sincronizar métricas agregadas
/// - Compartir reportes entre usuarios
class ReportRemoteDataSource {
  final SupabaseClient _supabase;

  ReportRemoteDataSource(this._supabase);

  /// Sincroniza métricas agregadas con el servidor
  /// (Funcionalidad futura)
  Future<void> syncMetrics(Map<String, dynamic> metrics) async {
    // TODO: Implementar cuando se requiera sincronización de métricas
    throw UnimplementedError('syncMetrics no implementado aún');
  }

  /// Exporta reporte al servidor para compartir
  /// (Funcionalidad futura)
  Future<String> exportToServer(
    String reportType,
    Map<String, dynamic> data,
  ) async {
    // TODO: Implementar exportación a servidor
    throw UnimplementedError('exportToServer no implementado aún');
  }
}
