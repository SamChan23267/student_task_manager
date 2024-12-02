import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/event.dart';
import 'event_creation_page.dart';
import 'event_edit_page.dart';

class TimetablePage extends StatefulWidget {
  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  late Box<Event> eventBox;
  CalendarController _calendarController = CalendarController();
  CalendarView _currentView = CalendarView.month;
  int _recurrenceInterval = 0; // Default value

  @override
  void initState() {
    super.initState();
    _openMyBox().then((_) {});
  }

  Future<void> _openMyBox() async {
    if (!Hive.isBoxOpen('events')) {
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
      setState(() {
        // The ValueListenableBuilder will automatically refresh the calendar
      });
    });
  }

  void _onCalendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment && details.appointments != null) {
      final Appointment appointment = details.appointments!.first;
      final String eventKeyString = appointment.notes ?? '';

      if (eventKeyString.isNotEmpty) {
        try {
          final int eventKey = int.parse(eventKeyString);
          final Event? tappedEvent = eventBox.get(eventKey);

          if (tappedEvent != null) {
            _navigateToEventEdit(tappedEvent);
          }
        } catch (e) {
          // Handle parsing error gracefully
          print('Error parsing event key: $e');
        }
      }
    }
  }

  void _navigateToEventEdit(Event event) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventEditPage(event: event),
      ),
    );
    setState(() {}); // Refresh the calendar after returning
  }

  void _toggleCalendarView() {
    setState(() {
      if (_currentView == CalendarView.month) {
        _currentView = CalendarView.week;
      } else {
        _currentView = CalendarView.month;
      }
      _calendarController.view = _currentView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                _calendarController.backward!();
              },
            ),
            SizedBox(width: 16), // Add some spacing between the buttons
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                _calendarController.forward!();
              },
            ),
            SizedBox(width: 16), // Spacing before the toggle button
            IconButton(
              icon: Icon(
                _currentView == CalendarView.month ? Icons.view_week : Icons.view_module,
              ),
              onPressed: _toggleCalendarView,
              tooltip: _currentView == CalendarView.month
                  ? 'Switch to Week View'
                  : 'Switch to Month View',
            ),
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: eventBox.listenable(),
        builder: (context, Box<Event> box, _) {
          return SfCalendar(
            view: _currentView,
            controller: _calendarController,
            dataSource: EventDataSource(_getCalendarEvents(box)),
            monthViewSettings: MonthViewSettings(
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            ),
            onTap: _onCalendarTapped,
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
    List<Appointment> appointments = [];

    for (var event in box.values) {
      String? rRule = _getRecurrenceRule(event);

      if (rRule == null) {
        // Non-recurring event
        appointments.add(
          Appointment(
            startTime: event.timePeriods.first.startDate,
            endTime: event.timePeriods.first.endDate,
            subject: event.title,
            notes: event.key.toString(),
            isAllDay: event.timePeriods.first.isAllDay,
          ),
        );
      } else {
        // Recurring event with FREQ=DAILY;INTERVAL=x
        appointments.add(
          Appointment(
            startTime: event.timePeriods.first.startDate,
            endTime: event.timePeriods.first.endDate,
            subject: event.title,
            notes: event.key.toString(),
            isAllDay: event.timePeriods.first.isAllDay,
            recurrenceRule: rRule,
          ),
        );
      }
    }

    return appointments;
  }

  String? _getRecurrenceRule(Event event) {
    if (event.recurrenceInterval <= 0) {
      return null; // No recurrence
    }

    return 'FREQ=DAILY;INTERVAL=${event.recurrenceInterval}';
  }
}

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Appointment> source) {
    appointments = source;
  }
}