import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/parking_state.dart';
import 'firebase_service.dart';
import 'parking_service.dart';
import 'simulation_parking_service.dart';

enum AppMode { simulation, firebase }

class ParkingController extends ChangeNotifier {
  ParkingController({required bool firebaseConfigured})
    : _firebaseConfigured = firebaseConfigured,
      _simulationService = SimulationParkingService(),
      _firebaseService = firebaseConfigured ? FirebaseService() : null,
      _state = ParkingState.initial(lastCommand: 'Cargando tablero de control');

  final bool _firebaseConfigured;
  final SimulationParkingService _simulationService;
  final FirebaseService? _firebaseService;

  ParkingService? _activeService;
  StreamSubscription<ParkingState>? _stateSubscription;
  ParkingState _state;

  ParkingState get state => _state;

  AppMode _mode = AppMode.simulation;
  bool _loading = false;
  String _modeMessage = 'Modo simulacion activo';
  String? _errorMessage;

  AppMode get mode => _mode;
  bool get loading => _loading;
  String get modeMessage => _modeMessage;
  String? get errorMessage => _errorMessage;
  bool get firebaseConfigured => _firebaseConfigured;
  bool get isInFirebaseMode => _mode == AppMode.firebase;

  Future<void> initialize() async {
    await _bindService(
      service: _simulationService,
      mode: AppMode.simulation,
      modeMessage: 'Modo simulacion activo',
    );

    if (_firebaseConfigured) {
      await connectToFirebase(auto: true);
    }
  }

  Future<void> connectToFirebase({bool auto = false}) async {
    if (!_firebaseConfigured || _firebaseService == null) {
      _errorMessage = 'Firebase aun no esta configurado en este proyecto.';
      notifyListeners();
      return;
    }

    _loading = true;
    _errorMessage = null;
    _modeMessage = auto ? 'Buscando conexion con Firebase...' : 'Conectando...';
    notifyListeners();

    try {
      await _bindService(
        service: _firebaseService,
        mode: AppMode.firebase,
        modeMessage: 'Firebase conectado en tiempo real',
      );
    } catch (_) {
      _errorMessage =
          'No se pudo conectar a Firebase. Se mantiene el modo simulacion.';
      await _bindService(
        service: _simulationService,
        mode: AppMode.simulation,
        modeMessage: 'Modo simulacion activo',
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> useSimulationMode() async {
    _errorMessage = null;
    await _bindService(
      service: _simulationService,
      mode: AppMode.simulation,
      modeMessage: 'Modo simulacion activo',
    );
    notifyListeners();
  }

  Future<void> toggleSpot(int spotNumber) async {
    final spot = _state.spots.firstWhere((item) => item.id == spotNumber);
    await _activeService?.setSpotOccupancy(
      spotNumber: spotNumber,
      occupied: !spot.occupied,
    );
  }

  Future<void> toggleReservation(int spotNumber) async {
    final spot = _state.spots.firstWhere((item) => item.id == spotNumber);
    if (spot.occupied) {
      return;
    }
    await _activeService?.setSpotReservation(
      spotNumber: spotNumber,
      reserved: !spot.reserved,
    );
  }

  Future<void> openBarrier() async {
    await _activeService?.setBarrierOpen(true);
  }

  Future<void> closeBarrier() async {
    await _activeService?.setBarrierOpen(false);
  }

  Future<void> simulateAllowedRfid() async {
    await _activeService?.simulateRfidScan(allowed: true);
  }

  Future<void> simulateRejectedRfid() async {
    await _activeService?.simulateRfidScan(allowed: false);
  }

  Future<void> toggleEsp32Connection() async {
    await _activeService?.toggleEsp32Connection();
  }

  Future<void> _bindService({
    required ParkingService service,
    required AppMode mode,
    required String modeMessage,
  }) async {
    await _stateSubscription?.cancel();
    _activeService = service;
    _mode = mode;
    _modeMessage = modeMessage;

    _stateSubscription = service.watchState().listen(
      (newState) {
        _state = newState;
        notifyListeners();
      },
      onError: (_) {
        _errorMessage = 'Se perdio la lectura de datos en tiempo real.';
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _simulationService.dispose();
    _firebaseService?.dispose();
    super.dispose();
  }
}
