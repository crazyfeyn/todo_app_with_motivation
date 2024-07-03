import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String id;
  String title;
  bool isDone;
  int priority;
  Timestamp date;

  Todo({
    required this.id,
    required this.title,
    required this.isDone,
    required this.priority,
    required this.date,
  });

  factory Todo.fromJson(QueryDocumentSnapshot query) {
    return Todo(
        id: query.id,
        title: query['title'],
        isDone: query['isDone'],
        priority: query['priority'],
        date: query['date']);
  }
}
