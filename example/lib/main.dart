import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:daily_pedometer2/daily_pedometer2.dart';
import 'package:permission_handler/permission_handler.dart';

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Stream<StepCount> _dailyStepCountStream;
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '?', _dailySteps = '?';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void onDailyStepCount(StepCount event) {
    print(event);
    setState(() {
      _dailySteps = event.steps.toString();
    });
  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  void onDailyStepCountError(error) {
    print('onDailyStepCountError: $error');
    setState(() {
      _dailySteps = 'Daily Step Count not available';
    });
  }

  void initPlatformState() async {
    log('INITIALIZING THE STREAMS');

    if (await Permission.activityRecognition.isDenied) {
      await Permission.activityRecognition.request();
    }
    if (!await Permission.activityRecognition.isGranted) return;
    _pedestrianStatusStream = DailyPedometer2.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = DailyPedometer2.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    _dailyStepCountStream = DailyPedometer2.dailyStepCountStream;
    _dailyStepCountStream
        .listen(onDailyStepCount)
        .onError(onDailyStepCountError);

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pedometer Example'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Steps Taken',
                style: TextStyle(fontSize: 30),
              ),
              Text(
                _steps,
                style: TextStyle(fontSize: 60),
              ),
              Divider(
                height: 100,
                thickness: 0,
                color: Colors.white,
              ),
              Text(
                'Daily Steps',
                style: TextStyle(fontSize: 30),
              ),
              Text(
                _dailySteps,
                style: TextStyle(fontSize: 60),
              ),
              Divider(
                height: 100,
                thickness: 0,
                color: Colors.white,
              ),
              Text(
                'Pedestrian Status',
                style: TextStyle(fontSize: 30),
              ),
              Icon(
                _status == 'walking'
                    ? Icons.directions_walk
                    : _status == 'stopped'
                        ? Icons.accessibility_new
                        : Icons.error,
                size: 100,
              ),
              Center(
                child: Text(
                  _status,
                  style: _status == 'walking' || _status == 'stopped'
                      ? TextStyle(fontSize: 30)
                      : TextStyle(fontSize: 20, color: Colors.red),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
