import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/event.dart';

class EventCreationPage extends StatefulWidget {
  final Box<Event> eventBox;

  EventCreationPage({required this.eventBox});

  @override
  _EventCreationPageState createState() => _EventCreationPageState();
}

class _EventCreationPageState extends State<EventCreationPage> {
  final _formKey = GlobalKey<FormState>();


  String _title = '';
  String _description = '';
  List<TimePeriod> _timePeriods = [];
  String _repeat = "Doesn't repeat";
  List<String> _repeatOptions = ["Doesn't repeat", "Custom"];

  @override
  void initState() {
    super.initState();
    _addInitialTimePeriod();
  }

  void _addInitialTimePeriod() {
    _addTimePeriod();
    _updateRepeatOptions();
  }

  void _addTimePeriod() {
    setState(() {
      var startDate = DateTime.now();
      var endDate = DateTime.now().add(Duration(hours: 1));
      _timePeriods.add(TimePeriod(
        startDate: startDate,
        endDate: endDate,
        isAllDay: false,
      ));

      _updateRepeatOptions();
    });
  }

  void _saveEvent() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      Event event = Event(
        title: _title,
        description: _description,
        timePeriods: _timePeriods,
        repeat: _repeat,
      );

      // Save the event to the Hive box
      widget.eventBox.add(event);

      Navigator.pop(context);
    }
  }

  void _updateRepeatOptions() {
    if (_timePeriods.isEmpty) return;

    // Determine the overall duration based on all time periods
    DateTime earliestStart = _timePeriods.first.startDate;
    DateTime latestEnd = _timePeriods.first.endDate;

    for (var period in _timePeriods) {
      if (period.startDate.isBefore(earliestStart)) {
        earliestStart = period.startDate;
      }
      if (period.endDate.isAfter(latestEnd)) {
        latestEnd = period.endDate;
      }
    }

    Duration totalDuration = latestEnd.difference(earliestStart);

    List<String> options = ["Doesn't repeat", "Custom"];

    // Check for time periods within constraints and add appropriate options
    if (totalDuration.inMinutes <= 1440) {
      options.insert(1, 'Repeat daily');
    }

    if (totalDuration.inDays <= 7) {
      options.insert(1, 'Repeat weekly');
    }

    if (totalDuration.inDays <= 365) {
      options.insert(1, 'Repeat annually');
    }

    setState(() {
      _repeatOptions = options;

      // Ensure the current repeat option is valid
      if (!_repeatOptions.contains(_repeat)) {
        _repeat = "Doesn't repeat";
      }
    });
  }

  void _removeTimePeriod(int index) {
    setState(() {
      if (_timePeriods.length > 1) {
        _timePeriods.removeAt(index);
        _updateRepeatOptions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title Field
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Please enter a title' : null,
                onSaved: (value) => _title = value ?? '',
              ),
              // Description Field
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value ?? '',
              ),
              SizedBox(height: 20),
              // Time Periods
              _buildTimePeriods(),
              SizedBox(height: 20),
              // Repeat Options
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Repeat'),
                value: _repeat,
                items: _repeatOptions
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    _repeat = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              // Save Button
              ElevatedButton(
                onPressed: _saveEvent,
                child: Text('Save Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePeriods() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _timePeriods.length,
          itemBuilder: (context, index) {
            return _buildTimePeriodCard(index);
          },
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _addTimePeriod,
          child: Text('Add Time Period'),
        ),
      ],
    );
  }

  Widget _buildTimePeriodCard(int index) {
    TimePeriod period = _timePeriods[index];
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // All day checkbox
            Row(
              children: [
                Checkbox(
                  value: period.isAllDay,
                  onChanged: (value) {
                    setState(() {
                      period.isAllDay = value ?? false;
                      _updateRepeatOptions();
                    });
                  },
                ),
                Text('All day'),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _removeTimePeriod(index);
                  },
                ),
              ],
            ),
            // Start Date
            ListTile(
              title: Text('Start date'),
              subtitle: Text(
                  '${period.startDate.year}/${period.startDate.month}/${period.startDate.day}'),
              onTap: () => _pickStartDate(context, index),
            ),
            // Start Time
            if (!period.isAllDay)
              ListTile(
                title: Text('Start time'),
                subtitle:
                    Text('${TimeOfDay.fromDateTime(period.startDate).format(context)}'),
                onTap: () => _pickStartTime(context, index),
              ),
            // End Date
            ListTile(
              title: Text('End date'),
              subtitle:
                  Text('${period.endDate.year}/${period.endDate.month}/${period.endDate.day}'),
              onTap: () => _pickEndDate(context, index),
            ),
            // End Time
            if (!period.isAllDay)
              ListTile(
                title: Text('End time'),
                subtitle:
                    Text('${TimeOfDay.fromDateTime(period.endDate).format(context)}'),
                onTap: () => _pickEndTime(context, index),
              ),
          ],
        ),
      ),
    );
  }


  // Date and Time Pickers...

  Future<void> _pickStartDate(BuildContext context, int index) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _timePeriods[index].startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );


    if (date != null) {
      setState(() {
        TimeOfDay time = TimeOfDay.fromDateTime(_timePeriods[index].startDate);
        _timePeriods[index].startDate =
            DateTime(date.year, date.month, date.day, time.hour, time.minute);


        // Adjust end date if necessary
        if (_timePeriods[index].startDate.isAfter(_timePeriods[index].endDate)) {
          _timePeriods[index].endDate = _timePeriods[index].startDate;
        }


        _updateRepeatOptions();
      });
    }
  }


  Future<void> _pickEndDate(BuildContext context, int index) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _timePeriods[index].endDate,
      firstDate: _timePeriods[index].startDate,
      lastDate: DateTime(2101),
    );


    if (date != null) {
      setState(() {
        TimeOfDay time = TimeOfDay.fromDateTime(_timePeriods[index].endDate);
        _timePeriods[index].endDate =
            DateTime(date.year, date.month, date.day, time.hour, time.minute);
        _updateRepeatOptions();
      });
    }
  }


  Future<void> _pickStartTime(BuildContext context, int index) async {
    if (_timePeriods[index].isAllDay) return;


    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timePeriods[index].startDate),
    );


    if (time != null) {
      setState(() {
        DateTime date = _timePeriods[index].startDate;
        _timePeriods[index].startDate =
            DateTime(date.year, date.month, date.day, time.hour, time.minute);


        // Adjust end time if necessary
        if (_timePeriods[index].startDate.isAfter(_timePeriods[index].endDate)) {
          _timePeriods[index].endDate = _timePeriods[index].startDate;
        } else if (_timePeriods[index]
            .startDate
            .isAtSameMomentAs(_timePeriods[index].endDate)) {
          // If times are equal, add one minute to end time
          _timePeriods[index].endDate =
              _timePeriods[index].endDate.add(Duration(minutes: 1));
        }


        _updateRepeatOptions();
      });
    }
  }


  Future<void> _pickEndTime(BuildContext context, int index) async {
    if (_timePeriods[index].isAllDay) return;


    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timePeriods[index].endDate),
    );


    if (time != null) {
      setState(() {
        DateTime date = _timePeriods[index].endDate;
        DateTime newEndDate =
            DateTime(date.year, date.month, date.day, time.hour, time.minute);


        if (newEndDate.isBefore(_timePeriods[index].startDate)) {
          // Show an error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('End time cannot be before start time')),
          );
        } else {
          _timePeriods[index].endDate = newEndDate;
          _updateRepeatOptions();
        }
      });
    }
  }
}
