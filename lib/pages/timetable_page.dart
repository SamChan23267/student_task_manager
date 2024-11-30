import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/event.dart';
import 'event_creation_page.dart';

class TimetablePage extends StatefulWidget {
  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  late Box<Event> eventBox;
  bool _isHiveInitialized = false;
  String? _initializationError;

  @override
  void initState() {
    super.initState();
    _openMyBox();
  }

  Future<void> _openMyBox() async {
    if (!Hive.isBoxOpen('events')){
      eventBox = await Hive.openBox<Event>('events');
    } else {
      eventBox = Hive.box<Event>('events');
    }
  }

  void _navigateToEventCreation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventCreationPage(eventBox: eventBox),
      ),
    ).then((_) {
      // Debugging print statement
      print('Returned from EventCreationPage, refreshing calendar.');
      setState(() {
        // The ValueListenableBuilder will automatically refresh the calendar
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (eventBox == null) {
      // Show loading indicator while the box is opening
      return Scaffold(
        appBar: AppBar(
          title: Text('Timetable'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Timetable'),
      ),
      body: ValueListenableBuilder(
        valueListenable: eventBox!.listenable(),
        builder: (context, Box<Event> box, _) {
          print('ValueListenableBuilder triggered, events have changed.');
          return SfCalendar(
            view: CalendarView.month,
            dataSource: EventDataSource(_getCalendarEvents(box)),
            monthViewSettings: MonthViewSettings(
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _navigateToEventCreation,
      ),
    );
  }

  List<Appointment> _getCalendarEvents(Box<Event> box) {
    List<Appointment> calendarEvents = [];

    print('Loading events from Hive box...');
    print('Total events in box: ${box.length}');

    for (var event in box.values) {
      print('Event loaded: ${event.title}');
      print('Description: ${event.description}');
      print('Repeat: ${event.repeat}');

      for (var period in event.timePeriods) {
        print('Time Period - Start: ${period.startDate}, End: ${period.endDate}, All Day: ${period.isAllDay}');
        var appointment = Appointment(
          startTime: period.startDate,
          endTime: period.endDate,
          subject: event.title,
          notes: event.description,
          isAllDay: period.isAllDay,
          recurrenceRule: _getRecurrenceRule(event),
        );
        calendarEvents.add(appointment);
        print('Appointment created: ${appointment.subject}');
        print('Start Time: ${appointment.startTime}, End Time: ${appointment.endTime}');
        print('Recurrence Rule: ${appointment.recurrenceRule}');
      }
    }

    print('Total appointments created: ${calendarEvents.length}');
    return calendarEvents;
  }

  String? _getRecurrenceRule(Event event) {
  String? recurrenceRule;
  switch (event.repeat) {
    case 'Repeat daily':
      recurrenceRule = 'FREQ=DAILY';
      break;
    case 'Repeat weekly':
      recurrenceRule = 'FREQ=WEEKLY';
      break;
    case 'Repeat annually':
      recurrenceRule = 'FREQ=YEARLY';
      break;
    default:
      recurrenceRule = null;
  }
  print('Recurrence rule for event "${event.title}": $recurrenceRule');
  return recurrenceRule;
}
}

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Appointment> source) {
    appointments = source;
  }
}