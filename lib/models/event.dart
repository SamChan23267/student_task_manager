import 'package:hive/hive.dart';

part 'event.g.dart';

@HiveType(typeId: 1)
class Event extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  List<TimePeriod> timePeriods;

  @HiveField(3)
  int recurrenceInterval; // Number of days between recurrences

  Event({
    required this.title,
    required this.description,
    required this.timePeriods,
    this.recurrenceInterval = 0, // 0 means no recurrence
  });
}

@HiveType(typeId: 2)
class TimePeriod extends HiveObject {
  @HiveField(0)
  DateTime startDate;

  @HiveField(1)
  DateTime endDate;

  @HiveField(2)
  bool isAllDay;

  TimePeriod({
    required this.startDate,
    required this.endDate,
    this.isAllDay = false,
  });
}