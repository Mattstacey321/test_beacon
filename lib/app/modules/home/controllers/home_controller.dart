import 'dart:async';

import 'package:android_long_task/android_long_task.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:rxdart/subjects.dart';
import 'package:test_beacon/app/data/background_service.dart';
import 'package:test_beacon/app/data/foreground_service.dart';
import 'package:test_beacon/app/data/secure_storage.dart';

class HomeController extends FullLifeCycleController with FullLifeCycle {
  var bluetoothState = BluetoothState.stateOff.obs;
  var authorizationStatus = AuthorizationStatus.notDetermined.obs;
  var locationService = false.obs;

  var log = <Beacon>[].obs;

  var enableBackgroundTask = false.obs;
  var enableForegroundTask = false.obs;
  var enableNormalScan = false.obs;
  var enableBroadcast = false.obs;

  bool get bluetoothEnabled => bluetoothState.value == BluetoothState.stateOn;
  bool get authorizationStatusOk =>
      authorizationStatus.value == AuthorizationStatus.allowed ||
      authorizationStatus.value == AuthorizationStatus.always;
  bool get locationServiceEnabled => locationService.value;

  StreamSubscription<BluetoothState>? _streamBluetooth;
  StreamSubscription<RangingResult>? _streamRanging;

  final secureStorage = SecureStorage();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  late ForegroundSevice foregroundSevice;
  late BackgroundService backgroundService;

  final _streamBeacon = BehaviorSubject<List<Beacon>>.seeded([]);

  updateBluetoothState(BluetoothState state) {
    bluetoothState.value = state;
  }

  updateAuthorizationStatus(AuthorizationStatus status) {
    authorizationStatus.value = status;
  }

  updateLocationService(bool flag) {
    locationService.value = flag;
  }

  void listeningState() async {
    print('Listening to bluetooth state');
    _streamBluetooth = flutterBeacon.bluetoothStateChanged().listen((BluetoothState state) async {
      updateBluetoothState(state);
      checkAllRequirements();
    });
  }

  void checkAllRequirements() async {
    final bluetoothState = await flutterBeacon.bluetoothState;
    updateBluetoothState(bluetoothState);
    print('BLUETOOTH $bluetoothState');

    await flutterBeacon.requestAuthorization;
    final authorizationStatus = await flutterBeacon.authorizationStatus;

    updateAuthorizationStatus(authorizationStatus);
    print('AUTHORIZATION $authorizationStatus');

    final locationServiceEnabled = await flutterBeacon.checkLocationServicesIfEnabled;
    updateLocationService(locationServiceEnabled);
    print('LOCATION SERVICE $locationServiceEnabled');

    if (bluetoothEnabled && authorizationStatusOk && locationServiceEnabled) {
      print('STATE READY');
      print('SCANNING');
    }
  }

  void initScanBeacon() async {
    if (!bluetoothEnabled) await flutterBeacon.openBluetoothSettings;

    final beacons = <Beacon>[].obs;
    final regionBeacons = <Region, List<Beacon>>{};

    await flutterBeacon.initializeScanning;
    if (!authorizationStatusOk || !locationServiceEnabled || !bluetoothEnabled) {
      print('RETURNED, authorizationStatusOk=$authorizationStatusOk, '
          'locationServiceEnabled=$locationServiceEnabled, '
          'bluetoothEnabled=$bluetoothEnabled');
      return;
    }
    final regions = <Region>[Region(identifier: 'com.beacon')];

    _streamRanging = flutterBeacon.ranging(regions).listen((RangingResult result) {
      regionBeacons[result.region] = result.beacons;
      _streamBeacon.value.clear();
      regionBeacons.values.forEach((list) {
        _streamBeacon.sink.add(list);
      });
      beacons.sort(_compareParameters);
    });
  }

  int _compareParameters(Beacon a, Beacon b) {
    int compare = a.proximityUUID.compareTo(b.proximityUUID);

    if (compare == 0) {
      compare = a.major.compareTo(b.major);
    }

    if (compare == 0) {
      compare = a.minor.compareTo(b.minor);
    }

    return compare;
  }

  @override
  void onInit() {
    listeningState();
    backgroundService = BackgroundService(_streamBeacon);

    foregroundSevice = ForegroundSevice(
      _streamRanging,
      _streamBeacon,
      flutterLocalNotificationsPlugin,
    );

    super.onInit();
  }

  @override
  void onReady() {
    _initLocalNotification();
    isEnableForeground();

    ever<bool>(enableBackgroundTask, (callback) {
      if (callback) {
        _streamBeacon.listen((value) {
          print('Background $value');
          this.log.clear();
          this.log.addAll(value);
        });
      } else {
        this.log.clear();
        backgroundService.stop();
      }
    });

    ever<bool>(enableForegroundTask, (callback) async {
      if (callback) {
        secureStorage.enableForeground();
        foregroundSevice.startForeground();
        _streamBeacon.listen((value) {
          print('Foreground $value');
          if(value.isNotEmpty) this.log.clear();
          this.log.addAll(value);
        });
      } else {
        secureStorage.disableForeground();
        foregroundSevice.stopForeground();
        this.log.clear();
      }
    });

    ever<bool>(enableNormalScan, (callback) {
      if (callback) {
        initScanBeacon();
        _streamBeacon.listen((value) {
          print('Normal Scan $value');
          this.log.clear();
          this.log.addAll(value);
        });
      } else {
        _streamRanging?.cancel();
        this.log.clear();
      }
    });
    super.onReady();
  }

  @override
  void onClose() {
    _streamRanging?.cancel();
    _streamBluetooth?.cancel();
    super.onClose();
  }

  @override
  void onDetached() {
    print("detach");
  }

  @override
  void onInactive() {}

  @override
  void onPaused() {}

  @override
  void onResumed() {}

  void _initLocalNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void setForegroundTask() {
    enableForegroundTask.toggle();
  }

  void isEnableForeground() async {
    final isEnable = await secureStorage.isEnableForeground();
    print('is foreground start $isEnable');
    enableForegroundTask(isEnable);
  }
}
