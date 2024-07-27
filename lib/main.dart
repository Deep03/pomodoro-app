// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, non_constant_identifier_names, prefer_final_fields

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
Future<String> loadAsset() async {
  return await rootBundle.loadString('assets/config.json');
}

var pomodoro = 25;
var short_break = 5;
var long_break = 15;

String pomodoro_time = "25:00";
String short_break_time = "5:00";
String long_break_time = "10:00";

List<String> times = [pomodoro_time, short_break_time, long_break_time];
List<String> _options = ['Pomodoro $pomodoro mins', 'Short Break $short_break mins', 'Long Break $long_break mins'];
int _selectedIndex = 0;


void main() {
  runApp(PomodoroApp());
}
final GlobalKey<_TimeScreenState> _timeScreenKey = GlobalKey<_TimeScreenState>();

class PomodoroApp extends StatelessWidget {
  PomodoroApp({super.key});
  // final GlobalKey<_TimeScreenState> _timeScreenKey = GlobalKey<_TimeScreenState>();


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 226, 138),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 255, 226, 138),
          actions: [
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 50),
            TimeScreen(key: _timeScreenKey),
            SizedBox(height: 150),
            TimerOptionsStack(),
            SizedBox(height: 100),
            cancelTimer(onPressed: () {_timeScreenKey.currentState?._resetTimer();})
          ],
        ),
      ),
    );
  }
}


class TimeScreen extends StatefulWidget {
  const TimeScreen({super.key});  // Ensure the constructor can accept the key
  @override
  // ignore: no_logic_in_create_state, library_private_types_in_public_api
  _TimeScreenState createState() => _TimeScreenState(current_selected_time: pomodoro_time);
}

class _TimeScreenState extends State<TimeScreen> {
  Timer _timer = Timer(Duration(seconds: 0), () {});

  String current_selected_time;
  _TimeScreenState({required this.current_selected_time});

  bool isPaused = true;
  int totalSeconds = 0;

  @override
  void initState() {
    super.initState();
    totalSeconds = _parseTimeString(current_selected_time);
  }

  int _parseTimeString(String time) {
    final parts = time.split(":");
    final minutes = int.parse(parts[0]);
    final seconds = int.parse(parts[1]);
    return (minutes * 60) + seconds;
  }

  void _resetTimer() {
    print("Resetting timer");
    setState(() {
      isPaused = true;
      totalSeconds = _parseTimeString(times[_selectedIndex]);
      current_selected_time = _formatTime(totalSeconds);
    });
  }
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isPaused && totalSeconds > 0) {
        setState(() {
          totalSeconds--;
          current_selected_time = _formatTime(totalSeconds);
        });
      } else if (totalSeconds <= 0) {
        _timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
    if (!isPaused) {
      if (!_timer.isActive) {
        _startTimer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TimerClock(pomodoroTime: current_selected_time),
          SizedBox(height: 150),
          PlayPauseButton(
            isPaused: isPaused,
            onPressed: _togglePause,
          ),
        ],
      ),
    );
  }
}

class TimerClock extends StatelessWidget {
  String pomodoroTime;

  TimerClock({super.key, required this.pomodoroTime});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          pomodoroTime,
          style: TextStyle(
            fontSize: 80,
            fontFamily: GoogleFonts.audiowide().fontFamily,
          ),
        ),
      ],
    );
  }
}

class cancelTimer extends StatelessWidget {
  final VoidCallback onPressed;

  cancelTimer({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(onPressed: onPressed, icon: Icon(Icons.refresh), iconSize: 40,),
      ],
    );
  }
}

class PlayPauseButton extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onPressed;

  PlayPauseButton({super.key, required this.isPaused, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromARGB(255, 107, 84, 14),
        ),
        padding: EdgeInsets.all(16),
        child: Icon(
          isPaused ? Icons.play_arrow : Icons.pause,
          size: 40,
          color: Color.fromARGB(255, 255, 226, 138),
        ),
      ),
    );
  }
}

class TimerOptionsStack extends StatefulWidget {
  const TimerOptionsStack({super.key});

  @override
  _TimerOptionsStackState createState() => _TimerOptionsStackState();
}

class _TimerOptionsStackState extends State<TimerOptionsStack> {
  
  // int _selectedIndex = 0;

  // List<String> _options = ['Pomodoro $pomodoro mins', 'Short Break $short_break mins', 'Long Break $long_break mins'];

  void _cycleOptions() {
    setState(() {
      _selectedIndex = (_selectedIndex + 1) % _options.length;
      _timeScreenKey.currentState?._resetTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _cycleOptions, // Handle tap to cycle through options
      child: Stack(
        children: [
          Container(
            color: Colors.transparent,
            height: 10, // Adjust height as needed
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 40, // Adjust height as needed
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 226, 138),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  _options[_selectedIndex],
                  style: TextStyle(fontSize: 20, fontFamily: GoogleFonts.audiowide().fontFamily),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 65, top: 10),
              child: Icon(Icons.unfold_more, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

