import 'package:dartusbhid/usb_device.dart';
import 'package:dartusbhid_example/device_view.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:dartusbhid/enumerate.dart';

import 'device_info.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String text = "Hello world";

  USBDeviceInfo? currentDevice;
  late Future<List<USBDeviceInfo>> devices;

  @override
  void initState() {
    super.initState();
    devices = getDevices();
  }

  Future<List<USBDeviceInfo>> getDevices() async {
    var devices = await enumerateDevices(0, 0);
    // for (var device in devices) {
    //   print(device);
    // }
    return devices;
    // var openDevice = await devices[0].open();
    // print(devices[0].manufacturerString);
    // while (true) {
    //   var report = await openDevice.readReport();
    //   setState(() {
    //     text = report.toString();
    //   });
    // }
    // await openDevice.close();
    // print(devices[0]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('USB HID Report explorer'),
        ),
        body: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(10),
                color: Colors.lightBlue[50],
                width: 300,
                child: FutureBuilder<List<USBDeviceInfo>>(
                    future: devices,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<USBDeviceInfo>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: Text('Refreshing usb devices'));
                      } else {
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else {
                          return ListView.separated(
                              padding: const EdgeInsets.all(8),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (BuildContext context, int index) {
                                var device = snapshot.data![index];
                                return GestureDetector(
                                    child: DeviceInfoWidget(device),
                                    onTap: () {
                                      setState(() {
                                        currentDevice = device;
                                      });
                                    });
                              },
                              separatorBuilder: (context, index) =>
                                  const Divider());
                        }
                      }
                    })),
            DeviceView(
              deviceInfo: currentDevice,
            )
          ],
        ),
      ),
    );
  }
}
