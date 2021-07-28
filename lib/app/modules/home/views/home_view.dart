import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_beacon/app/data/broadcast.dart';
import 'package:uuid/uuid.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    children: [
                      ObxValue<RxBool>(
                        (p0) => ElevatedButton(
                          onPressed: () {
                            controller.enableNormalScan(!p0.value);
                          },
                          child: Text(
                            '${p0.value == true ? 'Stop' : 'Start'} Normal Scan',
                          ),
                        ),
                        controller.enableNormalScan,
                      ),
                      ObxValue<RxBool>(
                        (p0) => ElevatedButton(
                          onPressed: () {
                            controller.enableBackgroundTask(!p0.value);
                          },
                          child: Text(
                            '${p0.value == true ? 'Stop' : 'Start'} Background',
                          ),
                        ),
                        controller.enableBackgroundTask,
                      ),
                      const SizedBox(width: 10),
                      ObxValue<RxBool>(
                        (p0) => ElevatedButton(
                          onPressed: () {
                            controller.setForegroundTask();
                          },
                          child: Text(
                            '${p0.value == true ? 'Stop' : 'Start'} Foreground',
                          ),
                        ),
                        controller.enableForegroundTask,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      ObxValue<RxBool>(
                        (p0) {
                          final textController =
                              TextEditingController(text: Uuid().v4());
                          return ElevatedButton(
                            onPressed: p0.value == true
                                ? () {
                                    //stop broadcast
                                    Broadcast().stop();
                                     ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(content: Text('Stop Broadcasting')));
                                    controller.enableBroadcast(false);
                                  }
                                : () {
                                    //start broadcast
                                    Get.defaultDialog(
                                      radius: 10,
                                      title: 'UUID',
                                      confirm: ElevatedButton(
                                        onPressed: () async {
                                          final result =
                                              await Broadcast().start(textController.value.text);
                                          if (result) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Start Broadcasting')));
                                            Get.back();
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Check your UUID')));
                                          }
                                        },
                                        child: Text('Start'),
                                      ),
                                      content: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: textController,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                    controller.enableBroadcast(true);
                                  },
                            child: Text(
                              '${p0.value == true ? 'Stop' : 'Start'} Broadcast',
                            ),
                          );
                        },
                        controller.enableBroadcast,
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Text(
                    'Log',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: controller.log.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView(
                        children: ListTile.divideTiles(
                          context: context,
                          tiles: controller.log.map(
                            (beacon) {
                              return ListTile(
                                contentPadding: EdgeInsets.all(0),
                                title: Text(
                                  beacon.proximityUUID,
                                  style: TextStyle(fontSize: 15.0),
                                ),
                                subtitle: new Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                      child: Text(
                                        'Major: ${beacon.major}\nMinor: ${beacon.minor}',
                                        style: TextStyle(fontSize: 13.0),
                                      ),
                                      flex: 1,
                                      fit: FlexFit.tight,
                                    ),
                                    Flexible(
                                      child: Text(
                                        'Accuracy: ${beacon.accuracy}m\nRSSI: ${beacon.rssi}',
                                        style: TextStyle(fontSize: 13.0),
                                      ),
                                      flex: 2,
                                      fit: FlexFit.tight,
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ).toList(),
                      ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
