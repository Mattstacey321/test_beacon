import 'package:workmanager/workmanager.dart';

class WorkerService {
  runWorker() async {
    await Workmanager()
        .registerPeriodicTask('1', 'scanBeacon', existingWorkPolicy: ExistingWorkPolicy.keep);
  }
}
