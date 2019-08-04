import 'dart:async';
import 'dart:core';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var urlText;
  bool urlOutcome = false;
  bool engineReady = true;
  bool snoozeFlag = false;
  String audioPath = 'audio/light.mp3';
  AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);

  Duration oneMin = Duration(seconds: 60);
  Timer timer;
  @override
  void initState() {
    super.initState();
    
  }

  @override
  void dispose() {
    super.dispose();
  }

  getUrlResponse(String url) {
    http.get(url).then((http.Response response) {
      if (response.body.contains('1')) {
        debugPrint('Url Response:' + response.body);
        setState(() {
          urlOutcome = true;
        });
      } else {
        debugPrint('Url Response:' + response.body);
        setState(() {
          urlOutcome = false;
        });
      }
    });
  }

  _playAudioFromCache(String path) {
    return AudioCache(fixedPlayer: audioPlayer).play(path);
  }

  _checkUrlOutcomePeriodic() {
    new Timer.periodic(oneMin, (timer) {
      if (engineReady ) { 
        getUrlResponse(urlText);
      if ( !snoozeFlag && urlOutcome) {
        setState(() {
          _playAudioFromCache(audioPath);
        });
      }
    } else {
      timer.cancel();
    }
    });
  }

  _buildUrlField() {
    return Container(
        height: 50,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white70, borderRadius: BorderRadius.circular(10)),
        child: TextField(
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration.collapsed(
              hintText: 'Enter the web address',
              hintStyle: TextStyle(color: Colors.black54)),
          onSubmitted: (text) {
            urlText = text;
            debugPrint('Url entered:' + urlText);
           _checkUrlOutcomePeriodic();
          },
        ));
  }

  _buildStopEngine() {
    return MaterialButton(
      child: Text('Reset',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      onPressed: () {
        setState(() {
        engineReady = false;
        urlOutcome = false;
        snoozeFlag = false;
        audioPath = 'audio/light.mp3'; 
        });
      },
    );
  }

  _buildAudioButton(BuildContext context) {
    return RaisedButton(
      child: Text('Audio'),
      padding: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: () {
        _buildBottomSheet(context);
      },
    );
  }

  _buildBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                ListTile(
                    leading: new IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () {
                        _playAudioFromCache('audio/light.mp3');
                      },
                    ),
                    title: new Text('light'),
                    onTap: () {
                      setState(() {
                        audioPath = 'audio/light.mp3';
                      });
                      debugPrint('Current audio path:' + audioPath);
                      Navigator.pop(context);
                    }),
                ListTile(
                    leading: new IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () {
                        _playAudioFromCache('audio/plucky.mp3');
                      },
                    ),
                    title: new Text('plucky'),
                    onTap: () {
                      setState(() {
                        audioPath = 'audio/plucky.mp3';
                      });
                      debugPrint('Current audio path:' + audioPath);
                      Navigator.pop(context);
                    }),
                ListTile(
                    leading: new IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () {
                        _playAudioFromCache('audio/to-the-point.mp3');
                      },
                    ),
                    title: new Text('to-the-point'),
                    onTap: () {
                      setState(() {
                        audioPath = 'audio/to-the-point.mp3';
                      });
                      debugPrint('Current audio path:' + audioPath);
                      Navigator.pop(context);
                    }),
              ],
            ),
          );
        });
  }

  _buidSnoozeButton() {
    //Wireframe(Mock Screen) shows a button but RadioBUtton would work betteron the given scenerio.
    //Tried to create a Radio button with RaisedButton.
    return RaisedButton(
      padding: EdgeInsets.all(8),
      child: snoozeFlag ? Text('Snooze ON') : Text('Snooze OFF'),
      color: snoozeFlag ? Colors.blueGrey : Colors.blue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: () {
        setState(() {
          snoozeFlag = snoozeFlag ? false : true;
        });
        debugPrint('Snooze is turned on :' + snoozeFlag.toString());
      },
    );
  }

  _buildDropDown() {
    return DropdownButton<bool>(
      items: [
        DropdownMenuItem(
          value: true,
          child: Text(
            "Enabled",
            style: TextStyle(color: Colors.white),
          ),
        ),
        DropdownMenuItem(
          value: false,
          child: Text(
            "Disabled",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          engineReady = value;
        });
        debugPrint(
            'Eabled/Disabled from by dropdown:' + engineReady.toString());
      },
      value: engineReady,
      hint: Text(
        engineReady ? 'Enabled' : 'Disabled',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'WebAlert',
          style: TextStyle(fontSize: 30),
        ),
      ),
      body: ListView(
        children: <Widget>[
          _buildUrlField(),
          SizedBox(
            height: 5,
          ),
          // _buidUrlButton(),
          Container(
            height: 80,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildAudioButton(context),
                SizedBox(width: 10),
                _buildDropDown(),
                SizedBox(width: 10),
                _buidSnoozeButton(),
              ],
            ),
          ),
          _buildStopEngine(),
        ],
      ),
    );
  }
}
