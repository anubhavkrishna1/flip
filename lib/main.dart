import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'settings_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clipboard Sync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: ClipboardSyncApp(),
    );
  }
}

class ClipboardSyncApp extends StatefulWidget {
  @override
  _ClipboardSyncAppState createState() => _ClipboardSyncAppState();
}

class _ClipboardSyncAppState extends State<ClipboardSyncApp> {
  bool isHost = true;
  HttpServer? _server;
  String _localIP = '';
  String _clipboardText = '';
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _clientIPController = TextEditingController();
  bool _isConnected = false;
  int _connectedClientsCount = 0;

  WebSocketChannel? _channel;
  List<WebSocket> _connectedClients = [];

  @override
  void initState() {
    super.initState();
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
    if (isHost) {
      _localIP = await _getLocalIp();
      await _startWebSocketServer();
    }
  }

  Future<String> _getLocalIp() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );
    return interfaces.expand((e) => e.addresses).first.address;
  }

  Future<void> _startWebSocketServer() async {
    final handler = webSocketHandler((WebSocket socket) {
      _connectedClients.add(socket);
      setState(() {
        _connectedClientsCount = _connectedClients.length;
      });
      
      socket.listen(
        (message) {
          debugPrint('Host received message: $message');
          // Update host's display with received message
          setState(() {
            _clipboardText = message;
          });
          
          // Show notification to host
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Message received from client'),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 2),
              ),
            );
          }
          
          // Forward message to all other clients (except sender)
          for (var client in _connectedClients) {
            if (client != socket) {
              client.add(message);
            }
          }
        },
        onDone: () {
          _connectedClients.remove(socket);
          setState(() {
            _connectedClientsCount = _connectedClients.length;
          });
        },
        onError: (error) {
          debugPrint('WebSocket client error: $error');
          _connectedClients.remove(socket);
          setState(() {
            _connectedClientsCount = _connectedClients.length;
          });
        },
      );
    });

    _server = await shelf_io.serve(
      logRequests().addHandler(handler),
      InternetAddress.anyIPv4,
      5000,
    );

    debugPrint('WebSocket server running on ws://$_localIP:5000');
  }

  Future<void> _connectToWebSocket(String ip) async {
    try {
      setState(() {
        _isConnected = false;
      });
      
      // Validate and format IP
      if (!ip.contains(':')) {
        ip = '$ip:5000';
      }
      
      if (!_validateIPFormat(ip)) {
        throw Exception('Invalid IP address format');
      }
      
      debugPrint('Attempting to connect to: ws://$ip');
      
      // Test basic connection first
      final canConnect = await _testConnection(ip);
      if (!canConnect) {
        throw Exception('Cannot reach host at $ip. Please check if the host is running and reachable.');
      }
      
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://$ip'),
        protocols: null,
      );
      
      await _channel!.ready;
      
      _channel!.stream.listen(
        (message) {
          debugPrint('Received message: $message');
          setState(() {
            _clipboardText = message;
            _isConnected = true;
          });
          // Don't automatically copy - just display the received text
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Message received from host'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          setState(() {
            _isConnected = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Connection error: ${error.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          setState(() {
            _isConnected = false;
          });
        },
      );
      
      setState(() {
        _isConnected = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected to host successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
    } catch (e) {
      debugPrint('Connection failed: $e');
      setState(() {
        _isConnected = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sendClipboard(String text) {
    if (isHost) {
      for (var client in _connectedClients) {
        client.add(text);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Message sent to ${_connectedClients.length} client(s)'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      _channel?.sink.add(text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Message sent to host'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
    // Update local display and clear input
    setState(() {
      _clipboardText = text;
    });
    _textController.clear();
  }

  @override
  void dispose() {
    _textController.dispose();
    _clientIPController.dispose();
    _server?.close();
    _channel?.sink.close();
    super.dispose();
  }

  Widget _buildConnectionStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isHost ? Icons.wifi_tethering : Icons.wifi,
                  color: isHost 
                    ? (_connectedClientsCount > 0 ? Colors.green : Colors.orange)
                    : (_isConnected ? Colors.green : Colors.red),
                ),
                SizedBox(width: 8),
                Text(
                  isHost ? 'Host Mode' : 'Client Mode',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Switch(
                  value: isHost,
                  onChanged: (val) async {
                    setState(() {
                      isHost = val;
                      _clipboardText = '';
                      _isConnected = false;
                    });
                    if (isHost) {
                      // Close client connection
                      await _channel?.sink.close();
                      _channel = null;
                      await _initHostIfNeeded();
                    } else {
                      // Close server
                      await _server?.close();
                      _server = null;
                      _connectedClients.clear();
                      _connectedClientsCount = 0;
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            if (isHost) ...[
              Text(
                'Connected clients: $_connectedClientsCount',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (_localIP.isNotEmpty)
                Text(
                  'Server: $_localIP:5000',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ] else ...[
              Row(
                children: [
                  Icon(
                    _isConnected ? Icons.check_circle : Icons.error,
                    color: _isConnected ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    _isConnected ? 'Connected' : 'Disconnected',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _isConnected ? Colors.green : Colors.red,
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

  Widget _buildClientConnection() {
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
              controller: _clientIPController,
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
                              _buildQRScanner(),
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
                onPressed: _clientIPController.text.trim().isNotEmpty
                    ? () {
                        String ip = _clientIPController.text.trim();
                        // Validate and format IP
                        if (!ip.contains(':')) {
                          ip = '$ip:5000';
                        }
                        _connectToWebSocket(ip);
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

  Widget _buildClipboardSection() {
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
              controller: _textController,
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
                onPressed: _textController.text.trim().isNotEmpty && 
                          (isHost || _isConnected)
                    ? () => _sendClipboard(_textController.text.trim())
                    : null,
                icon: Icon(Icons.send),
                label: Text(isHost ? 'Send to Clients' : 'Send to Host'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (_clipboardText.isNotEmpty) ...[
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
                      FlutterClipboard.copy(_clipboardText);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied to clipboard!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 1),
                        ),
                      );
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
                  _clipboardText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQRScanner() {
    return SizedBox(
      height: 250,
      width: 250,
      child: MobileScanner(
        onDetect: (capture) {
          final barcode = capture.barcodes.first;
          final value = barcode.rawValue;
          if (value != null) {
            _clientIPController.text = value;
            _connectToWebSocket(value);
            Navigator.pop(context); // Close camera view
          }
        },
      ),
    );
  }

  // Helper method to validate IP format
  bool _validateIPFormat(String ip) {
    if (ip.isEmpty) return false;
    
    // Check if it already has port
    if (ip.contains(':')) {
      final parts = ip.split(':');
      if (parts.length != 2) return false;
      
      final port = int.tryParse(parts[1]);
      if (port == null || port < 1 || port > 65535) return false;
      
      // Validate IP part
      final ipParts = parts[0].split('.');
      if (ipParts.length != 4) return false;
      
      for (String part in ipParts) {
        final num = int.tryParse(part);
        if (num == null || num < 0 || num > 255) return false;
      }
      return true;
    } else {
      // Just IP, validate and add default port
      final ipParts = ip.split('.');
      if (ipParts.length != 4) return false;
      
      for (String part in ipParts) {
        final num = int.tryParse(part);
        if (num == null || num < 0 || num > 255) return false;
      }
      return true;
    }
  }

  // Helper method to test connection before actually connecting
  Future<bool> _testConnection(String ip) async {
    try {
      final socket = await Socket.connect(
        ip.split(':')[0], 
        int.parse(ip.split(':')[1]),
        timeout: Duration(seconds: 5),
      );
      await socket.close();
      return true;
    } catch (e) {
      debugPrint('Connection test failed: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clipboard Sync'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    localIP: _localIP,
                    isHost: isHost,
                    connectedClientsCount: _connectedClientsCount,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (isHost) {
            await _initHostIfNeeded();
          }
        },
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildConnectionStatus(),
            SizedBox(height: 16),
            if (!isHost) ...[
              _buildClientConnection(),
              SizedBox(height: 16),
            ],
            _buildClipboardSection(),
          ],
        ),
      ),
    );
  }
}
