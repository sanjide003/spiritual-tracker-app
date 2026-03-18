import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/localization/app_localizations.dart';
import 'core/theme/theme_provider.dart';
import 'features/dhikr/dhikr_controller.dart';
import 'features/notes/notes_controller.dart';
import 'features/prayer/prayer_controller.dart';
import 'features/settings/backup_controller.dart';
import 'services/database_service.dart';
import 'shared_widgets/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.initDatabase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppLanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PrayerController()),
        ChangeNotifierProvider(create: (_) => DhikrController()),
        ChangeNotifierProvider(create: (_) => NotesController()),
        ChangeNotifierProvider(create: (_) => BackupController()),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
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
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MainLayout(),
    );
  }
}
