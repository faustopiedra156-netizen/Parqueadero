import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/parking_state.dart';
import '../services/parking_controller.dart';
import '../widgets/parking_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.firebaseReady,
    required this.user,
    required this.onLogout,
  });

  final bool firebaseReady;
  final AppUser user;
  final VoidCallback onLogout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ParkingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ParkingController(firebaseConfigured: widget.firebaseReady);
    Future.microtask(_controller.initialize);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardColors = _DashboardColors.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dashboardColors.backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final state = _controller.state;
              return LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 900;
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: wide ? 32 : 18,
                      vertical: 22,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _Header(
                              state: state,
                              controller: _controller,
                              user: widget.user,
                              onLogout: widget.onLogout,
                            ),
                            const SizedBox(height: 20),
                            _MetricsRow(state: state),
                            const SizedBox(height: 20),
                            if (wide)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 7,
                                    child: _LeftDashboard(
                                      state: state,
                                      controller: _controller,
                                      user: widget.user,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    flex: 5,
                                    child: _RightDashboard(
                                      state: state,
                                      controller: _controller,
                                      user: widget.user,
                                    ),
                                  ),
                                ],
                              )
                            else ...[
                              _LeftDashboard(
                                state: state,
                                controller: _controller,
                                user: widget.user,
                              ),
                              const SizedBox(height: 20),
                              _RightDashboard(
                                state: state,
                                controller: _controller,
                                user: widget.user,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.state,
    required this.controller,
    required this.user,
    required this.onLogout,
  });

  final ParkingState state;
  final ParkingController controller;
  final AppUser user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final dashboardColors = _DashboardColors.of(context);

    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F7BFF).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2994FF)),
                ),
                child: const Icon(
                  Icons.local_parking_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PARQUEADERO INTELIGENTE',
                      style: TextStyle(
                        color: dashboardColors.text,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ESP32 + RFID + Sensores IR + Barrera automatica',
                      style: TextStyle(
                        color: dashboardColors.subtleText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatusChip(
                icon: Icons.account_circle_rounded,
                label: '${user.name} · ${user.roleLabel}',
                color: const Color(0xFF35A7FF),
              ),
              _StatusChip(
                icon: Icons.cloud_done_rounded,
                label: controller.isInFirebaseMode
                    ? 'Firebase tiempo real'
                    : 'Modo simulacion',
                color: controller.isInFirebaseMode
                    ? const Color(0xFF35A7FF)
                    : const Color(0xFF22F78E),
              ),
              _StatusChip(
                icon: Icons.memory_rounded,
                label: state.esp32Online ? 'ESP32 conectado' : 'ESP32 offline',
                color: state.esp32Online
                    ? const Color(0xFF22F78E)
                    : const Color(0xFFFF4F4F),
              ),
              _StatusChip(
                icon: Icons.door_sliding_rounded,
                label: 'Barrera ${state.barrierLabel}',
                color: state.barrierState == BarrierState.open
                    ? const Color(0xFF22F78E)
                    : const Color(0xFFFFC857),
              ),
              ActionChip(
                avatar: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Salir'),
                onPressed: onLogout,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({required this.state});

  final ParkingState state;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth >= 720
            ? (constraints.maxWidth - 36) / 4
            : (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricTile(
              width: cardWidth,
              icon: Icons.event_available_rounded,
              label: 'Disponibles',
              value: '${state.availableSpaces}',
              color: const Color(0xFF22F78E),
            ),
            _MetricTile(
              width: cardWidth,
              icon: Icons.directions_car_filled_rounded,
              label: 'Ocupados',
              value: '${state.occupiedSpaces}',
              color: const Color(0xFFFF4F4F),
            ),
            _MetricTile(
              width: cardWidth,
              icon: Icons.bookmark_rounded,
              label: 'Reservas',
              value: '${state.reservedSpaces}',
              color: const Color(0xFFFFC857),
            ),
            _MetricTile(
              width: cardWidth,
              icon: Icons.analytics_rounded,
              label: 'Ocupacion',
              value: state.occupancyLabel,
              color: const Color(0xFF35A7FF),
            ),
          ],
        );
      },
    );
  }
}

class _LeftDashboard extends StatelessWidget {
  const _LeftDashboard({
    required this.state,
    required this.controller,
    required this.user,
  });

  final ParkingState state;
  final ParkingController controller;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ParkingMap(state: state, controller: controller, user: user),
        const SizedBox(height: 20),
        _StatsPanel(state: state),
      ],
    );
  }
}

