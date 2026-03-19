import 'package:flutter/material.dart';

import 'scr/S000.dart';
import 'styles.dart';

void main() {
  runApp(const JuridicaiApp());
}

class JuridicaiApp extends StatelessWidget {
  const JuridicaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStyles.appTitle,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppStyles.seedColor),
      ),
      home: const S000(),
    );
  }
}
