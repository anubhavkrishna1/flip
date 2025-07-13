import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import '../models/connection_model.dart';
import '../utils/network_utils.dart';

class WebSocketService {
  final ConnectionModel _connectionModel;
  final Function(String) onMessageReceived;
  final Function() onStateChanged;
  final Function(String, Color?) onShowSnackBar;

  WebSocketService({
    required ConnectionModel connectionModel,
    required this.onMessageReceived,
    required this.onStateChanged,
    required this.onShowSnackBar,
  }) : _connectionModel = connectionModel;

  /// Start WebSocket server for host mode
  Future<void> startWebSocketServer() async {
    try {
      // Close existing server if any
      await _connectionModel.server?.close();
      
      final handler = webSocketHandler((webSocketChannel) {
        debugPrint('New client connected');
        _connectionModel.addClient(webSocketChannel);
        onStateChanged();
        
        webSocketChannel.stream.listen(
          (message) {
            debugPrint('Host received message from client: $message');
            // Update host's display with received message
            onMessageReceived(message.toString());
            
            // Show notification to host
            onShowSnackBar('Message received from client', Colors.blue);
            
            // Forward message to all other clients (except sender)
            for (var client in _connectionModel.connectedClients) {
              if (client != webSocketChannel) {
                try {
                  client.sink.add(message.toString());
                  debugPrint('Forwarded message to another client');
                } catch (e) {
                  debugPrint('Error forwarding message: $e');
                }
              }
            }
          },
          onDone: () {
            debugPrint('Client disconnected');
            _connectionModel.removeClient(webSocketChannel);
            onStateChanged();
          },
          onError: (error) {
            debugPrint('WebSocket client error: $error');
            _connectionModel.removeClient(webSocketChannel);
            onStateChanged();
          },
        );
      });

      _connectionModel.server = await shelf_io.serve(
        logRequests().addHandler(handler),
        InternetAddress.anyIPv4,
        5000,
      );

      debugPrint('WebSocket server running on ws://${_connectionModel.localIP}:5000');
    } catch (e) {
      debugPrint('Error starting WebSocket server: $e');
    }
  }

  /// Connect to WebSocket server for client mode
  Future<void> connectToWebSocket(String ip) async {
    try {
      _connectionModel.isConnected = false;
      onStateChanged();
      
      // Validate and format IP
      if (!ip.contains(':')) {
        ip = '$ip:5000';
      }
      
      if (!NetworkUtils.validateIPFormat(ip)) {
        throw Exception('Invalid IP address format');
      }
      
      debugPrint('Attempting to connect to: ws://$ip');
      
      // Test basic connection first
      final canConnect = await NetworkUtils.testConnection(ip);
      if (!canConnect) {
        throw Exception('Cannot reach host at $ip. Please check if the host is running and reachable.');
      }
      
      _connectionModel.channel = IOWebSocketChannel.connect(
        Uri.parse('ws://$ip'),
      );
      
      await _connectionModel.channel!.ready;
      
      _connectionModel.channel!.stream.listen(
        (message) {
          debugPrint('Client received message from host: $message');
          onMessageReceived(message.toString());
          onShowSnackBar('Message received from host', Colors.green);
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _connectionModel.isConnected = false;
          onStateChanged();
          onShowSnackBar('Connection error: ${error.toString()}', Colors.red);
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          _connectionModel.isConnected = false;
          onStateChanged();
        },
      );
      
      _connectionModel.isConnected = true;
      onStateChanged();
      onShowSnackBar('Connected to host successfully!', Colors.green);
      
    } catch (e) {
      debugPrint('Connection failed: $e');
      _connectionModel.isConnected = false;
      onStateChanged();
      onShowSnackBar('Failed to connect: ${e.toString()}', Colors.red);
    }
  }

  /// Send message through WebSocket
  void sendMessage(String text) {
    if (_connectionModel.isHost) {
      // Send to all connected clients
      int sentCount = 0;
      for (var client in _connectionModel.connectedClients) {
        try {
          client.sink.add(text);
          sentCount++;
          debugPrint('Message sent to client');
        } catch (e) {
          debugPrint('Error sending to client: $e');
        }
      }
      onShowSnackBar('Message sent to $sentCount client(s)', Colors.green);
    } else {
      // Send to host
      if (_connectionModel.channel != null && _connectionModel.isConnected) {
        try {
          _connectionModel.channel!.sink.add(text);
          debugPrint('Message sent to host: $text');
          onShowSnackBar('Message sent to host', Colors.green);
        } catch (e) {
          debugPrint('Error sending to host: $e');
          onShowSnackBar('Failed to send message', Colors.red);
        }
      } else {
        onShowSnackBar('Not connected to host', Colors.red);
      }
    }
  }

  /// Initialize host if needed
  Future<void> initHostIfNeeded() async {
    if (_connectionModel.isHost) {
      _connectionModel.localIP = await NetworkUtils.getLocalIp();
      await startWebSocketServer();
    }
  }

  /// Clean up connections
  void dispose() {
    // Close all client connections
    for (var client in _connectionModel.connectedClients) {
      try {
        client.sink.close();
      } catch (e) {
        debugPrint('Error closing client connection: $e');
      }
    }
    _connectionModel.clearClients();
    
    _connectionModel.server?.close();
    _connectionModel.channel?.sink.close();
  }
}
