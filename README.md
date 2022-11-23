# dartusbhid

A dart wrapper for libusbhid, to interface with human input devices. It runs in its own isolate. Supports

* Enumerating USB HID devices
* Reading and writing device reports with or without report ID

Planned:

* Read and write feature reports

## Installation

```console
flutter pub add dartusbhid
```

## Usage

```dart
import 'package:dartusbhid/usb_device.dart';

final devices = await enumerateDevices(0, 0);
for (final device in devices) {
  print(device);
}

final openDevice = await device[0].open();
final receivedData = await openDevice.readReport();
await openDevice.close();
```

## Development

To try out the example

```console
git clone https://github.com/TobiasJacob/dartusbhid.git
cd dartusbhid/example
flutter run
```

from there on you can start to develop the library.
