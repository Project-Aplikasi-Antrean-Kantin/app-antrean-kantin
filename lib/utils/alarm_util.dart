import 'package:flutter/services.dart';

const platform = MethodChannel('com.foodlab.pens/alarm_channel');

Future<void> triggerAlarmFromFlutter() async {
  try {
    await platform.invokeMethod('setAlarm');
  } catch (e) {
    print("Failed to trigger alarm: $e");
  }
}
