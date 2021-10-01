import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quicknote/pages.dart';
import 'package:quicknote/screen/oldPassword.dart';

class startApp extends StatefulWidget{
  _startApp createState() => _startApp();
}

class _startApp extends State<startApp>{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Directory dir = Directory(
        '/data/user/0/com.xcodeteam.quicknote/app_flutter/passwords.db');
    Future.delayed(Duration(seconds: 5), (){
      Navigator.push(context, MaterialPageRoute(builder: (context) => dir.existsSync() ? oldPasswordPage() : page(0)));
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/start.png", width: 150, height: 150),
                    Text(
                      "Quick Note",
                      style: TextStyle(fontSize: 30, fontFamily: "Source Sans Pro"),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "By X-Code Team",
                      style: TextStyle(fontSize: 20, fontFamily: "Source Sans Pro"),
                    ),
                    Text(
                        "2020",
                      style: TextStyle(fontSize: 15, fontFamily: "Source Sans Pro"),
                    ),
                    SizedBox(
                      height: 25,
                    )
                  ],
                ),
              ],
            ),
          ),
    );
  }

}