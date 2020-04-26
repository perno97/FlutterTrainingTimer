import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrainingTimer',
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'Training Timer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const Duration TICK = Duration(seconds: 1);

  MyTime _display = MyTime(0, 0);
  Duration _currentTime = Duration(seconds: 10);
  Timer _timer;
  bool _exercising = true;
  bool _showingPlay = true;//TODO use animation play/pause AnimatedIcon

  void _buttonPressed() {
    if(_showingPlay) _play();
    else _pause();
  }

  void _play(){
    setState(() {
      _showingPlay = false;
      _display.set(_currentTime.inMinutes, _currentTime.inSeconds);
      _timer = Timer.periodic(TICK, _tick);
    });
  }

  void _tick(Timer _t) {
    _currentTime -= TICK;
    setState(() {
      _display.set(_currentTime.inMinutes, _currentTime.inSeconds);
      if(_currentTime.inSeconds < 0) _timerFinished();
    });
  }

  void _timerFinished(){
    _timer.cancel();
    _currentTime = Duration(seconds: 10);
    _exercising = !_exercising;
  }

  void _pause(){
    _timer.cancel();

    setState(() {
      _showingPlay = true;
    });
  }

  void _stop(){
    _timer.cancel();
    _currentTime = Duration(seconds: 10);

    setState(() {
      _display = MyTime(0, 0);
      _showingPlay = true;
    });
  }

  void _stopTimer(){
    if(_timer != null) _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _display.toString(),
            ),
          ],
        ),
      ),
      floatingActionButton: InkWell(
        splashColor: Colors.black45,
        onLongPress: () {
          _stop();
        },
        child: FloatingActionButton(
          child: Icon(Icons.play_arrow),
          onPressed: _buttonPressed,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class MyTime {
  int min, sec;

  MyTime(int min, int sec){
    set(min, sec);
  }

  @override
  String toString() {
    String seconds;
    sec < 10 ? seconds = "0$sec" : seconds = "$sec";
    return "$min:$seconds";
  }

  void set(int min, int sec){
    if(sec >= 60){
      min += (sec/60) as int;
      sec = sec%60;
    }
    this.min = min;
    this.sec = sec;
  }

  int getMin(){
    return min;
  }

  int getSec(){
    return sec;
  }
}