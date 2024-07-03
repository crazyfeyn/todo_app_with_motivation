import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/todo_firebase_controllers.dart';
import 'package:flutter_application_1/models/todo.dart';
import 'package:flutter_application_1/services/local_notification_services.dart';
import 'package:flutter_application_1/views/widgets/add_todo_modal_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final todoFirebaseControllers = TodoFirebaseControllers();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: StreamBuilder(
        stream: todoFirebaseControllers.todosList,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: Text('No Todos avaliable',
                  style: TextStyle(color: Colors.white)),
            );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ...List.generate(snapshot.data.docs.length, (int index) {
                Todo todo = Todo.fromJson(snapshot.data.docs[index]);
                DateTime convertedDateTime = todo.date.toDate();
                return ListTile(
                  title: Text(todo.title,
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(convertedDateTime.toString(),
                      style: TextStyle(color: Colors.white)),
                  trailing: IconButton(
                      onPressed: () {
                        todoFirebaseControllers.toggleIsDone(
                            todo.id, !todo.isDone);
                      },
                      icon: todo.isDone
                          ? Icon(Icons.check_box)
                          : Icon(Icons.check_box_outline_blank)),
                  leading: Text(todo.priority.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 19)),
                );
              })
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xFF8687E6),
          shape: const CircleBorder(),
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return AddTodoModalSheet();
                });
          },
          child: const Icon(CupertinoIcons.add)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Container(
          height: 60.0,
        ),
      ),
    );
  }
}
