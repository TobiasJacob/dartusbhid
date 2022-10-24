import 'dart:isolate';

import 'package:dartusbhid/dartusbhid.dart';
import 'package:flutter/foundation.dart';

import 'dartusbhid_bindings_generated.dart';
import 'dart:ffi' as ffi;

import 'dart:async';

enum USBDeviceCommand {
  Close,
  ReadReport,
  WriteReport,
  SendFeatureReport,
  GetFeatureReport,
}

class USBIsolateCommand {
  final SendPort responsePort;
  final USBDeviceCommand command;
  final ByteData? buffer;
  USBIsolateCommand(this.responsePort, this.command, this.buffer);
}

enum USBDeviceStatus {
  Ok,
  Fail
}

class USBIsolateResponse {
  final USBDeviceStatus status;
  final ByteData? buffer;
  USBIsolateResponse(this.status, this.buffer);
}

class USBIsolateInit {
  final SendPort responsePort;
  final int vendorId;
  final int productId;
  USBIsolateInit(this.responsePort, this.vendorId, this.productId);
}

void usbIsolate(USBIsolateInit initData) {
  var mainToIsolateStream = ReceivePort();
  var dev = bindings.hid_open(initData.vendorId, initData.productId, ffi.Pointer.fromAddress(0));
  if (dev.address == 0) {
    Isolate.exit(initData.responsePort, USBIsolateResponse(USBDeviceStatus.Fail, null));
  }
  initData.responsePort.send(mainToIsolateStream.sendPort);

  mainToIsolateStream.listen((data) {
    var command = data as USBIsolateCommand;
    switch (command.command) {
      case USBDeviceCommand.Close:
        bindings.hid_close(dev);
        command.responsePort.send(USBIsolateResponse(USBDeviceStatus.Ok, null));
        break;
      default:
        Isolate.exit();
    }
  });
}

class OpenUSBDevice {
  final SendPort commandPort;

  OpenUSBDevice(this.commandPort);

  Future<void> close() async {
    var responsePort = ReceivePort();
    commandPort.send(USBIsolateCommand(responsePort.sendPort, USBDeviceCommand.Close, null));
    var resp = await responsePort.first as USBIsolateResponse;
    if (resp.status != USBDeviceStatus.Ok) {
      throw Exception("Error closing device");
    }
  }
}