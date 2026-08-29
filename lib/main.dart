import 'package:flutter/material.dart';

import 'models/app_user.dart';
import 'screens/login_screen.dart';
import 'services/firebase_service.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ParqueaderoInteligenteApp());
}

class ParqueaderoInteligenteApp extends StatelessWidget {
  const ParqueaderoInteligenteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0A84FF),
      brightness: Brightness.light,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF35A7FF),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Parqueadero Inteligente',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
        scaffoldBackgroundColor: const Color(0xFFF3F8FF),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 8,
          shadowColor: Color(0x16000000),
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
        scaffoldBackgroundColor: const Color(0xFF030A12),
        cardTheme: const CardThemeData(
          color: Color(0xFF0B1C30),
          elevation: 8,
          shadowColor: Color(0x33000000),
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      home: const _FirebaseBootstrap(),
    );
  }
}

class _FirebaseBootstrap extends StatefulWidget {
  const _FirebaseBootstrap();

  @override
  State<_FirebaseBootstrap> createState() => _FirebaseBootstrapState();
}

class _FirebaseBootstrapState extends State<_FirebaseBootstrap> {
  bool _checking = true;
  bool _firebaseReady = false;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    final ready = await FirebaseService.tryInitialize();
    if (!mounted) {
      return;
    }
    setState(() {
      _checking = false;
      _firebaseReady = ready;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const _StartupScreen();
    }

    return _SessionGate(firebaseReady: _firebaseReady);
  }
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF020814), Color(0xFF062F5F), Color(0xFF02111F)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_parking_rounded, color: Color(0xFF37FF8B), size: 72),
              SizedBox(height: 18),
              Text(
                'PARQUEADERO INTELIGENTE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.6,
                  fontSize: 22,
                ),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(color: Color(0xFF35A7FF)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionGate extends StatefulWidget {
  const _SessionGate({required this.firebaseReady});

  final bool firebaseReady;

  @override
  State<_SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<_SessionGate> {
  AppUser? _currentUser;

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    if (user == null) {
      return LoginScreen(
        onLogin: (newUser) {
          setState(() {
            _currentUser = newUser;
          });
        },
      );
    }

    return HomeScreen(
      firebaseReady: widget.firebaseReady,
      user: user,
      onLogout: () {
        setState(() {
          _currentUser = null;
        });
      },
    );
  }
}
