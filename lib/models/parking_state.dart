enum BarrierState { open, closed, moving }

enum UserRole { administrator, operator, client }

enum AlertLevel { info, warning, critical }

class ParkingSpot {
  const ParkingSpot({
    required this.id,
    required this.label,
    required this.occupied,
    this.reserved = false,
    this.sensorOnline = true,
  });

  final int id;
  final String label;
  final bool occupied;
  final bool reserved;
  final bool sensorOnline;

  ParkingSpot copyWith({bool? occupied, bool? reserved, bool? sensorOnline}) {
    return ParkingSpot(
      id: id,
      label: label,
      occupied: occupied ?? this.occupied,
      reserved: reserved ?? this.reserved,
      sensorOnline: sensorOnline ?? this.sensorOnline,
    );
  }
}

class AccessLog {
  const AccessLog({
    required this.cardId,
    required this.userName,
    required this.role,
    required this.allowed,
    required this.timestamp,
  });

  final String cardId;
  final String userName;
  final UserRole role;
  final bool allowed;
  final DateTime timestamp;

  String get roleLabel {
    switch (role) {
      case UserRole.administrator:
        return 'Administrador';
      case UserRole.operator:
        return 'Operador';
      case UserRole.client:
        return 'Cliente';
    }
  }
}

class AlertItem {
  const AlertItem({
    required this.title,
    required this.message,
    required this.level,
    required this.timestamp,
  });

  final String title;
  final String message;
  final AlertLevel level;
  final DateTime timestamp;
}

class StatPoint {
  const StatPoint({required this.label, required this.value});

  final String label;
  final int value;
}

class ParkingState {
  const ParkingState({
    required this.spots,
    required this.barrierState,
    required this.accessLogs,
    required this.alerts,
    required this.vehiclesByDay,
    required this.peakHours,
    required this.lastUpdated,
    required this.lastCommand,
    this.esp32Online = true,
    this.systemOnline = true,
  });

  final List<ParkingSpot> spots;
  final BarrierState barrierState;
  final List<AccessLog> accessLogs;
  final List<AlertItem> alerts;
  final List<StatPoint> vehiclesByDay;
  final List<StatPoint> peakHours;
  final DateTime lastUpdated;
  final String lastCommand;
  final bool esp32Online;
  final bool systemOnline;

  factory ParkingState.initial({String lastCommand = 'Sistema listo'}) {
    final now = DateTime.now();
    return ParkingState(
      spots: const [
        ParkingSpot(id: 1, label: 'Puesto 1', occupied: false),
        ParkingSpot(id: 2, label: 'Puesto 2', occupied: true),
      ],
      barrierState: BarrierState.closed,
      accessLogs: [
        AccessLog(
          cardId: 'RFID-A13C',
          userName: 'Carlos M.',
          role: UserRole.client,
          allowed: true,
          timestamp: now.subtract(const Duration(minutes: 8)),
        ),
        AccessLog(
          cardId: 'RFID-0X91',
          userName: 'Tarjeta no registrada',
          role: UserRole.client,
          allowed: false,
          timestamp: now.subtract(const Duration(minutes: 15)),
        ),
        AccessLog(
          cardId: 'RFID-ADMIN',
          userName: 'Admin',
          role: UserRole.administrator,
          allowed: true,
          timestamp: now.subtract(const Duration(minutes: 25)),
        ),
      ],
      alerts: [
        AlertItem(
          title: 'Sistema operativo',
          message: 'ESP32 conectado por WiFi y sensores activos.',
          level: AlertLevel.info,
          timestamp: now.subtract(const Duration(minutes: 2)),
        ),
      ],
      vehiclesByDay: const [
        StatPoint(label: 'Lun', value: 18),
        StatPoint(label: 'Mar', value: 24),
        StatPoint(label: 'Mie', value: 20),
        StatPoint(label: 'Jue', value: 31),
        StatPoint(label: 'Vie', value: 27),
        StatPoint(label: 'Sab', value: 35),
        StatPoint(label: 'Dom', value: 16),
      ],
      peakHours: const [
        StatPoint(label: '07', value: 6),
        StatPoint(label: '10', value: 14),
        StatPoint(label: '13', value: 10),
        StatPoint(label: '16', value: 18),
        StatPoint(label: '19', value: 12),
      ],
      lastUpdated: now,
      lastCommand: lastCommand,
    );
  }

  int get totalSpaces => spots.length;

  int get occupiedSpaces => spots.where((spot) => spot.occupied).length;

  int get reservedSpaces => spots.where((spot) => spot.reserved).length;

  int get availableSpaces =>
      spots.where((spot) => !spot.occupied && !spot.reserved).length;

  double get occupancyRate {
    if (totalSpaces == 0) {
      return 0;
    }
    return occupiedSpaces / totalSpaces;
  }

  bool get parkingFull => availableSpaces == 0;

  bool get hasSensorFailure => spots.any((spot) => !spot.sensorOnline);

  String get barrierLabel {
    switch (barrierState) {
      case BarrierState.open:
        return 'Abierta';
      case BarrierState.closed:
        return 'Cerrada';
      case BarrierState.moving:
        return 'En movimiento';
    }
  }

  String get occupancyLabel {
    final percentage = (occupancyRate * 100).round();
    return '$percentage% ocupacion';
  }

  ParkingState copyWith({
    List<ParkingSpot>? spots,
    BarrierState? barrierState,
    List<AccessLog>? accessLogs,
    List<AlertItem>? alerts,
    List<StatPoint>? vehiclesByDay,
    List<StatPoint>? peakHours,
    DateTime? lastUpdated,
    String? lastCommand,
    bool? esp32Online,
    bool? systemOnline,
  }) {
    return ParkingState(
      spots: spots ?? this.spots,
      barrierState: barrierState ?? this.barrierState,
      accessLogs: accessLogs ?? this.accessLogs,
      alerts: alerts ?? this.alerts,
      vehiclesByDay: vehiclesByDay ?? this.vehiclesByDay,
      peakHours: peakHours ?? this.peakHours,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lastCommand: lastCommand ?? this.lastCommand,
      esp32Online: esp32Online ?? this.esp32Online,
      systemOnline: systemOnline ?? this.systemOnline,
    );
  }
}
