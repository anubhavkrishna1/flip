import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';

class ConnectionModel {
  bool isHost;
  HttpServer? server;
  String localIP;
  String clipboardText;
  bool isConnected;
  int connectedClientsCount;
  WebSocketChannel? channel;
  List<WebSocketChannel> connectedClients;

  ConnectionModel({
    this.isHost = true,
    this.server,
    this.localIP = '',
    this.clipboardText = '',
    this.isConnected = false,
    this.connectedClientsCount = 0,
    this.channel,
    List<WebSocketChannel>? connectedClients,
  }) : connectedClients = connectedClients ?? [];

  void addClient(WebSocketChannel client) {
    connectedClients.add(client);
    connectedClientsCount = connectedClients.length;
  }

  void removeClient(WebSocketChannel client) {
    connectedClients.remove(client);
    connectedClientsCount = connectedClients.length;
  }

  void clearClients() {
    connectedClients.clear();
    connectedClientsCount = 0;
  }

  void reset() {
    clipboardText = '';
    isConnected = false;
    clearClients();
  }
}
