import 'package:flutter/material.dart';
import 'shared_widgets/main_layout.dart';

void main() {
  runApp(const SpiritualTrackerApp());
}

class SpiritualTrackerApp extends StatelessWidget {
  const SpiritualTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spiritual Tracker',
      debugShowCheckedModeBanner: false,
      // Light Theme Setup
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // Dark Theme Setup
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // Automatically switch based on device settings
      themeMode: ThemeMode.system, 
      home: const MainLayout(),
    );
  }
}