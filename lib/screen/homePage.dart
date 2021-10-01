import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quicknote/screen/note/utils/database_helper.dart';
import 'package:quicknote/pages.dart';
import 'package:quicknote/screen/sidemenu.dart';
import 'package:quicknote/todolist/model/todolist.dart';
import 'package:quicknote/todolist/screens/add_task_screen.dart';
import 'package:quicknote/todolist/utilities/database_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

import 'note/models/note.dart';
import 'note/screens/note_detail.dart';

class homePage extends StatefulWidget {
  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  Future<List<Task>> _taskList;
  final DateFormat _dateFormat = DateFormat('MMM dd,yyyy');

  AudioPlayer advancedPlayer = AudioPlayer();
  Duration _duration = new Duration();
  Duration _position = new Duration();

  DatabaseHelpers databaseHelper = DatabaseHelpers();
  List<Note> noteList;
  int count = 0;

  var scaffoldKey = GlobalKey<ScaffoldState>();

  PermissionStatus permissions;

  void getPermission() async {
    permissions = await Permission.microphone.request();
    permissions = await Permission.storage.request();
    permissions = await Permission.camera.request();
  }

  @override
  void initState() {
    super.initState();
    getPermission();
  }

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }
    _updateTaskList();

    return Scaffold(
      key: scaffoldKey,
      drawer: NavDrawer(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Container(
              child: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => scaffoldKey.currentState.openDrawer(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                child: Text("Hallo", style: TextStyle(fontSize: 20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 10),
              child: Container(
                child: Text("Welcome back.",
                    style: TextStyle(fontSize: 10, color: Colors.grey)),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 4,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.lightBlue[50],
                          border: Border.all(color: Colors.black38, width: 2)),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("All Notes",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            Expanded(child: getNoteListView())
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 4,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.lightBlue[50],
                          border: Border.all(color: Colors.black38, width: 2)),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("All Records",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            Expanded(child: viewFiles())
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 4,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.lightBlue[50],
                          border: Border.all(color: Colors.black38, width: 2)),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("All Photos",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            Expanded(child: viewPhotos())
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 4,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.lightBlue[50],
                          border: Border.all(color: Colors.black38, width: 2)),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("All To do list",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            Expanded(child: getToDoList())
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListView getNoteListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subtitle1;

    return count != 0
        ? ListView.builder(
            itemCount: count,
            itemBuilder: (BuildContext context, int position) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      getPriorityColor(this.noteList[position].priority),
                  child: getPriorityIcon(this.noteList[position].priority),
                ),
                title: Text(this.noteList[position].title,
                    style: TextStyle(color: Colors.black)),
                subtitle: Text(this.noteList[position].date),
                trailing: GestureDetector(
                  child: Icon(Icons.delete, color: Colors.black),
                  onTap: () {
                    _delete(context, noteList[position]);
                  },
                ),
                onTap: () {
                  debugPrint("ListTile Tapped");
                  navigateToDetail(this.noteList[position], 'Edit Note');
                },
              );
            },
          )
        : ListView.builder(
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                child: Center(
                  child: Text("No Note", style: TextStyle(color: Colors.black)),
                ),
              );
            },
          );
    ;
  }

  // Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;

      default:
        return Colors.yellow;
    }
  }

  // Returns the priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;

      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  ListView viewFiles() {
    Directory dir = Directory(
        '/storage/emulated/0/Android/data/com.xcodeteam.quicknote/files/record');
    List<FileSystemEntity> _files;
    List<FileSystemEntity> _songs = [];
    if (dir.existsSync()) {
      _files = dir.listSync(recursive: true, followLinks: false);
      for (FileSystemEntity entity in _files) {
        String path = entity.path;
        if (path.endsWith('.mp3')) {
          _songs.add(entity);
        }
      }
    }

    if (_songs.length != 0) {
      return ListView.builder(
          itemCount: _songs.length,
          // ignore: missing_return
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(_songs[index].path.split("/").last,
                  style: TextStyle(color: Colors.black)),
              trailing: FlatButton(
                child: Icon(Icons.delete, color: Colors.black),
                onPressed: () {
                  Directory dir = Directory(_songs[index].path);
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
                            content: Text("Do you need delete this song"),
                            actions: [
                              Center(
                                child: FlatButton(
                                  child: Text("Yes"),
                                  onPressed: () {
                                    dir.deleteSync(recursive: true);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => page(0)),
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
                          advancedPlayer.stop();
                        },
                        child: AlertDialog(
                          title: Text(_songs[index].path.split("/").last),
                          content: PlayerWidget(song: _songs[index].path),
                          actions: [
                            Center(
                              child: FlatButton(
                                child: Text("Cancel"),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                  advancedPlayer.stop();
                                },
                              ),
                            )
                          ],
                        ),
                      );
                    });
              },
            );
          });
    } else {
      return ListView.builder(
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: Center(
              child: Text("No Record", style: TextStyle(color: Colors.black)),
            ),
          );
        },
      );
    }
  }

  ListView viewPhotos() {
    Directory dir = Directory(
        "/storage/emulated/0/Android/data/com.xcodeteam.quicknote/files/photo");
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
                child: Icon(Icons.delete, color: Colors.black),
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
                                          builder: (context) => page(0)),
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
              title: Text(_photo[index].path.split("/").last,
                  style: TextStyle(color: Colors.black)),
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
              child: Text("No Photo", style: TextStyle(color: Colors.black)),
            ),
          );
        },
      );
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
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
                  color: Colors.black,
                  fontSize: 18,
                  decoration: task.status == 0
                      ? TextDecoration.none
                      : TextDecoration.lineThrough),
            ),
            subtitle: Text('${_dateFormat.format(task.date)} ${task.priority}',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    decoration: task.status == 0
                        ? TextDecoration.none
                        : TextDecoration.lineThrough)),
            trailing: Container(
              height: 20,
              width: 20,
              color: Colors.blue,
              child: Checkbox(
                  onChanged: (value) {
                    task.status = value ? 1 : 0;
                    DatabaseHelper.instance.updateTask(task);
                    _updateTaskList();
                    print(value);
                  },
                  activeColor: Colors.black,
                  value: task.status == 1 ? true : false),
            ),
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

  FutureBuilder getToDoList() {
    return FutureBuilder(
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

          return snapshot.data.length != 0
              ? ListView.builder(
                  itemCount: 1 + snapshot.data.length,
                  itemBuilder: (BuildContext context, int i) {
                    if (i == 0) {
                      return SizedBox(
                        height: 1,
                      );
                    }
                    return _buildTask(snapshot.data[i - 1]);
                  },
                )
              : ListView.builder(
                  itemCount: 1 + snapshot.data.length,
                  itemBuilder: (BuildContext context, int i) {
                    return Container(
                      child: Center(
                        child: Text("No To Do List",
                            style: TextStyle(color: Colors.black)),
                      ),
                    );
                  },
                );
        });
  }
}

enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }

class PlayerWidget extends StatefulWidget {
  final String song;

  PlayerWidget({Key key, @required this.song}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState(song);
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  String song;

  AudioPlayer _audioPlayer;
  AudioPlayerState _audioPlayerState;
  Duration _duration;
  Duration _position;

  PlayerState _playerState = PlayerState.stopped;
  PlayingRouteState _playingRouteState = PlayingRouteState.speakers;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;
  StreamSubscription<PlayerControlCommand> _playerControlCommandSubscription;

  get _isPlaying => _playerState == PlayerState.playing;

  get _isPaused => _playerState == PlayerState.paused;

  get _durationText => _duration?.toString()?.split('.')?.first ?? '';

  get _positionText => _position?.toString()?.split('.')?.first ?? '';

  get _isPlayingThroughEarpiece =>
      _playingRouteState == PlayingRouteState.earpiece;

  _PlayerWidgetState(this.song);

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _playerControlCommandSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                key: Key('play_button'),
                onPressed: _isPlaying ? null : () => _play(),
                iconSize: 32.0,
                icon: Icon(Icons.play_arrow),
                color: Colors.cyan,
              ),
              IconButton(
                key: Key('pause_button'),
                onPressed: _isPlaying ? () => _pause() : null,
                iconSize: 32.0,
                icon: Icon(Icons.pause),
                color: Colors.cyan,
              ),
              IconButton(
                key: Key('stop_button'),
                onPressed: _isPlaying || _isPaused ? () => _stop() : null,
                iconSize: 32.0,
                icon: Icon(Icons.stop),
                color: Colors.cyan,
              ),
            ],
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Stack(
                  children: [
                    Slider(
                      onChanged: (v) {
                        final Position = v * _duration.inMilliseconds;
                        _audioPlayer
                            .seek(Duration(milliseconds: Position.round()));
                      },
                      value: (_position != null &&
                              _duration != null &&
                              _position.inMilliseconds > 0 &&
                              _position.inMilliseconds <
                                  _duration.inMilliseconds)
                          ? _position.inMilliseconds / _duration.inMilliseconds
                          : 0.0,
                    ),
                  ],
                ),
              ),
              Text(
                _position != null
                    ? '${_positionText ?? ''} / ${_durationText ?? ''}'
                    : _duration != null
                        ? _durationText
                        : '',
                style: TextStyle(fontSize: 24.0),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer();

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);

      // TODO implemented for iOS, waiting for android impl
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        // (Optional) listen for notification updates in the background
        _audioPlayer.startHeadlessService();

        // set at least title to see the notification bar on ios.
        _audioPlayer.setNotification(
          title: 'App Name',
          artist: 'Artist or blank',
          albumTitle: 'Name or blank',
          imageUrl: 'url or blank',
          // forwardSkipInterval: const Duration(seconds: 30), // default is 30s
          // backwardSkipInterval: const Duration(seconds: 30), // default is 30s
          duration: duration,
          elapsedTime: Duration(seconds: 0),
          hasNextTrack: true,
          hasPreviousTrack: false,
        );
      }
    });

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              _position = p;
            }));

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        _position = _duration;
      });
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    });

    _playerControlCommandSubscription =
        _audioPlayer.onPlayerCommand.listen((command) {
      print('command');
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _audioPlayerState = state;
      });
    });

    _audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _audioPlayerState = state);
    });

    _playingRouteState = PlayingRouteState.speakers;
  }

  Future<int> _play() async {
    final playPosition = (_position != null &&
            _duration != null &&
            _position.inMilliseconds > 0 &&
            _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    final result = await _audioPlayer.play(song, position: playPosition);
    if (result == 1) setState(() => _playerState = PlayerState.playing);

    // default playback rate is 1.0
    // this should be called after _audioPlayer.play() or _audioPlayer.resume()
    // this can also be called everytime the user wants to change playback rate in the UI
    _audioPlayer.setPlaybackRate(playbackRate: 1.0);

    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) setState(() => _playerState = PlayerState.paused);
    return result;
  }

  Future<int> _earpieceOrSpeakersToggle() async {
    final result = await _audioPlayer.earpieceOrSpeakersToggle();
    if (result == 1)
      setState(() => _playingRouteState =
          _playingRouteState == PlayingRouteState.speakers
              ? PlayingRouteState.earpiece
              : PlayingRouteState.speakers);
    return result;
  }

  Future<int> _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration();
      });
    }
    return result;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
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
      appBar: AppBar(
        title: Text(
          "Photo",
        ),
        centerTitle: true,
      ),
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
                                              builder: (context) => page(0)),
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
