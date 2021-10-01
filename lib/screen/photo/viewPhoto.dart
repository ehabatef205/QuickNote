import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../pages.dart';

class cameraApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _cameraApp();
  }
}

class _cameraApp extends State<cameraApp> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => page(3)));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Photos"),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [viewFiles()],
          ),
        ),
      ),
    );
  }

  ListView viewFiles() {
    Directory dir = Directory(
        "/storage/emulated/0/Android/data/com.xcodeteam.newnote/files/photo");
    List<FileSystemEntity> _files;
    List<FileSystemEntity> _photo = [];
    if (dir.existsSync()) {
      _files = dir.listSync(recursive: true, followLinks: false);
      for (FileSystemEntity entity in _files) {
        String path = entity.path;
        if (path.endsWith('.png')) {
          _photo.add(entity);
        }
      }
    }

    if (_photo.length != 0) {
      return ListView.builder(
          itemCount: _photo.length,
          // ignore: missing_return
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(_photo[index]),
              ),
              trailing: FlatButton(
                child: Icon(Icons.delete),
                onPressed: () {
                  Directory dir = Directory(_photo[index].path);
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
                            title: Text("Delete"),
                            content: Text("Do you need delete this photo"),
                            actions: [
                              Center(
                                child: FlatButton(
                                  child: Text("Yes"),
                                  onPressed: () {
                                    dir.deleteSync(recursive: true);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => cameraApp()),
                                    );
                                  },
                                ),
                              ),
                              Center(
                                child: FlatButton(
                                  child: Text("No"),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              )
                            ],
                          ),
                        );
                      });
                },
              ),
              title: Text(_photo[index].path.split("/").last),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => viewPhoto(
                            photo: _photo[index],
                          )),
                );
              },
            );
          });
    } else {
      return ListView.builder(
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: Center(
              child: Text("No File"),
            ),
          );
        },
      );
    }
  }
}

class viewPhoto extends StatefulWidget {
  final File photo;

  viewPhoto({Key key, @required this.photo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _viewPhoto(photo);
  }
}

class _viewPhoto extends State<viewPhoto> {
  File photo;

  _viewPhoto(this.photo);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Image.file(
                photo,
                fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 60.0,
                child: Center(
                  child: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      Directory dir = Directory(photo.path);
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
                                title: Text("Delete"),
                                content: Text("Do you need delete this photo"),
                                actions: [
                                  Center(
                                    child: FlatButton(
                                      child: Text("Yes"),
                                      onPressed: () {
                                        dir.deleteSync(recursive: true);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  cameraApp()),
                                        );
                                      },
                                    ),
                                  ),
                                  Center(
                                    child: FlatButton(
                                      child: Text("No"),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                    ),
                                  )
                                ],
                              ),
                            );
                          });
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
