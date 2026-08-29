import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/parking_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLogin});

  final ValueChanged<AppUser> onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'admin@parqueadero.com');
  final _passwordController = TextEditingController(text: '123456');
  UserRole _selectedRole = UserRole.administrator;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final email = _emailController.text.trim();
    if (email.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa correo y contrasena')),
      );
      return;
    }

    widget.onLogin(
      AppUser(
        name: _nameFromRole(_selectedRole),
        email: email,
        role: _selectedRole,
      ),
    );
  }

  String _nameFromRole(UserRole role) {
    switch (role) {
      case UserRole.administrator:
        return 'Admin Central';
      case UserRole.operator:
        return 'Operador Garita';
      case UserRole.client:
        return 'Cliente';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _LoginColors.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors.gradient,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: colors.panel,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow,
                        blurRadius: 30,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.local_parking_rounded,
                        color: colors.accent,
                        size: 64,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'PARQUEADERO INTELIGENTE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ingreso seguro al panel IoT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.subtleText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo',
                          prefixIcon: Icon(Icons.email_rounded),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Contrasena',
                          prefixIcon: const Icon(Icons.lock_rounded),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<UserRole>(
                        segments: const [
                          ButtonSegment(
                            value: UserRole.administrator,
                            icon: Icon(Icons.admin_panel_settings_rounded),
                            label: Text('Admin'),
                          ),
                          ButtonSegment(
                            value: UserRole.operator,
                            icon: Icon(Icons.support_agent_rounded),
                            label: Text('Operador'),
                          ),
                          ButtonSegment(
                            value: UserRole.client,
                            icon: Icon(Icons.person_rounded),
                            label: Text('Cliente'),
                          ),
                        ],
                        selected: {_selectedRole},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _selectedRole = selection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: _login,
                        icon: const Icon(Icons.login_rounded),
                        label: const Text('Ingresar'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginColors {
  const _LoginColors({
    required this.gradient,
    required this.panel,
    required this.border,
    required this.text,
    required this.subtleText,
    required this.accent,
    required this.shadow,
  });

  final List<Color> gradient;
  final Color panel;
  final Color border;
  final Color text;
  final Color subtleText;
  final Color accent;
  final Color shadow;

  static _LoginColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const _LoginColors(
        gradient: [Color(0xFF030A12), Color(0xFF061D36), Color(0xFF02070D)],
        panel: Color(0xEE071529),
        border: Color(0x3335A7FF),
        text: Colors.white,
        subtleText: Color(0xB8FFFFFF),
        accent: Color(0xFF22F78E),
        shadow: Color(0x66000000),
      );
    }

    return const _LoginColors(
      gradient: [Color(0xFFEAF4FF), Color(0xFFFFFFFF), Color(0xFFDCEBFF)],
      panel: Color(0xF7FFFFFF),
      border: Color(0x3335A7FF),
      text: Color(0xFF06111F),
      subtleText: Color(0xB206111F),
      accent: Color(0xFF0A84FF),
      shadow: Color(0x22072D57),
    );
  }
}
