import 'package:flutter/material.dart';
import '../models/event.dart';

class TimePeriodWidget extends StatefulWidget {
  final TimePeriod timePeriod;
  final VoidCallback onDelete;
  final ValueChanged<TimePeriod> onUpdate;

  TimePeriodWidget({
    required this.timePeriod,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  _TimePeriodWidgetState createState() => _TimePeriodWidgetState();
}

class _TimePeriodWidgetState extends State<TimePeriodWidget> {
  late DateTime _startDate;
  late DateTime _endDate;
  late bool _isAllDay;

  @override
  void initState() {
    super.initState();
    _startDate = widget.timePeriod.startDate;
    _endDate = widget.timePeriod.endDate;
    _isAllDay = widget.timePeriod.isAllDay;
  }

  Future<void> _pickStartDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
        _updateTimePeriod();
      });
    }
  }

  Future<void> _pickEndDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
        _updateTimePeriod();
      });
    }
  }

  void _toggleAllDay(bool? value) {
    setState(() {
      _isAllDay = value ?? false;
      _updateTimePeriod();
    });
  }

  void _updateTimePeriod() {
    widget.onUpdate(
      TimePeriod(
        startDate: _startDate,
        endDate: _endDate,
        isAllDay: _isAllDay,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(
            title: Text('Start Date: ${_startDate.toLocal()}'),
            trailing: Icon(Icons.calendar_today),
            onTap: _pickStartDate,
          ),
          ListTile(
            title: Text('End Date: ${_endDate.toLocal()}'),
            trailing: Icon(Icons.calendar_today),
            onTap: _pickEndDate,
          ),
          CheckboxListTile(
            title: Text('All Day'),
            value: _isAllDay,
            onChanged: _toggleAllDay,
          ),
          TextButton.icon(
            onPressed: widget.onDelete,
            icon: Icon(Icons.delete, color: Colors.red),
            label: Text('Remove Time Period', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}