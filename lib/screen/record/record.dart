import 'dart:io';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quicknote/pages.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class record extends StatefulWidget {
  @override
  _record createState() => _record();
}

class _record extends State<record> {
  AudioPlayer advancedPlayer = AudioPlayer();
  Duration _duration = new Duration();
  Duration _position = new Duration();
  PermissionStatus permissions;
  bool isComplete = false;
  String statusText = "";
  String recordFilePath;
  AudioCache audioCache;
  int count = 0;
  int i = 0;

  void getPermission() async {
    permissions = await Permission.microphone.request();
    permissions = await Permission.storage.request();
  }

  void initPlayer() {
    audioCache = new AudioCache(fixedPlayer: advancedPlayer);

    advancedPlayer.durationHandler = (d) => setState(() {
          _duration = d;
        });

    advancedPlayer.positionHandler = (p) => setState(() {
          _position = p;
        });
  }

  void seekToSecond(millisecond) {
    Duration newDuration = Duration(milliseconds: millisecond);

    advancedPlayer.seek(newDuration);
  }

  void printer(double value) {
    printer(value);
  }

  @override
  void initState() {
    super.initState();
    getPermission();
    initPlayer();
  }

  DateTime backbutton;

  TextEditingController nameController = TextEditingController();

  String nameRecord = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Record'),
          centerTitle: true,
          leading: Container(),
        ),
        body: SafeArea(
          child: Column(
            children: [Expanded(child: viewFiles()), getBottoms()],
          ),
        ),
      );
  }

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  void startRecord() async {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      statusText = "Recording...";
      recordFilePath = await getFilePath();
      isComplete = false;
      RecordMp3.instance.start(recordFilePath, (type) {
        statusText = "Record error--->$type";
        setState(() {});
      });
    } else {
      statusText = "No microphone permission";
    }
    setState(() {});
  }

  void pauseRecord() {
    if (RecordMp3.instance.status == RecordStatus.PAUSE) {
      bool s = RecordMp3.instance.resume();
      if (s) {
        statusText = "Recording...";
        setState(() {});
      }
    } else {
      bool s = RecordMp3.instance.pause();
      if (s) {
        statusText = "Recording pause...";
        setState(() {});
      }
    }
  }

  void resumeRecord() {
    bool s = RecordMp3.instance.resume();
    if (s) {
      statusText = "Recording...";
      setState(() {});
    }
  }

  void stopRecord() {
    bool s = RecordMp3.instance.stop();
    if (s) {
      statusText = "Record complete";
      isComplete = true;
      setState(() {});
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
                title: Text("Name of record"),
                content: TextField(
                  controller: nameController,
                  onChanged: (value) {
                    setState(() {
                      nameRecord = value;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: 'Name of record',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
                actions: [
                  Center(
                    child: FlatButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => page(2)));
                      },
                    ),
                  ),
                  Center(
                    child: FlatButton(
                      child: Text("Save"),
                      onPressed: () {
                        if (nameRecord == "") {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => page(2)));
                        } else {
                          newName(nameRecord);
                          nameRecord = "";
                          nameController.clear();
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => page(2)));
                        }
                      },
                    ),
                  )
                ],
              ),
            );
          });
    }
  }

  Future<String> newName(String nameRecord) async {
    String name = "";
    Directory storageDirectory = await getExternalStorageDirectory();
    String sdPath = storageDirectory.path + "/record";
    File d = File(recordFilePath);
    if (d.existsSync()) {
      d.rename(sdPath + "/" + nameRecord + ".mp3");
      name = d.path;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => page(2)));
    print(name);

    return name;
  }

  Future<String> getFilePath() async {
    SharedPreferences inst = await SharedPreferences.getInstance();
    count = inst.getInt("test") ?? 0;
    count++;
    inst.setInt("test", count);
    Directory storageDirectory = await getExternalStorageDirectory();
    String sdPath = storageDirectory.path + "/record";
    Directory d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }

    return sdPath + "/test_$count.mp3";
  }

  BottomAppBar getBottoms() {
    if (i == 0) {
      return BottomAppBar(
        child: Row(children: <Widget>[
          Expanded(
            child: FlatButton(
              child: Icon(Icons.play_arrow),
              onPressed: () {
                startRecord();
                setState(() {
                  i = 2;
                });
              },
            ),
          )
        ]),
      );
    } else {
      return BottomAppBar(
        child: Row(children: <Widget>[
          Expanded(
            child: FlatButton(
              child: Icon(RecordMp3.instance.status == RecordStatus.PAUSE
                  ? Icons.play_arrow
                  : Icons.pause),
              onPressed: () {
                pauseRecord();
              },
            ),
          ),
          Expanded(
              child: FlatButton(
            child: Icon(Icons.stop),
            onPressed: () {
              stopRecord();
              setState(() {
                i = 0;
              });
            },
          ))
        ]),
      );
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
              title: Text(_songs[index].path.split("/").last),
              trailing: FlatButton(
                child: Icon(Icons.delete),
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
                                          builder: (context) => page(2)),
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
              child: Text("No File"),
            ),
          );
        },
      );
    }
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
