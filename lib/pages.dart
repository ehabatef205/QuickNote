import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quicknote/screen/note/screens/note_list.dart';
import 'package:quicknote/screen/photo/camera_screen.dart';
import 'package:quicknote/screen/record/record.dart';
import 'package:quicknote/todolist/screens/todo_list_screen.dart';
import 'screen/homePage.dart';

class page extends StatefulWidget {
  int index;

  page(this.index);

  @override
  _pageState createState() => _pageState(index);
}

class _pageState extends State<page> {
  int index;

  _pageState(this.index);

  double _height = 50;

  List<Color> _color = [
    Colors.grey,
    Colors.grey,
    Colors.grey,
    Colors.grey,
    Colors.grey
  ];

  @override
  Widget build(BuildContext context) {
    _color[index] = Colors.blue;
    Widget child;
    switch (index) {
      case 0:
        child = homePage();
        break;
      case 1:
        child = NoteList();
        break;
      case 2:
        child = record();
        break;
      case 3:
        child = CameraScreen();
        break;
      case 4:
        child = TodoListScreeen();
        break;
    }

    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        SystemNavigator.pop();
      },
      child: Scaffold(
        body: Container(child: child),
        bottomNavigationBar: SafeArea(
          child: Stack(
            children: [
              BottomNavigationBar(
                onTap: (newIndex) {
                  setState(() => index = newIndex);
                  for (int i = 0; i < 5; i++) {
                    _color[i] = Colors.grey;
                  }
                  _color[index] = Colors.blue;
                },
                currentIndex: index,
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home, color: _color[0]),
                      title:
                          Text("Home", style: TextStyle(color: Colors.blue))),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.note, color: _color[1]),
                      title:
                          Text("Note", style: TextStyle(color: Colors.blue))),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.mic, color: _color[2]),
                      title:
                          Text("Record", style: TextStyle(color: Colors.blue))),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.camera, color: _color[3]),
                      title:
                          Text("Camera", style: TextStyle(color: Colors.blue))),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.today, color: _color[4]),
                      title: Text("To do list",
                          style: TextStyle(color: Colors.blue))),
                ],
              ),
              SizedBox(height: _height)
            ],
          ),
        ),
      ),
    );
  }
}
