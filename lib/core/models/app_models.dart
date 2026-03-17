import 'package:hive/hive.dart';

// 1. സുന്നത്ത് നിസ്കാരങ്ങൾക്കുള്ള മോഡൽ
class CustomPrayer {
  String id;
  String name;
  int rakah;
  bool isCompleted;

  CustomPrayer({required this.id, required this.name, required this.rakah, this.isCompleted = false});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'rakah': rakah, 'isCompleted': isCompleted};
  factory CustomPrayer.fromMap(Map<dynamic, dynamic> map) => CustomPrayer(
    id: map['id'], name: map['name'], rakah: map['rakah'], isCompleted: map['isCompleted'] ?? false,
  );
}

// 2. ദിക്റുകൾക്കുള്ള മോഡൽ
class CustomDhikr {
  String id;
  String text;
  int count;

  CustomDhikr({required this.id, required this.text, this.count = 0});

  Map<String, dynamic> toMap() => {'id': id, 'text': text, 'count': count};
  factory CustomDhikr.fromMap(Map<dynamic, dynamic> map) => CustomDhikr(
    id: map['id'], text: map['text'], count: map['count'] ?? 0,
  );
}

// 3. നോട്ട്സുകൾക്കുള്ള മോഡൽ
class NoteItem {
  String id;
  String title;
  String content;
  String type;

  NoteItem({required this.id, required this.title, required this.content, required this.type});

  Map<String, dynamic> toMap() => {'id': id, 'title': title, 'content': content, 'type': type};
  factory NoteItem.fromMap(Map<dynamic, dynamic> map) => NoteItem(
    id: map['id'], title: map['title'], content: map['content'], type: map['type'],
  );
}