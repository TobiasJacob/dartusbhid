import 'package:flutter/material.dart';
import 'dart:async';

import 'package:dartusbhid/dartusbhid.dart' as dartusbhid;
import 'package:dartusbhid/enumerate.dart';


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

  @override
  void initState() {
    super.initState();

    monitorDevices();
  }

  void monitorDevices() async {
    var devices = await enumerateDevices(0, 0);
    for (var device in devices) {
      print(device.manufacturerString);
      print(device.productString);
      print(device.productId);
      print(device.vendorId);
    }
    var openDevice = await devices[0].open();
    print(devices[0].manufacturerString);
    while (true) {
      var report = await openDevice.readReport();
      setState(() {
        text = report.toString();
      });
    }
    await openDevice.close();
    print(devices[0]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Packages'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  text,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
