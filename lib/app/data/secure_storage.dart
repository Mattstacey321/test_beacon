import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _secureStorage = FlutterSecureStorage();
  static const FOREGROUND = 'foreground';

  Future<bool> isEnableForeground() async {
    final isEnable = await _secureStorage.read(key: FOREGROUND);
    if (isEnable == null) {
      return false;
    } else {
      return bool.fromEnvironment(isEnable);
    }
  }

  void enableForeground() {
    _secureStorage.write(key: FOREGROUND, value: 'true');
  }

  void disableForeground() {
    _secureStorage.write(key: FOREGROUND, value: 'false');
  }
}
