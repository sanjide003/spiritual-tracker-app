// 📂 File: lib/main.dart
// പഴയ main.dart പൂർണ്ണമായും മാറ്റി ഇത് നൽകുക

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/localization/app_localizations.dart';
import 'shared_widgets/main_layout.dart';

void main() async {
  // ആപ്പ് തുടങ്ങുന്നതിന് മുൻപ് ഡാറ്റാബേസുകൾ ലോഡ് ചെയ്യാൻ
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase Initialize ചെയ്യുന്നു
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase Initialization Error: $e');
  }

  // Hive Local Database Initialize ചെയ്യുന്നു
  await Hive.initFlutter();

  runApp(
    // ഭാഷ മാറ്റാൻ സഹായിക്കുന്ന പ്രൊവൈഡർ (Provider) ആഡ് ചെയ്യുന്നു
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppLanguageProvider()),
      ],
      child: const SpiritualTrackerApp(),
    ),
  );
}

class SpiritualTrackerApp extends StatelessWidget {
  const SpiritualTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ഏത് ഭാഷയാണ് സെലക്ട് ചെയ്തത് എന്ന് അറിയാൻ
    final langProvider = Provider.of<AppLanguageProvider>(context);
    
    // അറബിക് ആണെങ്കിൽ ഡിസൈൻ വലത്ത് നിന്നും ഇടത്തേക്ക് (RTL) ആകാൻ
    final isArabic = langProvider.currentLanguage == 'ar';

    return MaterialApp(
      title: 'Spiritual Tracker',
      debugShowCheckedModeBanner: false,
      
      // ഭാഷ അനുസരിച്ച് ഡിസൈൻ ഡയറക്ഷൻ മാറ്റുന്നു (LTR or RTL)
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