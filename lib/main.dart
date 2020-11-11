import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:wakelock/wakelock.dart';
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
  MyTime _exerciseTime;
  MyTime _restTime;
  Duration _currentTime;
  Timer _timer;
  bool _exercising = true;
  bool _stopped = true;
  bool _showingPlay = true;
  Color _backgroundColor = Color.fromRGBO(48, 48, 48, 1);
  Color _inputBordersColor = Colors.deepOrange;
  Color _textColor = Colors.white;

  Animation<Color> _greenRedAnimation;
  Animation<Color> _blackGreenAnimation;
  Animation<Color> _redBlackAnimation;
  Animation<Color> _orangeGreenAnimation;
  Animation<Color> _greenWhiteAnimation;
  Animation<Color> _redGreenAnimation;
  Animation<Color> _greenBlackAnimation;
  Animation<Color> _greenOrangeAnimation;
  Animation<Color> _whiteGreenAnimation;
  Animation<Color> _whiteOrangeAnimation;
  Animation<double> _playPauseAnimation;

  AnimationController _greenRedController;
  AnimationController _redGreenController;
  AnimationController _blackGreenController;
  AnimationController _greenBlackController;
  AnimationController _redBlackController;
  AnimationController _playPauseController;

  final _textExercisingController = TextEditingController();
  final _textRestingController = TextEditingController();
  FocusNode _restingFocusNode;
  FocusNode _exercisingFocusNode;

  AudioPlayer audioPlayer = AudioPlayer();
  static AudioCache player = AudioCache();

  void _initAnimations(){
    _greenRedController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _redGreenController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _blackGreenController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _greenBlackController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _redBlackController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _playPauseController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _greenRedAnimation = ColorTween(begin: Colors.blue, end: Color.fromRGBO(204, 0, 0, 1)).animate(_greenRedController)..addListener(() {
      setState(() {
        _backgroundColor = _greenRedAnimation.value;
      });
    });
    _redGreenAnimation = ColorTween(begin: Color.fromRGBO(204, 0, 0, 1), end: Colors.blue).animate(_redGreenController)..addListener(() {
      setState(() {
        _backgroundColor = _redGreenAnimation.value;
      });
    });
    _blackGreenAnimation = ColorTween(begin: Color.fromRGBO(48, 48, 48, 1), end: Colors.blue).animate(_blackGreenController)..addListener(() {
      setState(() {
        _backgroundColor = _blackGreenAnimation.value;
      });
    });
    _greenBlackAnimation = ColorTween(begin: Colors.blue, end: Color.fromRGBO(48, 48, 48, 1)).animate(_greenBlackController)..addListener(() {
      setState(() {
        _backgroundColor = _greenBlackAnimation.value;
      });
    });
    _redBlackAnimation = ColorTween(begin: Color.fromRGBO(204, 0, 0, 1), end: Color.fromRGBO(48, 48, 48, 1)).animate(_redBlackController)..addListener(() {
      setState(() {
        _backgroundColor = _redBlackAnimation.value;
      });
    });

    _orangeGreenAnimation = ColorTween(begin: Colors.deepOrange, end: Color.fromRGBO(0, 100, 0, 100)).animate(_blackGreenController)..addListener(() {
      setState(() {
        _inputBordersColor = _orangeGreenAnimation.value;
      });
    });
    _greenOrangeAnimation = ColorTween(begin: Color.fromRGBO(0, 100, 0, 100), end: Colors.deepOrange).animate(_greenBlackController)..addListener(() {
      setState(() {
        _inputBordersColor = _greenOrangeAnimation.value;
      });
    });
    _greenWhiteAnimation = ColorTween(begin: Color.fromRGBO(0, 100, 0, 100), end: Colors.white).animate(_greenRedController)..addListener(() {
      setState(() {
        _inputBordersColor = _greenWhiteAnimation.value;
      });
    });
    _whiteGreenAnimation = ColorTween(begin: Colors.white, end: Color.fromRGBO(0, 100, 0, 100)).animate(_redGreenController)..addListener(() {
      setState(() {
        _inputBordersColor = _whiteGreenAnimation.value;
      });
    });
    _whiteOrangeAnimation = ColorTween(begin: Colors.white, end: Colors.deepOrange).animate(_redBlackController)..addListener(() {
      setState(() {
        _inputBordersColor = _whiteOrangeAnimation.value;
      });
    });

    _playPauseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_playPauseController);
  }

  void _initFocus(){
    _restingFocusNode = FocusNode();
    _exercisingFocusNode = FocusNode();
    _restingFocusNode.addListener(_handleFocusChange);
    _exercisingFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange(){//TODO controllare inserimento posizionale
    String ex = _textExercisingController.text;
    String rest = _textRestingController.text;
    if(ex.length != 0){
      MyTime exTime = MyTime.stringTime(ex);
      if(!exTime.isNull())
        _exerciseTime = exTime;
      else if(_exerciseTime != null)
        _textExercisingController.text = _exerciseTime.toDigits();
    }
    if(rest.length != 0){
      MyTime restTime = MyTime.stringTime(rest);
      if(!restTime.isNull())
        _restTime = restTime;
      else if(_restTime != null)
        _textRestingController.text = _restTime.toDigits();
    }
  }

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initFocus();
    player.load("alarm.mp3");
  }

  @override
  void dispose() {
    super.dispose();
    _blackGreenController.dispose();
    _playPauseController.dispose();
    _greenRedController.dispose();
    _redBlackController.dispose();
    _redGreenController.dispose();
    _greenBlackController.dispose();
    _textExercisingController.dispose();
    _textRestingController.dispose();
  }

  void _buttonPressed() {
    if(_exerciseTime == null || _restTime == null) return;
    if(_showingPlay) {
      Wakelock.enable();
      _playPauseController.forward();
      _showingPlay = false;
      if(_stopped) {
        _stopped = false;
        _blackGreenController.reset();
        _blackGreenController.forward();
        _currentTime = Duration(seconds: _exerciseTime.getInSeconds());
      }
      _play();
    }
    else {
      Wakelock.disable();
      _playPauseController.reverse();
      _showingPlay=true;
      _pause();
    }
  }

  void _play(){
    setState(() {
      _display.set(0, _currentTime.inSeconds);
      _timer = Timer.periodic(TICK, _tick);
    });
  }

  void _tick(Timer _t) {
    _currentTime -= TICK;
    setState(() {
      if(_currentTime.inSeconds < 0) _timerFinished();
      else _display.set(0, _currentTime.inSeconds);
    });
  }

  void _timerFinished(){
    _timer.cancel();
    _playAlarm();
    setState(() {
      if(_exercising){
        _greenRedController.reset();
        _greenRedController.forward();
        _currentTime = Duration(seconds: _restTime.getInSeconds());
      }
      else{
        _redGreenController.reset();
        _redGreenController.forward();
        _currentTime = Duration(seconds: _exerciseTime.getInSeconds());
      }
    });
    _exercising = !_exercising;
    _play();
  }

  void _pause(){
    _timer.cancel();
  }

  void _stop(){
    if(_timer == null || _stopped) return;

    _timer.cancel();
    Wakelock.disable();

    if(_exercising){
      _greenBlackController.reset();
      _greenBlackController.forward();
    }
    else{
      _redBlackController.reset();
      _redBlackController.forward();
    }

    _stopped = true;
    _exercising = true;
    if(!_showingPlay) _playPauseController.reverse();
    _showingPlay = true;
    setState(() {
      _display.set(_exerciseTime.getMin(), _exerciseTime.getSec());
    });
  }

  void _playAlarm(){
    playLocal();
  }

  void playLocal() async {
    player.play("alarm.mp3");
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
                      controller: _textExercisingController,
                      focusNode: _exercisingFocusNode,
                      keyboardType: TextInputType.datetime,
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4)],
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
                      controller: _textRestingController,
                      focusNode: _restingFocusNode,
                      keyboardType: TextInputType.datetime,
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4)],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
              Text(
                  _exercising?"EXERCISING":"RESTING",
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
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
        customBorder: CircleBorder(),
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

  MyTime.stringTime(String inputTime){
    int min=0,sec=0;
    if(inputTime.length > 2) {
      sec = int.parse(inputTime.substring(inputTime.length-2, inputTime.length));
      min = int.parse(inputTime.substring(0,inputTime.length-2));
    }
    else
      sec = int.parse(inputTime);
    set(min,sec);
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

  bool isNull(){
    return min == 0 && sec == 0;
  }

  String toDigits() {
    String min,sec;
    if(this.min > 0) {
      min = "${this.min}";
      if(this.sec < 10) sec = "0${this.sec}";
      else sec = "${this.sec}";
    }
    else {
      min = "";
      sec = "${this.sec}";
    }
    return "$min$sec";
  }

  getInSeconds() {
    return this.sec + this.min*60;
  }
}