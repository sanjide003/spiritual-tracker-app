// 📂 File: test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:spiritual_tracker_app/main.dart';
import 'package:spiritual_tracker_app/core/localization/app_localizations.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppLanguageProvider()),
        ],
        child: const SpiritualTrackerApp(),
      ),
    );

    // Verify that the first tab is loaded (Prayer)
    expect(find.byIcon(Icons.mosque_outlined), findsOneWidget);
  });
}