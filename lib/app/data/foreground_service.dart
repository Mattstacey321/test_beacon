import 'dart:async';

import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_foreground_plugin/flutter_foreground_plugin.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

class ForegroundSevice {
  ForegroundSevice(
    StreamSubscription<RangingResult>? beaconRanging,
    BehaviorSubject<List<Beacon>> streamBeacon,
    FlutterLocalNotificationsPlugin notificationsPlugin,
  ) {
    flutterLocalNotificationsPlugin = notificationsPlugin;
    _streamRanging = beaconRanging;
    _streamBeacon = streamBeacon;
  }

  static late StreamSubscription<RangingResult>? _streamRanging;
  static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static late BehaviorSubject<List<Beacon>> _streamBeacon;

  void startForeground() async {
    /*await FlutterForegroundServicePlugin.startPeriodicTask(
      periodicTaskFun: _task,
      period: const Duration(seconds: 10),
    );*/
    await flutterBeacon.openBluetoothSettings;
    await FlutterForegroundPlugin.setServiceMethodInterval(seconds: 5);
    await FlutterForegroundPlugin().setServiceMethod(_task);
    await FlutterForegroundPlugin.startForegroundService(
      holdWakeLock: false,
      onStarted: () {
        print("Foreground on Started");
      },
      onStopped: () {
        print("Foreground on Stopped");
      },
      chronometer: true,
      title: "Flutter Foreground Service",
      content: "This is Content",
      iconName: "ic_launcher",
      subtext: "Flutter Beacon",
    );
  }

  static void _task() {
    final regionBeacons = <Region, List<Beacon>>{};
    final regions = <Region>[Region(identifier: 'com.beacon')];

    /*const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '1',
      'your channel name',
      'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
    );*/

    _streamRanging = flutterBeacon.ranging(regions).listen((RangingResult result) async {
      regionBeacons[result.region] = result.beacons;
      _streamBeacon.value.clear();
      regionBeacons.values.forEach((list) {
        _streamBeacon.sink.add(list);
      });
      // filter region beacon
      /*await flutterLocalNotificationsPlugin.show(0, 'Flutter Beacon',
              'You are near ${beacons.length} device', platformChannelSpecifics,
              payload: 'item x');*/
    });
  }

  void stopForeground() async {
    _streamRanging?.cancel();
    await FlutterForegroundPlugin.stopForegroundService();
  }
}
