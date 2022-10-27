import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:dartusbhid/conversion_helpers.dart';
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
  final String? errorMsg;
  USBIsolateResponse(this.status, this.buffer, this.errorMsg);
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
    var errorMsg = toString(bindings.hid_error(Pointer.fromAddress(0)));
    Isolate.exit(initData.responsePort, USBIsolateResponse(USBDeviceStatus.Fail, null, errorMsg));
  }
  initData.responsePort.send(mainToIsolateStream.sendPort);

  mainToIsolateStream.listen((data) {
    var command = data as USBIsolateCommand;
    switch (command.command) {
      case USBDeviceCommand.Close:
        bindings.hid_close(dev);
        command.responsePort.send(USBIsolateResponse(USBDeviceStatus.Ok, null, null));
        break;
      case USBDeviceCommand.ReadReport:
        _readReport(initData, dev, command);
        break;
      case USBDeviceCommand.WriteReport:
        _writeReport(initData, dev, command);
        break;
      default:
        Isolate.exit();
    }
  });
}

void _writeReport(USBIsolateInit initData, Pointer<hid_device> dev, USBIsolateCommand command) {
  if (command.buffer == null) {
    var errorMsg = toString(bindings.hid_error(dev));
    command.responsePort.send(USBIsolateResponse(USBDeviceStatus.Fail, null, errorMsg));
    return;
  }
  final writeBuffer = malloc.allocate<UnsignedChar>(command.buffer!.length);
  for (int i = 0; i < command.buffer!.length; i++) {
    writeBuffer[i] = command.buffer![i];
  }
  final bytesWritten = bindings.hid_write(dev, writeBuffer, command.buffer!.length);
  malloc.free(writeBuffer);
  if(bytesWritten != command.buffer!.length) {
    var errorMsg = toString(bindings.hid_error(dev));
    command.responsePort.send(USBIsolateResponse(USBDeviceStatus.Fail, null, errorMsg));
    return;
  }
  command.responsePort.send(USBIsolateResponse(USBDeviceStatus.Ok, null, null));
}

void _readReport(USBIsolateInit initData, Pointer<hid_device> dev, USBIsolateCommand command) {
  final resultBuffer = malloc.allocate<UnsignedChar>(initData.maxBufferLength);
  final bytesRead = bindings.hid_read(dev, resultBuffer, initData.maxBufferLength);
  if (bytesRead == -1) {
    var errorMsg = toString(bindings.hid_error(dev));
    command.responsePort.send(USBIsolateResponse(USBDeviceStatus.Fail, null, errorMsg));
    return;
  }
  var responseBuffer = Uint8List(bytesRead);
  for (int i = 0; i < bytesRead; i++) {
    responseBuffer[i] = resultBuffer[i];
  }
  malloc.free(resultBuffer);
  command.responsePort.send(USBIsolateResponse(USBDeviceStatus.Ok, responseBuffer, null));
}

class OpenUSBDevice {
  final SendPort commandPort;

  OpenUSBDevice(this.commandPort);

  /// Closes the hid device
  Future<void> close() async {
    var responsePort = ReceivePort();
    commandPort.send(USBIsolateCommand(responsePort.sendPort, USBDeviceCommand.Close, null));
    var resp = await responsePort.first as USBIsolateResponse;
    if (resp.status != USBDeviceStatus.Ok) {
      throw Exception("Error closing device: ${resp.errorMsg}");
    }
  }

  /// Read an Input report from a HID device.
  ///
  /// Input reports are returned
  /// to the host through the INTERRUPT IN endpoint. The first byte will
  /// contain the Report number if the device uses numbered reports.
  ///
  /// This function returns the actual bytes read or throws an error.
  Future<Uint8List> readReport() async {
    var responsePort = ReceivePort();
    commandPort.send(USBIsolateCommand(responsePort.sendPort, USBDeviceCommand.ReadReport, null));
    var resp = await responsePort.first as USBIsolateResponse;
    if (resp.status != USBDeviceStatus.Ok) {
      throw Exception("Error reading device: ${resp.errorMsg}");
    }
    return resp.buffer as Uint8List;
  }

  /// Write an Output report to a HID device.
  ///
  /// The first byte of [buffer] must contain the Report ID. For
  /// devices which only support a single report, this must be set
  /// to 0x0. The remaining bytes contain the report data. Since
  /// the Report ID is mandatory, calls to sendReport() will always
  /// contain one more byte than the report contains. For example,
  /// if a hid report is 16 bytes long, 17 bytes must be passed to
  /// sendReport(), the Report ID (or 0x0, for devices with a
  /// single report), followed by the report data (16 bytes). In
  /// this example, the length passed in would be 17.
  ///
  /// sendReport() will send the data on the first OUT endpoint, if
  /// one exists. If it does not, it will send the data through
  /// the Control Endpoint (Endpoint 0).
  ///
  /// If the write fails this function will throw an exception.
  void sendReport(Uint8List buffer) async {
    var responsePort = ReceivePort();
    commandPort.send(USBIsolateCommand(responsePort.sendPort, USBDeviceCommand.SendFeatureReport, buffer));
    var resp = await responsePort.first as USBIsolateResponse;
    if (resp.status != USBDeviceStatus.Ok) {
      throw Exception("Error reading device: ${resp.errorMsg}");
    }
  }
}