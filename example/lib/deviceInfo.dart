import 'package:dartusbhid/usb_device.dart';
import 'package:flutter/material.dart';

String checkEmpty(String string) {
  if (string != "") return string;
  return "N/A";
}

class DeviceInfoWidget extends StatelessWidget {
  final USBDeviceInfo device;

  const DeviceInfoWidget(this.device, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    checkEmpty(device.productString),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(checkEmpty(device.manufacturerString),
                      overflow: TextOverflow.ellipsis),
                  Text(
                      "productId: ${device.productId}, vendorId: ${device.vendorId}",
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.arrow_right)
          ],
        ));
  }
}
