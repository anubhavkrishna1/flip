import 'package:flutter/material.dart';
import '../models/connection_model.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final ConnectionModel connectionModel;
  final Function(bool) onModeChanged;

  const ConnectionStatusWidget({
    Key? key,
    required this.connectionModel,
    required this.onModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  connectionModel.isHost ? Icons.wifi_tethering : Icons.wifi,
                  color: connectionModel.isHost 
                    ? (connectionModel.connectedClientsCount > 0 ? Colors.green : Colors.orange)
                    : (connectionModel.isConnected ? Colors.green : Colors.red),
                ),
                SizedBox(width: 8),
                Text(
                  connectionModel.isHost ? 'Host Mode' : 'Client Mode',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Switch(
                  value: connectionModel.isHost,
                  onChanged: onModeChanged,
                ),
              ],
            ),
            SizedBox(height: 8),
            if (connectionModel.isHost) ...[
              Text(
                'Connected clients: ${connectionModel.connectedClientsCount}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (connectionModel.localIP.isNotEmpty)
                Text(
                  'Server: ${connectionModel.localIP}:5000',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ] else ...[
              Row(
                children: [
                  Icon(
                    connectionModel.isConnected ? Icons.check_circle : Icons.error,
                    color: connectionModel.isConnected ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    connectionModel.isConnected ? 'Connected' : 'Disconnected',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: connectionModel.isConnected ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
