import 'package:hive/hive.dart';

part 'app_models.g.dart';

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
  String date;

  CustomPrayer({
    required this.id,
    required this.name,
    required this.rakah,
    this.isCompleted = false,
    required this.date,
  });
}

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

@HiveType(typeId: 2)
class NoteItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  String type;

  @HiveField(4)
  String folderId;

  @HiveField(5)
  int fileSizeBytes;

  NoteItem({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.folderId,
    this.fileSizeBytes = 0,
  });
}

@HiveType(typeId: 3)
class NoteFolder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  NoteFolder({
    required this.id,
    required this.name,
  });
}
