import 'package:flutter/material.dart';

import '../pages.dart';

class aboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _aboutPage();
  }
}

class _aboutPage extends State<aboutPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("About"),
        centerTitle: true,
      ),
      body: WillPopScope(
        // ignore: missing_return
        onWillPop: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => page(0)));
        },
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 10),
              Text("With this application \"Quick Note\", you can save all notes of all kinds, whether they are text, pictures or audio recording.", style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
              SizedBox(height: 20),
              Text("We made this easy and simple in order to suit everyone's simple use, and we hope that you like the development of our team \"X-Code Team\".", style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
              SizedBox(height: 20),
              Text("Connect Us:"),
              SizedBox(height: 10),
              Text("xcodeteam99@gmail.com", style: TextStyle(color: Colors.blue))
            ],
          ),
        ),
      ),
    );
  }
}
