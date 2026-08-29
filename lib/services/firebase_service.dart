import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/parking_state.dart';
import 'parking_service.dart';

class FirebaseService implements ParkingService {
  FirebaseService() : _reference = FirebaseDatabase.instance.ref('parqueadero');

  static Future<bool> tryInitialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp().timeout(const Duration(seconds: 8));
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  final DatabaseReference _reference;

  Future<void> ensureSeedData() async {
    final snapshot = await _reference.get();
    if (snapshot.value == null) {
      await _reference.set({
        'esp32Online': true,
        'barrera': {'estado': 'cerrada'},
        'puesto1': {'ocupado': false, 'reservado': false, 'sensorOnline': true},
        'puesto2': {'ocupado': true, 'reservado': false, 'sensorOnline': true},
      });
    }
  }

  @override
  Stream<ParkingState> watchState() async* {
    await ensureSeedData();
    yield* _reference.onValue.map((event) {
      final root = _asMap(event.snapshot.value);
      final puesto1 = _asMap(root['puesto1']);
      final puesto2 = _asMap(root['puesto2']);
      final barrera = _asMap(root['barrera']);
      final initial = ParkingState.initial(
        lastCommand: 'Firebase sincronizado',
      );

      return initial.copyWith(
        spots: [
          _spotFromMap(1, 'Puesto 1', puesto1),
          _spotFromMap(2, 'Puesto 2', puesto2),
        ],
        barrierState: _readBarrierState(barrera['estado']),
        esp32Online: _readBool(root['esp32Online'], fallback: true),
        systemOnline: true,
        lastUpdated: DateTime.now(),
      );
    });
  }

  @override
  Future<void> setSpotOccupancy({
    required int spotNumber,
    required bool occupied,
  }) async {
    await _reference.child('puesto$spotNumber/ocupado').set(occupied);
    await _reference.child('puesto$spotNumber/reservado').set(false);
  }

  @override
  Future<void> setSpotReservation({
    required int spotNumber,
    required bool reserved,
  }) async {
    await _reference.child('puesto$spotNumber/reservado').set(reserved);
  }

  @override
  Future<void> setBarrierOpen(bool open) async {
    await _reference.child('barrera/estado').set(open ? 'abierta' : 'cerrada');
    await _reference.child('barrera/comando').set(open ? 'abrir' : 'cerrar');
  }

  @override
  Future<void> simulateRfidScan({required bool allowed}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _reference.child('rfid/ultimoAcceso').set({
      'cardId': allowed ? 'RFID-DEMO' : 'RFID-BLOQ',
      'permitido': allowed,
      'timestamp': now,
    });
    if (allowed) {
      await setBarrierOpen(true);
    }
  }

  @override
  Future<void> toggleEsp32Connection() async {
    final snapshot = await _reference.child('esp32Online').get();
    final connected = _readBool(snapshot.value, fallback: true);
    await _reference.child('esp32Online').set(!connected);
  }

  ParkingSpot _spotFromMap(int id, String label, Map<Object?, Object?> source) {
    return ParkingSpot(
      id: id,
      label: label,
      occupied: _readBool(source['ocupado']),
      reserved: _readBool(source['reservado']),
      sensorOnline: _readBool(source['sensorOnline'], fallback: true),
    );
  }

  Map<Object?, Object?> _asMap(Object? value) {
    if (value is Map<Object?, Object?>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, val) => MapEntry(key, val));
    }
    return const {};
  }

  bool _readBool(Object? value, {bool fallback = false}) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value == null) {
      return fallback;
    }
    final normalized = value.toString().toLowerCase();
    if (normalized == 'true') {
      return true;
    }
    if (normalized == 'false') {
      return false;
    }
    return fallback;
  }

  BarrierState _readBarrierState(Object? value) {
    switch (value?.toString().toLowerCase()) {
      case 'abierta':
      case 'open':
        return BarrierState.open;
      case 'movimiento':
      case 'moving':
        return BarrierState.moving;
      case 'cerrada':
      case 'closed':
      default:
        return BarrierState.closed;
    }
  }

  @override
  Future<void> dispose() async {}
}
