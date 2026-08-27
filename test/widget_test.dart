import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:banapp/screens/seleccionar_usuario_screen.dart';

void main() {
  testWidgets('Seleccionar usuario screen shows the "quien eres" prompt',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(const MaterialApp(home: SeleccionarUsuarioScreen()));

    expect(find.text('¿Quién eres?'), findsOneWidget);
  });
}
