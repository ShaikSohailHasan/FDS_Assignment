import 'dart:io';

import 'package:activity_recognition_flutter/activity_recognition_flutter.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(new HumanActivity());

class HumanActivity extends StatefulWidget {
  @override
  _HumanActivityState createState() => new _HumanActivityState();
}

class _HumanActivityState extends State<HumanActivity> {
  Stream<ActivityEvent> activityStream;
  ActivityEvent latestActivity = ActivityEvent.empty();
  List<ActivityEvent> _events = [];
  ActivityRecognition activityRecognition = ActivityRecognition.instance;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    if (Platform.isAndroid) {
      if (await Permission.activityRecognition.request().isGranted) {
        _trackingStarted();
      }
    }
    else {
      _trackingStarted();
    }
  }

  void _trackingStarted() {
    activityStream =
        activityRecognition.startStream(runForegroundService: true);
    activityStream.listen(activityData);
  }

  void activityData(ActivityEvent activityEvent) {
    print(activityEvent.toString());
    setState(() {
      _events.add(activityEvent);
      latestActivity = activityEvent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          backgroundColor: Color.fromRGBO(185, 22, 70,1),
          title: Center(child: const Text('Human Activity Recognition')),
        ),

        body: SafeArea(
          child: Container(
            color: Color.fromRGBO(223, 216, 202, 1),
            child: new ListView.builder(
                itemCount: _events.length,
                reverse: true,
                itemBuilder: (BuildContext context, int idx) {
                  final entry = _events[idx];
                  return ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                    tileColor: Color.fromRGBO(16, 86, 82, 1),
                    trailing: Text(entry.timeStamp.toString().substring(0, 19),style: TextStyle(
                      fontWeight: FontWeight.bold,color: Color.fromRGBO(16,86,82,1),
                    ),),
                    leading: Text(entry.type.toString().split('.').last,style: TextStyle(
                      fontWeight: FontWeight.bold,color: Color.fromRGBO(16,86,82,1),
                    ),),
                    title: Center(child: Text(entry.confidence.toString(),style: TextStyle(
                      fontWeight: FontWeight.bold,color: Color.fromRGBO(16,86,82,1),
                    ),)),
                  );
                }),
          ),
        ),
      ),
    );
  }
}