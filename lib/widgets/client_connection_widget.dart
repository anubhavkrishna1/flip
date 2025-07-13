import 'package:flutter/material.dart';
import '../widgets/qr_scanner_widget.dart';
import '../utils/network_utils.dart';

class ClientConnectionWidget extends StatelessWidget {
  final TextEditingController ipController;
  final Function(String) onConnect;

  const ClientConnectionWidget({
    Key? key,
    required this.ipController,
    required this.onConnect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connect to Host',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: ipController,
              decoration: InputDecoration(
                labelText: 'Host IP:Port',
                hintText: '192.168.1.100:5000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.computer),
                suffixIcon: IconButton(
                  icon: Icon(Icons.qr_code_scanner),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Scan QR Code',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(height: 20),
                              QRScannerWidget(
                                onScanned: (value) {
                                  ipController.text = value;
                                  onConnect(value);
                                  Navigator.pop(context);
                                },
                              ),
                              SizedBox(height: 20),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: ipController.text.trim().isNotEmpty
                    ? () {
                        String ip = ipController.text.trim();
                        // Validate and format IP
                        if (!ip.contains(':')) {
                          ip = '$ip:5000';
                        }
                        onConnect(ip);
                      }
                    : null,
                icon: Icon(Icons.link),
                label: Text('Connect'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
