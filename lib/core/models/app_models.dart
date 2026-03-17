// 📂 File: lib/core/models/app_models.dart
// Hive ഡാറ്റാബേസിൽ ഡാറ്റ സേവ് ചെയ്യാനുള്ള മോഡലുകൾ (Tables)

import 'package:hive/hive.dart';

part 'app_models.g.dart'; // ഇത് Hive ഓട്ടോമാറ്റിക് ആയി ജനറേറ്റ് ചെയ്യുന്ന ഫയലാണ് (കമാൻഡ് റൺ ചെയ്യണം)

// 1. സുന്നത്ത് നിസ്കാരങ്ങൾക്കുള്ള മോഡൽ
@HiveType(typeId: 0)
class CustomPrayer extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int rakah;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  String date; // ഏത് ദിവസത്തെ നിസ്കാരമാണ് എന്ന് സേവ് ചെയ്യാൻ

  CustomPrayer({
    required this.id,
    required this.name,
    required this.rakah,
    this.isCompleted = false,
    required this.date,
  });
}

// 2. ദിക്റുകൾക്കുള്ള മോഡൽ
@HiveType(typeId: 1)
class CustomDhikr extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String text;

  @HiveField(2)
  int count;

  CustomDhikr({
    required this.id,
    required this.text,
    this.count = 0,
  });
}

// 3. നോട്ട്സ്/ജേണൽ മോഡൽ
@HiveType(typeId: 2)
class NoteItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  String type; // text, image, pdf

  NoteItem({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
  });
}