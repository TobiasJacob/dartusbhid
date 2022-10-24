import 'package:flutter/material.dart';
import 'dart:async';

import 'package:dartusbhid/dartusbhid.dart' as dartusbhid;
import 'package:dartusbhid/enumerate.dart';

void printDevices() async {
  var devices = await enumerateDevices(22352, 1155);
  for (var device in devices) {
    print(device.manufacturerString);
    print(device.productString);
    print(device.productId);
    print(device.vendorId);
  }
  var openDevice = await devices[0].open();
  print(devices[0].manufacturerString);
  for (var i = 0; i < 10; i++) {
    print(await openDevice.readReport());
  }
  await openDevice.close();
  print(devices[0]);
}

void main() {
  printDevices();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
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
                const Text(
                  'Hello world',
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