class _RightDashboard extends StatelessWidget {
  const _RightDashboard({
    required this.state,
    required this.controller,
    required this.user,
  });

  final ParkingState state;
  final ParkingController controller;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BarrierPanel(state: state, controller: controller, user: user),
        const SizedBox(height: 20),
        _RfidPanel(state: state, controller: controller, user: user),
        const SizedBox(height: 20),
        _AlertsPanel(state: state, controller: controller),
      ],
    );
  }
}

class _ParkingMap extends StatelessWidget {
  const _ParkingMap({
    required this.state,
    required this.controller,
    required this.user,
  });

  final ParkingState state;
  final ParkingController controller;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.map_rounded,
            title: 'Mapa visual de parqueos',
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.spots.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 330,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              mainAxisExtent: 230,
            ),
            itemBuilder: (context, index) {
              final spot = state.spots[index];
              return ParkingCard(
                spot: spot,
                onToggle: user.canManageSpots
                    ? () => controller.toggleSpot(spot.id)
                    : null,
                onReserve: () => controller.toggleReservation(spot.id),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BarrierPanel extends StatelessWidget {
  const _BarrierPanel({
    required this.state,
    required this.controller,
    required this.user,
  });

  final ParkingState state;
  final ParkingController controller;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final dashboardColors = _DashboardColors.of(context);
    final open = state.barrierState == BarrierState.open;
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.door_front_door_rounded,
            title: 'Control de barrera',
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  state.barrierLabel,
                  style: TextStyle(
                    color: dashboardColors.text,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: open ? 1 : 0),
                duration: const Duration(milliseconds: 450),
                builder: (context, value, _) {
                  return Transform.rotate(
                    angle: -0.8 * value,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 86,
                      height: 10,
                      decoration: BoxDecoration(
                        color: open
                            ? const Color(0xFF22F78E)
                            : const Color(0xFFFF4F4F),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: user.canControlBarrier
                      ? controller.openBarrier
                      : null,
                  icon: const Icon(Icons.lock_open_rounded),
                  label: const Text('Abrir'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: user.canControlBarrier
                      ? controller.closeBarrier
                      : null,
                  icon: const Icon(Icons.lock_rounded),
                  label: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RfidPanel extends StatelessWidget {
  const _RfidPanel({
    required this.state,
    required this.controller,
    required this.user,
  });

  final ParkingState state;
  final ParkingController controller;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(icon: Icons.badge_rounded, title: 'Acceso RFID'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: user.canValidateRfid
                      ? controller.simulateAllowedRfid
                      : null,
                  icon: const Icon(Icons.verified_user_rounded),
                  label: const Text('Validar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: user.canValidateRfid
                      ? controller.simulateRejectedRfid
                      : null,
                  icon: const Icon(Icons.gpp_bad_rounded),
                  label: const Text('Rechazar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...state.accessLogs.take(4).map((log) => _AccessRow(log: log)),
        ],
      ),
    );
  }
}

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({required this.state});

  final ParkingState state;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.query_stats_rounded,
            title: 'Estadisticas inteligentes',
          ),
          const SizedBox(height: 18),
          _OccupancyGauge(value: state.occupancyRate),
          const SizedBox(height: 18),
          _MiniBarChart(
            title: 'Vehiculos por dia',
            data: state.vehiclesByDay,
            color: const Color(0xFF35A7FF),
          ),
          const SizedBox(height: 18),
          _MiniBarChart(
            title: 'Horas pico',
            data: state.peakHours,
            color: const Color(0xFF22F78E),
          ),
        ],
      ),
    );
  }
}

class _AlertsPanel extends StatelessWidget {
  const _AlertsPanel({required this.state, required this.controller});

  final ParkingState state;
  final ParkingController controller;

