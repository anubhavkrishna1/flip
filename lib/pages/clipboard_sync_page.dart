import 'package:flutter/material.dart';
import '../models/connection_model.dart';
import '../services/websocket_service.dart';
import '../widgets/connection_status_widget.dart';
import '../widgets/client_connection_widget.dart';
import '../widgets/clipboard_sync_widget.dart';
import 'settings_page.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controllers/theme_controller.dart';

class ClipboardSyncPage extends StatefulWidget {
  final ThemeController? themeController;

  const ClipboardSyncPage({Key? key, this.themeController}) : super(key: key);
  @override
  _ClipboardSyncPageState createState() => _ClipboardSyncPageState();
}

class _ClipboardSyncPageState extends State<ClipboardSyncPage> {
  late ConnectionModel _connectionModel;
  late WebSocketService _webSocketService;
  
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _clientIPController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _connectionModel = ConnectionModel();
    _webSocketService = WebSocketService(
      connectionModel: _connectionModel,
      onMessageReceived: _onMessageReceived,
      onStateChanged: _onStateChanged,
      onShowSnackBar: _showSnackBar,
    );
    
    _initHostIfNeeded();
    
    // Add listeners to text controllers to update button states
    _textController.addListener(() {
      setState(() {});
    });
    _clientIPController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _initHostIfNeeded() async {
    await _webSocketService.initHostIfNeeded();
    _onStateChanged();
  }

  void _onMessageReceived(String message) {
    if (mounted) {
      setState(() {
        _connectionModel.clipboardText = message;
      });
    }
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {
        // Trigger UI rebuild
      });
    }
  }

  void _showSnackBar(String message, Color? backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: Duration(seconds: backgroundColor == Colors.green ? 1 : 2),
        ),
      );
    }
  }

  Future<void> _onModeChanged(bool isHost) async {
    setState(() {
      _connectionModel.isHost = isHost;
      _connectionModel.reset();
    });
    
    if (isHost) {
      // Close client connection
      await _connectionModel.channel?.sink.close();
      _connectionModel.channel = null;
      await _initHostIfNeeded();
    } else {
      // Close server
      await _connectionModel.server?.close();
      _connectionModel.server = null;
      _connectionModel.clearClients();
    }
  }

  void _onConnect(String ip) {
    _webSocketService.connectToWebSocket(ip);
  }

  void _onSendMessage(String message) {
    _webSocketService.sendMessage(message);
  }

  @override
  void dispose() {
    _textController.dispose();
    _clientIPController.dispose();
    _webSocketService.dispose();
    super.dispose();
  }

  // Show QR code popup for host
  void _showQRCodePopup() {
    if (_connectionModel.localIP.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: 500,
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Share QR Code',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Scan this QR code to connect',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: QrImageView(
                      data: '${_connectionModel.localIP}:5000',
                      version: QrVersions.auto,
                      size: 180,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: SelectableText(
                      '${_connectionModel.localIP}:5000',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsPage(
                                localIP: _connectionModel.localIP,
                                isHost: _connectionModel.isHost,
                                connectedClientsCount: _connectionModel.connectedClientsCount,
                                themeController: widget.themeController,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.settings),
                        label: Text('Settings'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clipboard Sync'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // QR Code button - only show when host and has IP
          if (_connectionModel.isHost && _connectionModel.localIP.isNotEmpty)
            IconButton(
              icon: Icon(Icons.qr_code),
              onPressed: _showQRCodePopup,
              tooltip: 'Show QR Code',
            ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    localIP: _connectionModel.localIP,
                    isHost: _connectionModel.isHost,
                    connectedClientsCount: _connectionModel.connectedClientsCount,
                    themeController: widget.themeController,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_connectionModel.isHost) {
            await _initHostIfNeeded();
          }
        },
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            ConnectionStatusWidget(
              connectionModel: _connectionModel,
              onModeChanged: _onModeChanged,
            ),
            SizedBox(height: 16),
            if (!_connectionModel.isHost) ...[
              ClientConnectionWidget(
                ipController: _clientIPController,
                onConnect: _onConnect,
              ),
              SizedBox(height: 16),
            ],
            ClipboardSyncWidget(
              connectionModel: _connectionModel,
              textController: _textController,
              onSendMessage: _onSendMessage,
              onShowSnackBar: _showSnackBar,
            ),
          ],
        ),
      ),
    );
  }
}
