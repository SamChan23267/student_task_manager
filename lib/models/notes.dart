import 'package:hive/hive.dart';

part 'notes.g.dart';

@HiveType(typeId: 3)
class Note {
  @HiveField(0)
  final String title;

  @HiveField(1)
  String content;

  Note({
    required this.title,
    this.content = '',
  });
}