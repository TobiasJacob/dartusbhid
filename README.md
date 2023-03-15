# dartusbhid

A dart wrapper for libusbhid, to interface with human input devices. It runs in its own isolate. Supports

* Enumerating USB HID devices
  * Supports `vendorId`, `productId`, `serialNumber`, `releaseNumber`, `manufacturerString`, `productString`, `usagePage`, `usage`, `interfaceNumber`
* Reading and writing device reports with or without report ID

Planned:

* Read and write feature reports

## Installation

```console
flutter pub add dartusbhid
```

## Usage

```dart
import 'package:dartusbhid/enumerate.dart';

void printDeviceList() async {
  // Enumerate all devices
  // Passing 0 for vendor and product Id will enumerate all devices.
  final devices = await enumerateDevices(0, 0);
  print(devices.length);
  for (final device in devices) {
    // Print device information like product name, vendor, etc.
    print(device);
  }

  // Open the first device
  final openDevice = await devices[0].open();

  // Read data without timeout (timeout: null)
  print("Waiting for first hid report");
  final receivedData = await openDevice.readReport(null);
  print("Report ID is: ${receivedData[0]}");
  print(receivedData);

  // Send 64 bytes of data to the device
  var uint8list = Uint8List.fromList(List.generate(64, (index) => 0));
  uint8list[0] = 2; // Set the Report ID
  await openDevice.writeReport(uint8list);

  // Close the device
  await openDevice.close();
}

printDeviceList();
```

## Development

To try out the example

```console
git clone https://github.com/TobiasJacob/dartusbhid.git
cd dartusbhid/example
flutter run
```

from there on you can start to develop the library. Publish the library by increasing the version, adjusting the changelog and using

```console
cd dartusbhid
flutter analyze
flutter pub publish
```
