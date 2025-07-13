import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import '../models/connection_model.dart';

class ClipboardSyncWidget extends StatelessWidget {
  final ConnectionModel connectionModel;
  final TextEditingController textController;
  final Function(String) onSendMessage;
  final Function(String, Color?) onShowSnackBar;

  const ClipboardSyncWidget({
    Key? key,
    required this.connectionModel,
    required this.textController,
    required this.onSendMessage,
    required this.onShowSnackBar,
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
              'Clipboard Sync',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                labelText: 'Enter text to sync',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.content_paste),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: textController.text.trim().isNotEmpty && 
                          (connectionModel.isHost || connectionModel.isConnected)
                    ? () {
                        onSendMessage(textController.text.trim());
                        textController.clear();
                      }
                    : null,
                icon: Icon(Icons.send),
                label: Text(connectionModel.isHost ? 'Send to Clients' : 'Send to Host'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (connectionModel.clipboardText.isNotEmpty) ...[
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Received Message:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      FlutterClipboard.copy(connectionModel.clipboardText);
                      onShowSnackBar('Copied to clipboard!', Colors.green);
                    },
                    icon: Icon(Icons.copy, size: 16),
                    label: Text('Copy'),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: SelectableText(
                  connectionModel.clipboardText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
