import 'dart:io';
import 'package:flutter/material.dart';
import 'package:quicknote/pages.dart';
import 'package:quicknote/password/modelspassword/password.dart';
import 'package:quicknote/password/utilities/database_helper.dart';

import 'package:sqflite/sqflite.dart';

class oldPasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _oldPasswordPageState();
  }
}

class _oldPasswordPageState extends State<oldPasswordPage> {
  Password password;
  List<Password> passwordsList;
  SQL_Helper helper = new SQL_Helper();

  TextEditingController passwordController = new TextEditingController();
  String _enteredPassword = "";

  bool _obscureText = true;

  void toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  int count = 0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (passwordsList == null) {
      passwordsList = new List<Password>();
      updateListView();
    }

    // TODO: implement build
    return WillPopScope(
        child: Scaffold(
      appBar: AppBar(
        title: Text("Lock app"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: width * 0.8,
              child: TextFormField(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  focusColor: Colors.grey,
                  hintStyle: TextStyle(color: Colors.grey),
                  hintText: "Enter your password",
                  labelText: "Password",
                  labelStyle: TextStyle(color: Colors.blue),
                  suffixIcon: IconButton(
                    icon: Icon(
                        !_obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.black),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.lightBlue[50],
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Colors.grey,
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide(
                          color: Colors.grey[500],
                          style: BorderStyle.solid,
                          width: 1)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(
                        color: Colors.grey, style: BorderStyle.solid, width: 1),
                  ),
                ),
                controller: passwordController,
                obscureText: _obscureText,
                onSaved: (val) => _enteredPassword = val,
                onChanged: (value) {
                  setState(() {
                    _enteredPassword = value;
                  });
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: RaisedButton(
                color: Colors.blue[700],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                padding: EdgeInsets.symmetric(horizontal: 70, vertical: 10),
                onPressed: () {
                  // ignore: unrelated_type_equality_checks
                  _enteredPassword.trim().isEmpty ||
                          passwordsList[0].password != _enteredPassword
                      ? null
                      : Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => page(0)),
                        );
                  passwordController.clear();
                },
                child: Text(
                  "Log In",
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
    ));
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
