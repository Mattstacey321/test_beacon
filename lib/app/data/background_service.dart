import 'dart:async';

import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:rxdart/subjects.dart';

class BackgroundService {
  BackgroundService(BehaviorSubject<List<Beacon>> streamBeacon) {
    _streamBeacon = streamBeacon;
    checkPermission();
  }
  StreamSubscription<RangingResult>? _streamRanging;
  late BehaviorSubject<List<Beacon>> _streamBeacon;

  void checkPermission() async {
    // show dialog or page to let user enable permission

    var hasPermission = await FlutterBackground.hasPermissions;

    await flutterBeacon.openBluetoothSettings;

    if (!hasPermission) {}
    try {
      final androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: "Beacon App",
        notificationText: "Beacon App running in the background",
        notificationImportance:
            AndroidNotificationImportance.Default, // Default is ic_launcher from folder mipmap
      );
      hasPermission = await FlutterBackground.initialize(androidConfig: androidConfig);
      print(hasPermission);

      start();
    } catch (e) {
      print(e);
    }
  }

  void start() async {
    final backgroundExecution = await FlutterBackground.enableBackgroundExecution();
    final regionBeacons = <Region, List<Beacon>>{};

    if (backgroundExecution) {
      final regions = <Region>[Region(identifier: 'com.beacon')];
      _streamRanging = flutterBeacon.ranging(regions).listen((RangingResult result) {
        regionBeacons[result.region] = result.beacons;
        _streamBeacon.value.clear();
        regionBeacons.values.forEach((list) {
          _streamBeacon.sink.add(list);
        });
      });

      try {} catch (err) {
        print(err);
      }
      return;
    }
  }

  void stop() async {
    _streamRanging?.cancel();
    await FlutterBackground.disableBackgroundExecution();
  }
}
