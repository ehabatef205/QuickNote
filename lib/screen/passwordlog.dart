import 'dart:io';
import 'package:flutter/material.dart';
import 'package:quicknote/password/modelspassword/password.dart';
import 'package:quicknote/password/utilities/database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quicknote/screen/password.dart';

class passwordPage extends StatefulWidget {
  Password password;

  passwordPage(this.password);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _passwordPageState(password);
  }
}

class _passwordPageState extends State<passwordPage> {
  Password password;
  SQL_Helper helper = new SQL_Helper();

  _passwordPageState(this.password);

  TextEditingController passwordController = new TextEditingController();
  String _enteredMessage = "";

  bool _obscureText = true;

  void toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // TODO: implement build
    return Scaffold(
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
                obscureText: _obscureText,
                controller: passwordController,
                onChanged: (value) {
                  password.password = value;
                  _enteredMessage = value;
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
                  _enteredMessage.trim().isEmpty ? null : _save();
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
          ],
        ),
      ),
    );
  }

  void goBack() {
    Navigator.pop(context, true);
  }

  void _save() async {
    getFilePath();
    passwordController.clear();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => passwords()),
    );

    int result;
    if (password.id == null) {
      result = await helper.insertPassword(password);
    } else {
      result = await helper.updatePassword(password);
    }
  }

  void getFilePath() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + '/passwords.db';
    Directory d = Directory(path);
    print(path);
    print(path);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
      print(d);
    }
  }
}
