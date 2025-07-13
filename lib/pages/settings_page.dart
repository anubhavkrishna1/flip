import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SettingsPage extends StatelessWidget {
  final String localIP;
  final bool isHost;
  final int connectedClientsCount;

  const SettingsPage({
    Key? key,
    required this.localIP,
    required this.isHost,
    required this.connectedClientsCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          if (isHost) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.qr_code, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'QR Code',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Share this QR code with clients to connect:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: '$localIP:5000',
                          version: QrVersions.auto,
                          size: 200,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade50,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Server Details:',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          SelectableText('IP: $localIP:5000'),
                          SelectableText('Connected Clients: $connectedClientsCount'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'How to Use',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildHowToStep('1', 'Host Mode', 'Turn on Host mode to create a server. Share the QR code or IP address with clients.'),
                  _buildHowToStep('2', 'Client Mode', 'Turn off Host mode and enter the host IP address or scan the QR code to connect.'),
                  _buildHowToStep('3', 'Sync Clipboard', 'Type text and click "Send & Copy" to sync clipboard across all connected devices.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToStep(String step, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            child: Text(
              step,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
