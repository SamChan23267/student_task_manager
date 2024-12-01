import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/event.dart';


class EventEditPage extends StatefulWidget {
  final Event event;

  EventEditPage({required this.event});

  @override
  _EventEditPageState createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late List<TimePeriod> _timePeriods;
  late String _repeat;
  List<String> _repeatOptions = ["Doesn't repeat", "Custom"];

  @override
  void initState() {
    super.initState();
    _title = widget.event.title;
    _description = widget.event.description;
    _timePeriods = List<TimePeriod>.from(widget.event.timePeriods);
    _repeat = widget.event.repeat;
  }

  void _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Update the existing event
      widget.event.title = _title;
      widget.event.description = _description;
      widget.event.timePeriods = _timePeriods;
      widget.event.repeat = _repeat;
      await widget.event.save();

      Navigator.of(context).pop();
    }
  }

  void _addTimePeriod() {
    setState(() {
      _timePeriods.add(TimePeriod(
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(hours: 1)),
        isAllDay: false,
      ));

      _updateRepeatOptions();
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

  void _toggleAllDay(int index, bool? value) {
    setState(() {
      _timePeriods[index].isAllDay = value ?? false;
    });
  }

  void _deleteEvent() async {
    await widget.event.delete();
    Navigator.of(context).pop();
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




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteEvent,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title field
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Event Title'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Please enter a title' : null,
                onSaved: (value) => _title = value ?? '',
              ),
              SizedBox(height: 20),
              // Description field
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value ?? '',
              ),
              SizedBox(height: 20),
              // Time Periods
              _buildTimePeriods(),
              SizedBox(height: 20),
              // Repeat option
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Repeat'),
                value: _repeat,
                items: _repeatOptions 
                    .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _repeat = value!;
                  });
                },
                
              ),

              SizedBox(height: 20),
              // Save Button
              ElevatedButton(
                onPressed: _saveEvent,
                child: Text('Save Changes'),
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
}
