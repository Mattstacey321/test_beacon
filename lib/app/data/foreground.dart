import 'dart:convert';

import 'package:android_long_task/android_long_task.dart';

class Foreground extends ServiceData {
  int progress = -1;
  
  static Foreground fromJson(Map map) {
    return Foreground()..progress = map['progress'] as int;
  }

  @override
  String get notificationDescription => 'running in foreground';

  @override
  String get notificationTitle => 'Flutter Beacon';

  @override
  String toJson() {
    var jsonMap = {
      'progress': progress,
    };
    return jsonEncode(jsonMap);
  }
}
