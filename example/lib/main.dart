import 'dart:io';
import 'dart:typed_data';

import 'package:dartusbhid/usb_device.dart';
import 'package:dartusbhid_example/device_view.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:dartusbhid/enumerate.dart';

import 'device_info.dart';

void exampleComm() async {
  final devices = await enumerateDevices(22352, 1155);
  print(devices.length);
  for (final device in devices) {
    // Print device information like product name, vendor, etc.
    print(device);
  }

  final openDevice = await devices[0].open();
  // Read data without timeout (timeout: null)
  print("Waiting for first hid report");
  for (var i = 0; i < 100; i++) {
    final receivedData = await openDevice.readReport(null);
    print("receivedData");
    print(receivedData);
    print("Report ID is: ${receivedData[0]}");

    // generate list with 64 bytes
    var uint8list = Uint8List.fromList(List.generate(64, (index) => 0));
    uint8list[0] = 2;
    await openDevice.writeReport(uint8list);
    final echoData = await openDevice.readReport(null);
    print("echoData");
    print(String.fromCharCodes(echoData));
    sleep(Duration(seconds: 1));
  }
  await openDevice.close();
}

void main() {
  exampleComm();
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
