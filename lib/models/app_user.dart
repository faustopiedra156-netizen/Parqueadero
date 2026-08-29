import 'parking_state.dart';

class AppUser {
  const AppUser({required this.name, required this.email, required this.role});

  final String name;
  final String email;
  final UserRole role;

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

  bool get canControlBarrier =>
      role == UserRole.administrator || role == UserRole.operator;

  bool get canManageSpots =>
      role == UserRole.administrator || role == UserRole.operator;

  bool get canValidateRfid =>
      role == UserRole.administrator || role == UserRole.operator;
}
