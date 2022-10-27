import 'dart:isolate';

import 'package:dartusbhid/open_device.dart';
import 'package:dartusbhid/usb_device.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class DeviceView extends StatefulWidget {
  const DeviceView({super.key, this.deviceInfo});

  final USBDeviceInfo? deviceInfo;

  @override
  State<DeviceView> createState() => _DeviceViewState();
}

class _DeviceViewState extends State<DeviceView> {
  String lastReport;
  bool isRunning;

  void _updateLoop() async {
    OpenUSBDevice? currentDevice;
    while(isRunning) {
      if (currentDevice?.deviceInfo != widget.deviceInfo) {
        currentDevice?.close();
        currentDevice = await widget.deviceInfo?.open();
        print(currentDevice?.deviceInfo.productString);
      }
      if (currentDevice != null) {
        // Show most recent report on screen
        var newMsg = await currentDevice.readReport();
        setState(() {
          lastReport = newMsg.toString();
        });
      } else {
        await Future.delayed(const Duration(milliseconds: 30));
      }
    }
    currentDevice?.close();
  }

  _DeviceViewState() : lastReport = "Not selected", isRunning = true;

  @override
  void initState() {
    super.initState();

    // Start watching the USB Device
    _updateLoop();
  }


  @override
  void dispose() {
    // Stop watching the USB Device
    isRunning = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(lastReport);
  }
}