import '../models/parking_state.dart';

abstract class ParkingService {
  Stream<ParkingState> watchState();

  Future<void> setSpotOccupancy({
    required int spotNumber,
    required bool occupied,
  });

  Future<void> setSpotReservation({
    required int spotNumber,
    required bool reserved,
  });

  Future<void> setBarrierOpen(bool open);

  Future<void> simulateRfidScan({required bool allowed});

  Future<void> toggleEsp32Connection();

  Future<void> dispose();
}
