// 📂 File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'services/database_service.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/theme_provider.dart'; // പുതിയത്
import 'shared_widgets/main_layout.dart';

import 'features/prayer/prayer_controller.dart';
import 'features/dhikr/dhikr_controller.dart';
import 'features/notes/notes_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('Firebase Error: $e');
  }

  await DatabaseService.initDatabase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppLanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Theme Provider
        ChangeNotifierProvider(create: (_) => PrayerController()),
        ChangeNotifierProvider(create: (_) => DhikrController()),
        ChangeNotifierProvider(create: (_) => NotesController()),
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
    final themeProvider = Provider.of<ThemeProvider>(context); // തീം എടുക്കുന്നു
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
      // യൂസർ സെലക്ട് ചെയ്ത തീം ഉപയോഗിക്കുന്നു
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light, 
      home: const MainLayout(),
    );
  }
}