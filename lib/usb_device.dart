import 'dart:isolate';

import 'package:dartusbhid/open_device.dart';

class USBDeviceInfo {
  /// Device Vendor ID
  final int vendorId;

  /// Device Product ID
  final int productId;

  /// Serial Number
  final String serialNumber;

  /// Device Release Number in binary-coded decimal,
  /// also known as Device Version Number
  final int releaseNumber;

  /// Manufacturer String
  final String manufacturerString;

  /// Product string
  final String productString;

  /// Usage Page for this Device/Interface
  /// (Windows/Mac/hidraw only)
  final int usagePage;

  /// Usage for this Device/Interface
  /// (Windows/Mac/hidraw only)
  final int usage;

  /// The USB interface which this logical device
  /// represents.
  ///
  /// Valid on both Linux implementations in all cases.
  /// Valid on the Windows implementation only if the device
  /// contains more than one interface.
  /// Valid on the Mac implementation if and only if the device
  /// is a USB HID device.
  final int interfaceNumber;

  USBDeviceInfo(
      this.vendorId,
      this.productId,
      this.serialNumber,
      this.releaseNumber,
      this.manufacturerString,
      this.productString,
      this.usagePage,
      this.usage,
      this.interfaceNumber);

  // Open this device to read and write output, input or feature reports. Throws an exception in case the command fails.
  Future<OpenUSBDevice> open({int maxBufferLength = 256}) async {
    var responsePort = ReceivePort();
    Isolate.spawn(
        usbIsolate,
        USBIsolateInit(
            responsePort.sendPort, vendorId, productId, maxBufferLength));
    var commandPort = await responsePort.first;
    if (commandPort is SendPort) {
      return OpenUSBDevice(commandPort, this);
    } else {
      var resp = commandPort as USBIsolateResponse;
      throw Exception("Error closing device: ${resp.errorMsg}");
    }
  }

  // Print all members
  @override
  String toString() {
    return """USB Device Info
vendorId: $vendorId
productId: $productId
serialNumber: $serialNumber
releaseNumber: $releaseNumber
manufacturerString: $manufacturerString
productString: $productString
usagePage: $usagePage
usage: $usage
interfaceNumber: $interfaceNumber
    """;
  }
}
