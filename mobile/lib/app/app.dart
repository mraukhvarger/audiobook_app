import 'package:flutter/material.dart';

class PlayerBookApp extends StatelessWidget {
  const PlayerBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Player Book',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('Player Book')),
      ),
    );
  }
}
