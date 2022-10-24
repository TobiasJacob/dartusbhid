import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:dartusbhid/dartusbhid.dart';
import 'package:flutter/foundation.dart';

import 'dartusbhid_bindings_generated.dart';
import 'package:ffi/ffi.dart';

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
  final Uint8List? buffer;
  USBIsolateCommand(this.responsePort, this.command, this.buffer);
}

enum USBDeviceStatus {
  Ok,
  Fail
}

class USBIsolateResponse {
  final USBDeviceStatus status;
  final Uint8List? buffer;
  USBIsolateResponse(this.status, this.buffer);
}

class USBIsolateInit {
  final SendPort responsePort;
  final int vendorId;
  final int productId;
  final int maxBufferLength;
  USBIsolateInit(this.responsePort, this.vendorId, this.productId, this.maxBufferLength);
}

void usbIsolate(USBIsolateInit initData) {
  var mainToIsolateStream = ReceivePort();
  var dev = bindings.hid_open(initData.vendorId, initData.productId, Pointer.fromAddress(0));
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
      case USBDeviceCommand.ReadReport:
        final resultBuffer = malloc.allocate<UnsignedChar>(initData.maxBufferLength);
        final bytesRead = bindings.hid_read(dev, resultBuffer, initData.maxBufferLength);
        if (bytesRead == -1) {
          command.responsePort.send(USBIsolateResponse(USBDeviceStatus.Fail, null));
        }
        var responseBuffer = Uint8List(bytesRead);
        for (int i = 0; i < bytesRead; i++) {
          responseBuffer[i] = resultBuffer[i];
        }
        malloc.free(resultBuffer);
        command.responsePort.send(USBIsolateResponse(USBDeviceStatus.Ok, responseBuffer));
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

  Future<Uint8List> readReport() async {
    var responsePort = ReceivePort();
    commandPort.send(USBIsolateCommand(responsePort.sendPort, USBDeviceCommand.ReadReport, null));
    var resp = await responsePort.first as USBIsolateResponse;
    if (resp.status != USBDeviceStatus.Ok) {
      throw Exception("Error reading device");
    }
    return resp.buffer as Uint8List;
  }
}