import 'package:flutter_beacon/flutter_beacon.dart';

class Broadcast {
  Future<bool> start(String uuid) async {
    try {
      if (await flutterBeacon.isBroadcasting()) stop();
      await flutterBeacon.startBroadcast(BeaconBroadcast(
        proximityUUID: uuid,
        major: 0,
        minor: 0,
      ));
      print('START BROADCASTING');
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void stop() async {
    await flutterBeacon.stopBroadcast();
    print('STOP BROADCASTING');
  }
}
