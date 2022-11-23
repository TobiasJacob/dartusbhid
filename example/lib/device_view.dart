import 'package:dartusbhid/open_device.dart';
import 'package:dartusbhid/usb_device.dart';
import 'package:flutter/cupertino.dart';

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
    while (isRunning) {
      try {
        if (currentDevice?.deviceInfo != widget.deviceInfo) {
          currentDevice?.close();
          currentDevice = await widget.deviceInfo?.open();
          setState(() {
            lastReport = "No data received yet";
          });
        }
        if (currentDevice != null) {
          // Show most recent report on screen
          var newMsg = await currentDevice.readReport(30);
          if (newMsg.isNotEmpty) {
            setState(() {
              lastReport = newMsg.toString();
            });
          }
        } else {
          await Future.delayed(const Duration(milliseconds: 30));
        }
      } catch (e) {
        setState(() {
          lastReport = e.toString();
        });
      }
    }
    currentDevice?.close();
  }

  _DeviceViewState()
      : lastReport = "Not selected",
        isRunning = true;

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
    if (widget.deviceInfo == null) return Container();

    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(widget.deviceInfo.toString()), Text(lastReport)]),
    );
  }
}
