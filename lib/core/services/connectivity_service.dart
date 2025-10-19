import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Servicio para monitorear el estado de conectividad
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  /// Stream que emite true cuando hay conexión, false cuando no hay
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  ConnectivityService() {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('Error al verificar conectividad: $e');
      _isOnline = false;
      _connectionStatusController.add(false);
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final hasConnection = results.any(
      (result) => result != ConnectivityResult.none,
    );

    if (_isOnline != hasConnection) {
      _isOnline = hasConnection;
      _connectionStatusController.add(hasConnection);
      print(
        'Estado de conexión cambió a: ${hasConnection ? "ONLINE" : "OFFLINE"}',
      );
    }
  }

  /// Verifica manualmente el estado de conexión
  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
    return _isOnline;
  }

  void dispose() {
    _connectionStatusController.close();
  }
}
