import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quicknote/todolist/utilities/database_helper.dart';
import 'package:quicknote/todolist/model/todolist.dart';
import 'package:quicknote/todolist/screens/add_task_screen.dart';

class TodoListScreeen extends StatefulWidget {
  @override
  _TodoListScreeenState createState() => _TodoListScreeenState();
}

class _TodoListScreeenState extends State<TodoListScreeen> {
  Future<List<Task>> _taskList;
  final DateFormat _dateFormat = DateFormat('MMM dd,yyyy');

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      _taskList = DatabaseHelper.instance.getTaskList();
    });
  }

  Widget _buildTask(Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                  fontSize: 18,
                  decoration: task.status == 0
                      ? TextDecoration.none
                      : TextDecoration.lineThrough),
            ),
            subtitle: Text('${_dateFormat.format(task.date)} ${task.priority}',
                style: TextStyle(
                    fontSize: 15,
                    decoration: task.status == 0
                        ? TextDecoration.none
                        : TextDecoration.lineThrough)),
            trailing: Checkbox(
                onChanged: (value) {
                  task.status = value ? 1 : 0;
                  DatabaseHelper.instance.updateTask(task);
                  _updateTaskList();
                  print(value);
                },
                activeColor: Theme.of(context).primaryColor,
                value: task.status == 1 ? true : false),
            onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (_) => AddTaskSreen(
                          task: task,
                          updateTaskList: _updateTaskList,
                        ))),
          ),
          Divider()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Task"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (_) => AddTaskSreen(
                        updateTaskList: _updateTaskList,
                      )));
        },
        child: Icon(Icons.add),
      ),
      body: FutureBuilder(
          future: _taskList,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final int completedTaskCount = snapshot.data
                .where((Task task) => task.status == 1)
                .toList()
                .length;

            return ListView.builder(
              itemCount: 1 + snapshot.data.length,
              itemBuilder: (BuildContext context, int i) {
                if (i == 0) {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My tasks $completedTaskCount of ${snapshot.data.length}',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600),
                        )
                      ],
                  );
                }
                return _buildTask(snapshot.data[i - 1]);
              },
            );
          }),
    );
  }
}
