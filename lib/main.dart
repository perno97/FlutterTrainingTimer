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
  MyTime _time = MyTime(0, 0);

  void _play() {
    setState(() {
      _time.set(1,30);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _time.toString(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _play,
        tooltip: 'Increment',
        child: Icon(Icons.play_circle_filled),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class MyTime {
  int min;
  int sec;

  MyTime(this.min,this.sec);

  @override
  String toString() {
    return "$min:$sec";
  }

  void set(min,sec){
    this.min = min;
    this.sec = sec;
  }
}