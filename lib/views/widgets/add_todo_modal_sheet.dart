import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/todo_firebase_controllers.dart';
import 'package:flutter_application_1/services/local_notification_services.dart';

class AddTodoModalSheet extends StatefulWidget {
  const AddTodoModalSheet({super.key});

  @override
  State<AddTodoModalSheet> createState() => _AddTodoModalSheetState();
}

class _AddTodoModalSheetState extends State<AddTodoModalSheet> {
  TodoFirebaseControllers todoFirebaseControllers = TodoFirebaseControllers();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priorityController = TextEditingController();
  bool isDone = false;
  DateTime? date;
  TimeOfDay? time;

  @override
  void dispose() {
    _titleController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        int.tryParse(_priorityController.text) != null &&
        int.parse(_priorityController.text) > 0 &&
        int.parse(_priorityController.text) < 4 &&
        date != null &&
        time != null) {
      if (date != null && time != null) {
        DateTime dateTime = DateTime(
            date!.year, date!.month, date!.day, time!.hour, time!.minute);
        Timestamp timestamp = Timestamp.fromDate(dateTime);
        todoFirebaseControllers.addTodo(_titleController.text,
            int.parse(_priorityController.text), isDone, timestamp);
        Duration difference = date!.difference(DateTime.now());
        print(difference);
        LocalNotificationServices.showScheduledNotification(
            difference.inSeconds,
            _titleController.text,
            int.parse(_priorityController.text));
      }
      _titleController.clear();
      _priorityController.clear();
      setState(() {
        date = null;
        time = null;
      });

      Navigator.of(context).pop();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != date) {
      setState(() {
        date = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: time ?? TimeOfDay.now(),
    );
    if (picked != null && picked != time) {
      setState(() {
        time = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF363636),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(23),
          topRight: Radius.circular(23),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              'Add your task',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 13),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: _priorityController,
              decoration: InputDecoration(
                labelText: 'Priority (1-3)',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a priority';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text(
                date == null
                    ? 'Select Date'
                    : 'Date: ${date?.toLocal().toString().split(' ')[0]}',
                style: TextStyle(color: Color(0xFF8687E6)),
              ),
              trailing: Icon(Icons.calendar_today, color: Color(0xFF8687E6)),
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text(
                time == null ? 'Select Time' : 'Time: ${time!.format(context)}',
                style: TextStyle(color: Color(0xFF8687E6)),
              ),
              trailing: Icon(Icons.alarm, color: Color(0xFF8687E6)),
              onTap: () => _selectTime(context),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
