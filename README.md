# dartusbhid

A dart wrapper for libusbhid, to interface with human input devices. It runs in its own isolate.

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

