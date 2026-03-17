// 📂 File: lib/main.dart
// പഴയത് മാറ്റി ഈ പുതിയ main.dart നൽകുക

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/localization/app_localizations.dart';
import 'shared_widgets/main_layout.dart';
import 'features/prayer/prayer_controller.dart';
import 'features/dhikr/dhikr_controller.dart';
import 'features/habits/habit_controller.dart'; // New
import 'features/notes/notes_controller.dart'; // New

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase Initialization Error: $e');
  }

  await Hive.initFlutter();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppLanguageProvider()),
        ChangeNotifierProvider(create: (_) => PrayerController()),
        ChangeNotifierProvider(create: (_) => DhikrController()),
        ChangeNotifierProvider(create: (_) => HabitController()), // New
        ChangeNotifierProvider(create: (_) => NotesController()), // New
      ],
      child: const SpiritualTrackerApp(),
    ),
  );
}

class SpiritualTrackerApp extends StatelessWidget {
  const SpiritualTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<AppLanguageProvider>(context);
    final isArabic = langProvider.currentLanguage == 'ar';

    return MaterialApp(
      title: 'Spiritual Tracker',
      debugShowCheckedModeBanner: false,
      
      builder: (context, child) {
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system, 
      home: const MainLayout(),
    );
  }
}