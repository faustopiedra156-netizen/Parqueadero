import 'package:flutter/material.dart';

import '../models/parking_state.dart';

class ParkingCard extends StatelessWidget {
  const ParkingCard({
    super.key,
    required this.spot,
    required this.onToggle,
    required this.onReserve,
  });

  final ParkingSpot spot;
  final VoidCallback? onToggle;
  final VoidCallback onReserve;

  @override
  Widget build(BuildContext context) {
    final statusColor = spot.occupied
        ? const Color(0xFFFF4F4F)
        : spot.reserved
        ? const Color(0xFFFFC857)
        : const Color(0xFF22F78E);
    final statusText = spot.occupied
        ? 'OCUPADO'
        : spot.reserved
        ? 'RESERVADO'
        : 'LIBRE';
    final icon = spot.occupied
        ? Icons.directions_car_filled_rounded
        : spot.reserved
        ? Icons.bookmark_rounded
        : Icons.local_parking_rounded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withValues(alpha: 0.12),
                  border: Border.all(color: statusColor, width: 2),
                ),
                child: Icon(icon, color: statusColor, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spot.label.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF06111F),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      spot.sensorOnline
                          ? 'Sensor IR online'
                          : 'Sensor fallando',
                      style: TextStyle(
                        color: spot.sensorOnline
                            ? const Color(0xFF466277)
                            : const Color(0xFFFF4F4F),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Text(
              statusText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onToggle,
                  icon: Icon(
                    spot.occupied ? Icons.logout_rounded : Icons.login_rounded,
                    size: 18,
                  ),
                  label: Text(spot.occupied ? 'Liberar' : 'Ocupar'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: spot.occupied ? null : onReserve,
                tooltip: spot.reserved ? 'Cancelar reserva' : 'Reservar',
                icon: Icon(
                  spot.reserved
                      ? Icons.event_busy_rounded
                      : Icons.event_available_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
