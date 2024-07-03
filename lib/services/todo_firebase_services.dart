// ignore_for_file: avoid_single_cascade_in_expression_statements

import 'package:cloud_firestore/cloud_firestore.dart';

class TodoFirebaseServices {
  final _todosCollection = FirebaseFirestore.instance.collection('todos');

  Stream<QuerySnapshot> getTodos() async* {
    yield* _todosCollection.snapshots();
  }

  Future<void> addTodo(
      String title, int priority, bool isDone, Timestamp date) async {
    _todosCollection.add(
        {'title': title, 'priority': priority, 'isDone': isDone, 'date': date});
  }

  Future<void> editTodo(
      String id, String title, int priority, bool isDone, DateTime date) async {
    _todosCollection
      ..doc(id).update({
        'title': title,
        'priority': priority,
        'isDone': isDone,
        'date': date
      });
  }

  Future<void> deleteTodo(String id) async {
    _todosCollection.doc(id).delete();
  }

  Future<void> toggleIsDone(String id, bool isDone) async {
    _todosCollection.doc(id).update({'isDone': isDone});
  }
}
