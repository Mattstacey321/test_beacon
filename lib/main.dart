import 'package:android_long_task/android_long_task.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_beacon/app/data/foreground.dart';

import 'app/routes/app_pages.dart';

@pragma('vm:entry-point')
serviceMain() async {
  //make sure you add this
  WidgetsFlutterBinding.ensureInitialized();
  //if your use dependency injection you initialize them here
  //what ever dart objects you created in your app main function is not  accessible here

  //set a callback and define the code you want to execute when your  ForegroundService runs
  ServiceClient.setExecutionCallback((initialData) async {
    //you set initialData when you are calling AppClient.execute()
    //from your flutter application code and receive it here
    var serviceData = Foreground.fromJson(initialData);
    //runs your code here
    serviceData.progress = 20;
    await ServiceClient.update(serviceData);
    //run some more code
    serviceData.progress = 100;
    await ServiceClient.endExecution(serviceData);
    await ServiceClient.stopService();
  });
}

void main() {  
  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
