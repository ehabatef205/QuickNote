import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quicknote/pages.dart';
import 'package:quicknote/password/modelspassword/password.dart';
import 'package:quicknote/password/utilities/database_helper.dart';
import 'package:quicknote/screen/passwordlog.dart';
import 'package:sqflite/sqflite.dart';

class passwords extends StatefulWidget {
  @override
  _passwordsState createState() => _passwordsState();
}

class _passwordsState extends State<passwords> {
  Password password;
  List<Password> passwordsList;
  int count = 0;
  SQL_Helper helper = new SQL_Helper();

  TextEditingController passwordController = TextEditingController();

  String pass = "";

  @override
  Widget build(BuildContext context) {
    if (passwordsList == null) {
      passwordsList = new List<Password>();
      updateListView();
    }
    Directory dir = Directory(
        '/data/user/0/com.xcodeteam.quicknote/app_flutter/passwords.db');
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => page(0)));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Lock app password"),
          centerTitle: true,
        ),
        body: dir.existsSync()
            ? ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.lock),
                    title: Text("Modify password"),
                    onTap: () {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          // ignore: missing_return
                          builder: (BuildContext context) {
                            return WillPopScope(
                              // ignore: missing_return
                              onWillPop: () {
                                Navigator.of(context).pop(true);
                              },
                              child: AlertDialog(
                                title: Text("Your password"),
                                content: TextField(
                                  controller: passwordController,
                                  onChanged: (value) {
                                    setState(() {
                                      pass = value;
                                    });
                                  },
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      labelText: "Your password",
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0))),
                                ),
                                actions: [
                                  Center(
                                    child: FlatButton(
                                      child: Text("Cancel"),
                                      onPressed: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (context) => passwords()));
                                      },
                                    ),
                                  ),
                                  Center(
                                    child: FlatButton(
                                      child: Text("Save"),
                                      onPressed: () {
                                        if (pass == passwordsList[0].password) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      passwordPage(passwordsList[0])));
                                        } else {
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (context) => passwords()));
                                        }
                                      },
                                    ),
                                  )
                                ],
                              ),
                            );
                          });
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.lock_open),
                    title: Text("Turn off password"),
                    onTap: () {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          // ignore: missing_return
                          builder: (BuildContext context) {
                            return WillPopScope(
                              // ignore: missing_return
                              onWillPop: () {
                                Navigator.of(context).pop(true);
                              },
                              child: AlertDialog(
                                title: Text("Your password"),
                                content: TextField(
                                  controller: passwordController,
                                  onChanged: (value) {
                                    setState(() {
                                      pass = value;
                                    });
                                  },
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      labelText: 'Your password',
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0))),
                                ),
                                actions: [
                                  Center(
                                    child: FlatButton(
                                      child: Text("Cancel"),
                                      onPressed: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (context) => passwords()));
                                      },
                                    ),
                                  ),
                                  Center(
                                    child: FlatButton(
                                      child: Text("Save"),
                                      onPressed: () {
                                        if (pass == passwordsList[0].password) {
                                          helper.deletePassword(passwordsList[0].id);
                                          dir.deleteSync();
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (context) => passwords()));
                                        } else {
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (context) => passwords()));
                                        }
                                      },
                                    ),
                                  )
                                ],
                              ),
                            );
                          });
                    },
                  ),
                ],
              )
            : ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.lock),
                    title: Text("Turn on password"),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  passwordPage(Password(""))));
                    },
                  ),
                ],
              ),
      ),
    );
  }

  void updateListView() {
    final Future<Database> db = helper.initializedDatabase();
    db.then((database) {
      Future<List<Password>> names = helper.getPasswordList();
      names.then((theList) {
        setState(() {
          this.passwordsList = theList;
          this.count = theList.length;
        });
      });
    });
  }
}
