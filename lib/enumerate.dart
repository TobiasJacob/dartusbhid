import 'dart:async';
import 'dart:isolate';

import 'package:dartusbhid/usb_device.dart';

import 'conversion_helpers.dart';
import 'dartusbhid.dart' as dartusbhid;

class EnumerateDevicesMessage {
  SendPort sendPort;
  int productId;
  int vendorId;

  EnumerateDevicesMessage(this.sendPort, this.productId, this.vendorId);
}

void _enumerateDevices(EnumerateDevicesMessage msg) async {
  var devices = dartusbhid.bindings.hid_enumerate(msg.vendorId, msg.productId);
  var deviceList = toDeviceList(devices);
  dartusbhid.bindings.hid_free_enumeration(devices);
  Isolate.exit(msg.sendPort, deviceList);
}

Future<List<USBDeviceInfo>> enumerateDevices(
    int productId, int vendorId) async {
  final p = ReceivePort();
  await Isolate.spawn(_enumerateDevices,
      EnumerateDevicesMessage(p.sendPort, productId, vendorId));
  return await p.first as List<USBDeviceInfo>;
}
