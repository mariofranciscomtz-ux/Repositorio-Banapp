import 'package:flutter/material.dart';
import 'data/powersync.dart';
import 'screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await openDatabase();
  runApp(const BanappApp());
}

class BanappApp extends StatelessWidget {
  const BanappApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banapp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
