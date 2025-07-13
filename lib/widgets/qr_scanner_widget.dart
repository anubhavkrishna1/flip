import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerWidget extends StatelessWidget {
  final Function(String) onScanned;

  const QRScannerWidget({
    Key? key,
    required this.onScanned,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: 250,
      child: MobileScanner(
        onDetect: (capture) {
          final barcode = capture.barcodes.first;
          final value = barcode.rawValue;
          if (value != null) {
            onScanned(value);
          }
        },
      ),
    );
  }
}
