import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrainingTimer',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.orangeAccent,
        accentColor: Colors.deepOrange,
        backgroundColor: Colors.black,
      ),
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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin{
  static const Duration TICK = Duration(seconds: 1);

  MyTime _display = MyTime(0, 0);
  Duration _currentTime = Duration(seconds: 10);
  Timer _timer;
  bool _exercising = true;
  bool _stopped = true;
  bool _showingPlay = true;//TODO use animation play/pause AnimatedIcon
  Color _backgroundColor = Colors.black;
  Color _inputBordersColor = Colors.deepOrange;
  Color _textColor = Colors.white;
  Animation<Color> _greenRedAnimation;
  Animation<Color> _blackGreenAnimation;
  Animation<Color> _redBlackAnimation;
  Animation<Color> _orangeGreenAnimation;
  Animation<Color> _greenWhiteAnimation;
  Animation<Color> _orangeWhiteAnimation;
  Animation<double> _playPauseAnimation;
  AnimationController _greenRedController;
  AnimationController _blackGreenController;
  AnimationController _redBlackController;
  AnimationController _playPauseController;


  @override
  void initState() {
    super.initState();
    _greenRedController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _blackGreenController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _redBlackController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _playPauseController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _greenRedAnimation = ColorTween(begin: Colors.green, end: Colors.red).animate(_greenRedController)..addListener(() {
      setState(() {
        _backgroundColor = _greenRedAnimation.value;
      });
    });
    _blackGreenAnimation = ColorTween(begin: Colors.black, end: Colors.green).animate(_blackGreenController)..addListener(() {
      setState(() {
        _backgroundColor = _blackGreenAnimation.value;
      });
    });
    _redBlackAnimation = ColorTween(begin: Colors.red, end: Colors.black).animate(_redBlackController)..addListener(() {
      setState(() {
        _backgroundColor = _redBlackAnimation.value;
      });
    });

    _orangeGreenAnimation = ColorTween(begin: Colors.deepOrange, end: Color.fromRGBO(0, 100, 0, 100)).animate(_blackGreenController)..addListener(() {
      setState(() {
        _inputBordersColor = _orangeGreenAnimation.value;
      });
    });
    _greenWhiteAnimation = ColorTween(begin: Color.fromRGBO(0, 100, 0, 100), end: Colors.white).animate(_greenRedController)..addListener(() {
      setState(() {
        _inputBordersColor = _greenWhiteAnimation.value;
      });
    });
    _orangeWhiteAnimation = ColorTween(begin: Colors.deepOrange, end: Colors.white).animate(_redBlackController)..addListener(() {
      setState(() {
        _inputBordersColor = _orangeWhiteAnimation.value;
      });
    });

    _playPauseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_playPauseController);
  }

  void _buttonPressed() {
    if(_showingPlay) {
      _playPauseController.forward();
      _showingPlay = false;
      if(_stopped)
        if(_exercising) _blackGreenController.forward();
      _play();
    }
    else {
      _playPauseController.reverse();
      _showingPlay=true;
      _pause();
    }
  }

  void _play(){
    setState(() {
      _display.set(_currentTime.inMinutes, _currentTime.inSeconds);
      _timer = Timer.periodic(TICK, _tick);
    });
  }

  void _tick(Timer _t) {
    _currentTime -= TICK;
    setState(() {
      if(_currentTime.inSeconds < 0) _timerFinished();
      else _display.set(_currentTime.inMinutes, _currentTime.inSeconds);
    });
  }

  void _timerFinished(){
    _timer.cancel();
    _currentTime = Duration(seconds: 10);
    _exercising = !_exercising;
    setState(() {
      _exercising?_greenRedController.reverse():_greenRedController.forward();
    });
    _play();
  }

  void _pause(){
    _timer.cancel();
  }

  void _stop(){
    _timer.cancel();
    _stopped = true;
    _exercising?_blackGreenController.reverse():_redBlackController.forward();
    _currentTime = Duration(seconds: 10);
    _exercising = true;
    if(!_showingPlay) _playPauseController.reverse();
    _showingPlay = true;

    setState(() {
      _display = MyTime(0, 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 10,right: 10,top: 70, bottom: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                          labelText: "Exercise",
                          labelStyle: TextStyle(color: _textColor),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: _inputBordersColor, width: 2.0),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: _inputBordersColor, width: 2.0),
                              borderRadius: BorderRadius.circular(10)
                          ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly],
                    ),
                  ),
                  SizedBox(width: 50),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "Rest",
                        labelStyle: TextStyle(color: _textColor),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: _inputBordersColor, width: 2.0),
                            borderRadius: BorderRadius.circular(10)
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: _inputBordersColor, width: 2.0),
                            borderRadius: BorderRadius.circular(10)
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
              Text(_exercising?"Exercising":"Resting"),
              SizedBox(height: 50),
              Text(
                _display.toString(),
                style: TextStyle(fontSize: 130),
              ),
            ],
          ),
        )
      ),
      floatingActionButton: InkWell(
        splashColor: Colors.black45,
        onLongPress: () {
          _stop();
        },
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).accentColor,
          child: AnimatedIcon(
            icon: AnimatedIcons.play_pause,
            progress: _playPauseAnimation,
          ),
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
      min += sec~/60;
      sec = sec%60;
    }
    if(min > 99)
      min = 99;

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