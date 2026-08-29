import 'dart:async';

import '../models/parking_state.dart';
import 'parking_service.dart';

class SimulationParkingService implements ParkingService {
  SimulationParkingService()
    : _state = ParkingState.initial(
        lastCommand: 'Sistema iniciado en modo simulacion',
      );

  final StreamController<ParkingState> _controller =
      StreamController<ParkingState>.broadcast();
  ParkingState _state;
  Timer? _barrierTimer;

  @override
  Stream<ParkingState> watchState() async* {
    yield _state;
    yield* _controller.stream;
  }

  @override
  Future<void> setSpotOccupancy({
    required int spotNumber,
    required bool occupied,
  }) async {
    final spots = _state.spots.map((spot) {
      if (spot.id != spotNumber) {
        return spot;
      }
      return spot.copyWith(occupied: occupied, reserved: false);
    }).toList();

    final alerts = [..._state.alerts];
    final nextState = _state.copyWith(
      spots: spots,
      lastCommand: occupied
          ? 'Sensor IR detecto vehiculo en puesto $spotNumber'
          : 'Puesto $spotNumber liberado',
    );

    if (nextState.parkingFull) {
      alerts.insert(
        0,
        AlertItem(
          title: 'Parqueadero lleno',
          message: 'No quedan espacios disponibles.',
          level: AlertLevel.warning,
          timestamp: DateTime.now(),
        ),
      );
    }

    _emit(nextState.copyWith(alerts: alerts.take(5).toList()));
  }

  @override
  Future<void> setSpotReservation({
    required int spotNumber,
    required bool reserved,
  }) async {
    final spots = _state.spots.map((spot) {
      if (spot.id != spotNumber || spot.occupied) {
        return spot;
      }
      return spot.copyWith(reserved: reserved);
    }).toList();

    _emit(
      _state.copyWith(
        spots: spots,
        lastCommand: reserved
            ? 'Reserva creada para puesto $spotNumber'
            : 'Reserva cancelada para puesto $spotNumber',
      ),
    );
  }

  @override
  Future<void> setBarrierOpen(bool open) async {
    _barrierTimer?.cancel();
    _emit(
      _state.copyWith(
        barrierState: BarrierState.moving,
        lastCommand: open ? 'Abriendo barrera' : 'Cerrando barrera',
      ),
    );

    _barrierTimer = Timer(const Duration(milliseconds: 900), () {
      _emit(
        _state.copyWith(
          barrierState: open ? BarrierState.open : BarrierState.closed,
          lastCommand: open ? 'Barrera abierta' : 'Barrera cerrada',
        ),
      );
    });
  }

  @override
  Future<void> simulateRfidScan({required bool allowed}) async {
    final now = DateTime.now();
    final log = AccessLog(
      cardId: allowed ? 'RFID-${now.second}A7' : 'RFID-BLOQ',
      userName: allowed ? 'Usuario autorizado' : 'Acceso no autorizado',
      role: allowed ? UserRole.client : UserRole.client,
      allowed: allowed,
      timestamp: now,
    );

    final alerts = [..._state.alerts];
    if (!allowed) {
      alerts.insert(
        0,
        AlertItem(
          title: 'Acceso no autorizado',
          message: 'Tarjeta RFID rechazada por permisos insuficientes.',
          level: AlertLevel.critical,
          timestamp: now,
        ),
      );
    }

    _emit(
      _state.copyWith(
        accessLogs: [log, ..._state.accessLogs].take(6).toList(),
        alerts: alerts.take(5).toList(),
        lastCommand: allowed
            ? 'RFID validado, acceso permitido'
            : 'RFID rechazado por seguridad',
      ),
    );

    if (allowed) {
      await setBarrierOpen(true);
    }
  }

  @override
  Future<void> toggleEsp32Connection() async {
    final connected = !_state.esp32Online;
    final alerts = [..._state.alerts];
    if (!connected) {
      alerts.insert(
        0,
        AlertItem(
          title: 'Conexion ESP32 perdida',
          message: 'No se reciben datos desde el controlador IoT.',
          level: AlertLevel.critical,
          timestamp: DateTime.now(),
        ),
      );
    }

    _emit(
      _state.copyWith(
        esp32Online: connected,
        systemOnline: connected,
        alerts: alerts.take(5).toList(),
        lastCommand: connected
            ? 'ESP32 reconectado'
            : 'ESP32 desconectado manualmente',
      ),
    );
  }

  void _emit(ParkingState nextState) {
    _state = nextState.copyWith(lastUpdated: DateTime.now());
    if (!_controller.isClosed) {
      _controller.add(_state);
    }
  }

  @override
  Future<void> dispose() async {
    _barrierTimer?.cancel();
    await _controller.close();
  }
}
