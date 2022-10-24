import 'dart:ffi';
import 'package:dartusbhid/usb_device.dart';

import 'dartusbhid_bindings_generated.dart';

String toString(Pointer<WChar> str) {
  var result = "";
  var i = 0;
  while (true) {
    var val = str.elementAt(i).value;
    if (val == 0 || i > 256) {
      break;
    }
    result += String.fromCharCode(val);
    i += 1;
  }
  return result;
}

List<USBDeviceInfo> toDeviceList(Pointer<hid_device_info> pointer) {
  List<USBDeviceInfo> result = [];
  var device = pointer;

  var i = 0;
  while (device.address != 0 && i < 256) {
    result.add(USBDeviceInfo(
      device.ref.vendor_id,
      device.ref.product_id, 
      toString(device.ref.serial_number),
      device.ref.release_number,
      toString(device.ref.manufacturer_string),
      toString(device.ref.product_string),
      device.ref.usage_page,
      device.ref.usage,
      device.ref.interface_number));
    i += 1;
    device = device.ref.next;
  }
  return result;
}
