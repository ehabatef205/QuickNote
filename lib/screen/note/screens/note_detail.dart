import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quicknote/screen/note/models/note.dart';
import 'package:quicknote/screen/note/utils/database_helper.dart';
import 'package:quicknote/pages.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  static var _priorities = ['High', 'Low'];

  DatabaseHelpers helper = DatabaseHelpers();

  String appBarTitle;
  Note note;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.subtitle1;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(

        // ignore: missing_return
        onWillPop: () {
          // Write some code to control things, when user press Back navigation button in device navigationBar
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => page(1)));
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              appBarTitle,
            ),
            centerTitle: true,
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  // Write some code to control things, when user press back button in AppBar
                  moveToLastScreen();
                }),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                // First element
                DropdownButtonFormField(
                    isDense: true,
                    items: _priorities.map((String dropDownStringItem) {
                      return DropdownMenuItem(
                          value: dropDownStringItem,
                          child: Text(dropDownStringItem));
                    }).toList(),
                    style: textStyle,
                    decoration: InputDecoration(
                        labelText: 'Priority',
                        labelStyle: TextStyle(fontSize: 18),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                    validator: (input) => note.priority == null
                        ? "Please Select a priority level"
                        : null,
                    value: getPriorityAsString(note.priority),
                    onChanged: (valueSelectedByUser) {
                      setState(() {
                        debugPrint('User selected $valueSelectedByUser');
                        updatePriorityAsInt(valueSelectedByUser);
                      });
                    }),
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                      focusColor: Colors.grey,
                      hintStyle: TextStyle(color: Colors.grey),
                      hintText: "Enter your title",
                      labelText: "Title",
                      labelStyle: TextStyle(color: Colors.blue),
                      filled: true,
                      fillColor: Colors.lightBlue[50],
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.grey[500],
                              style: BorderStyle.solid,
                              width: 1)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Colors.grey,
                            style: BorderStyle.solid,
                            width: 1),
                      ),
                    ),
                    controller: titleController,
                    onChanged: (value) {
                      debugPrint('Something changed in Title Text Field');
                      updateTitle();
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                    maxLines: null,
                    maxLength: 20000,
                    decoration: InputDecoration(
                      focusColor: Colors.grey,
                      hintStyle: TextStyle(color: Colors.grey),
                      hintText: "Enter your description",
                      labelText: "Description",
                      labelStyle: TextStyle(color: Colors.blue),
                      filled: true,
                      fillColor: Colors.lightBlue[50],
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.grey[500],
                              style: BorderStyle.solid,
                              width: 1)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Colors.grey,
                            style: BorderStyle.solid,
                            width: 1),
                      ),
                    ),
                    controller: descriptionController,
                    onChanged: (value) {
                      debugPrint('Something changed in Description Text Field');
                      updateDescription();
                    },
                  ),
                ),
                // Fourth Element
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Colors.blue[700],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          onPressed: () {
                            setState(() {
                              debugPrint("Save button clicked");
                              _save();
                            });
                          },
                          child: Text(
                            "Save",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Container(
                        width: 15,
                      ),
                      Expanded(
                        child: RaisedButton(
                          color: Colors.blue[700],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          onPressed: () {
                            setState(() {
                              debugPrint("Delete button clicked");
                              _delete();
                            });
                          },
                          child: Text(
                            "Delete",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Convert the String priority in the form of integer before saving it to Database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  // Convert int priority to String priority and display it to user in DropDown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; // 'High'
        break;
      case 2:
        priority = _priorities[1]; // 'Low'
        break;
    }
    return priority;
  }

  // Update the title of Note object
  void updateTitle() {
    note.title = titleController.text;
  }

  // Update the description of Note object
  void updateDescription() {
    note.description = descriptionController.text;
  }

  // Save data to database
  void _save() async {
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      // Case 1: Update operation
      result = await helper.updateNote(note);
    } else {
      // Case 2: Insert Operation
      result = await helper.insertNote(note);
    }
  }

  void _delete() async {
    moveToLastScreen();

    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
    // the detail page by pressing the FAB of NoteList page.

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await helper.deleteNote(note.id);
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