  @override
  Widget build(BuildContext context) {
    final alerts = [
      if (state.parkingFull)
        AlertItem(
          title: 'Parqueadero lleno',
          message: 'Todos los espacios estan ocupados o reservados.',
          level: AlertLevel.warning,
          timestamp: DateTime.now(),
        ),
      if (!state.esp32Online)
        AlertItem(
          title: 'ESP32 offline',
          message: 'Se perdio comunicacion con el controlador WiFi.',
          level: AlertLevel.critical,
          timestamp: DateTime.now(),
        ),
      ...state.alerts,
    ].take(4).toList();

    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.notifications_active_rounded,
            title: 'Alertas',
          ),
          const SizedBox(height: 12),
          if (alerts.isEmpty)
            Text(
              'Sin alertas activas',
              style: TextStyle(color: _DashboardColors.of(context).subtleText),
            )
          else
            ...alerts.map((alert) => _AlertRow(alert: alert)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: controller.toggleEsp32Connection,
            icon: Icon(
              state.esp32Online ? Icons.wifi_off_rounded : Icons.wifi_rounded,
            ),
            label: Text(
              state.esp32Online ? 'Simular perdida ESP32' : 'Reconectar ESP32',
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final dashboardColors = _DashboardColors.of(context);

    return SizedBox(
      width: width,
      child: _GlassPanel(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: dashboardColors.subtleText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: dashboardColors.text,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessRow extends StatelessWidget {
  const _AccessRow({required this.log});

  final AccessLog log;

  @override
  Widget build(BuildContext context) {
    final dashboardColors = _DashboardColors.of(context);
    final color = log.allowed
        ? const Color(0xFF22F78E)
        : const Color(0xFFFF4F4F);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            log.allowed ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.userName,
                  style: TextStyle(
                    color: dashboardColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${log.cardId} · ${log.roleLabel}',
                  style: TextStyle(
                    color: dashboardColors.subtleText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.alert});

  final AlertItem alert;

  @override
  Widget build(BuildContext context) {
    final dashboardColors = _DashboardColors.of(context);
    final color = switch (alert.level) {
      AlertLevel.info => const Color(0xFF35A7FF),
      AlertLevel.warning => const Color(0xFFFFC857),
      AlertLevel.critical => const Color(0xFFFF4F4F),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    color: dashboardColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  alert.message,
                  style: TextStyle(
                    color: dashboardColors.subtleText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBarChart extends StatelessWidget {
  const _MiniBarChart({
    required this.title,
    required this.data,
    required this.color,
  });

  final String title;
  final List<StatPoint> data;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final dashboardColors = _DashboardColors.of(context);
    final maxValue = data
        .map((item) => item.value)
        .fold<int>(1, (a, b) => a > b ? a : b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: dashboardColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 124,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((item) {
              final height = 18 + (item.value / maxValue) * 72;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 450),
                        height: height,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: dashboardColors.subtleText,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _OccupancyGauge extends StatelessWidget {
  const _OccupancyGauge({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final dashboardColors = _DashboardColors.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 650),
      builder: (context, animatedValue, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tasa de ocupacion',
                    style: TextStyle(
                      color: dashboardColors.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${(animatedValue * 100).round()}%',
                  style: const TextStyle(
                    color: Color(0xFF22F78E),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 12,
                value: animatedValue,
                backgroundColor: dashboardColors.divider,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF22F78E)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final dashboardColors = _DashboardColors.of(context);

    return Row(
      children: [
        Icon(icon, color: const Color(0xFF35A7FF)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: dashboardColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final dashboardColors = _DashboardColors.of(context);

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: dashboardColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: dashboardColors.border),
        boxShadow: [
          BoxShadow(
            color: dashboardColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DashboardColors {
  const _DashboardColors({
    required this.backgroundGradient,
    required this.panel,
    required this.border,
    required this.text,
    required this.subtleText,
    required this.divider,
    required this.shadow,
  });

  final List<Color> backgroundGradient;
  final Color panel;
  final Color border;
  final Color text;
  final Color subtleText;
  final Color divider;
  final Color shadow;

  static _DashboardColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const _DashboardColors(
        backgroundGradient: [
          Color(0xFF030A12),
          Color(0xFF061D36),
          Color(0xFF02070D),
        ],
        panel: Color(0x13FFFFFF),
        border: Color(0x1FFFFFFF),
        text: Colors.white,
        subtleText: Color(0xB8FFFFFF),
        divider: Color(0x1FFFFFFF),
        shadow: Color(0x33000000),
      );
    }

    return const _DashboardColors(
      backgroundGradient: [
        Color(0xFFEAF4FF),
        Color(0xFFF7FBFF),
        Color(0xFFDCEBFF),
      ],
      panel: Color(0xEFFFFFFF),
      border: Color(0x3335A7FF),
      text: Color(0xFF06111F),
      subtleText: Color(0xB206111F),
      divider: Color(0x2235A7FF),
      shadow: Color(0x18072D57),
    );
  }
}
