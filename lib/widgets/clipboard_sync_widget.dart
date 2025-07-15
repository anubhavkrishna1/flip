import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import '../models/connection_model.dart';

class ClipboardSyncWidget extends StatefulWidget {
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
  State<ClipboardSyncWidget> createState() => _ClipboardSyncWidgetState();
}

class _ClipboardSyncWidgetState extends State<ClipboardSyncWidget> {
  bool _autoCopyEnabled = false;
  String _lastProcessedText = '';

  @override
  Widget build(BuildContext context) {
    // Auto copy functionality
    if (_autoCopyEnabled && 
        widget.connectionModel.clipboardText.isNotEmpty && 
        widget.connectionModel.clipboardText != _lastProcessedText) {
      _lastProcessedText = widget.connectionModel.clipboardText;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FlutterClipboard.copy(widget.connectionModel.clipboardText);
        widget.onShowSnackBar('Auto-copied to clipboard!', Colors.blue);
      });
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Clipboard Sync',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _autoCopyEnabled 
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _autoCopyEnabled 
                          ? Theme.of(context).primaryColor.withOpacity(0.3)
                          : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      setState(() {
                        _autoCopyEnabled = !_autoCopyEnabled;
                      });
                      widget.onShowSnackBar(
                        _autoCopyEnabled 
                            ? 'Auto-copy enabled' 
                            : 'Auto-copy disabled',
                        _autoCopyEnabled ? Colors.green : Colors.orange,
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _autoCopyEnabled ? Icons.auto_mode : Icons.pause,
                            size: 16,
                            color: _autoCopyEnabled 
                                ? Theme.of(context).primaryColor 
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                          SizedBox(width: 6),
                          Text(
                            _autoCopyEnabled ? 'Auto-copy' : 'Manual',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _autoCopyEnabled 
                                  ? Theme.of(context).primaryColor 
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: widget.textController,
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
                onPressed: widget.textController.text.trim().isNotEmpty && 
                          (widget.connectionModel.isHost || widget.connectionModel.isConnected)
                    ? () {
                        widget.onSendMessage(widget.textController.text.trim());
                        widget.textController.clear();
                      }
                    : null,
                icon: Icon(Icons.send),
                label: Text(widget.connectionModel.isHost ? 'Send to Clients' : 'Send to Host'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (widget.connectionModel.clipboardText.isNotEmpty) ...[
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
                      FlutterClipboard.copy(widget.connectionModel.clipboardText);
                      widget.onShowSnackBar('Copied to clipboard!', Colors.green);
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
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: SelectableText(
                  widget.connectionModel.clipboardText,
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
