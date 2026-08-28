import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/logo.png', height: size, width: size);
  }
}
