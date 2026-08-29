import 'package:flutter_test/flutter_test.dart';
import 'package:parqueadero_inteligente/main.dart';

void main() {
  testWidgets('muestra el dashboard inteligente', (tester) async {
    await tester.pumpWidget(
      const ParqueaderoInteligenteApp(),
    );
    await tester.pump();

    expect(find.text('Ingreso seguro al panel IoT'), findsOneWidget);
    await tester.tap(find.text('Ingresar'));
    await tester.pump();

    expect(find.text('PARQUEADERO INTELIGENTE'), findsOneWidget);
    expect(find.text('Mapa visual de parqueos'), findsOneWidget);
    expect(find.text('Control de barrera'), findsOneWidget);
    expect(find.text('Acceso RFID'), findsOneWidget);
    expect(find.text('Estadisticas inteligentes'), findsOneWidget);
    expect(find.text('Alertas'), findsOneWidget);
  });
}
