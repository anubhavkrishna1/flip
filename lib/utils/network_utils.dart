import 'dart:io';

class NetworkUtils {
  /// Get the local IP address
  static Future<String> getLocalIp() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );
    return interfaces.expand((e) => e.addresses).first.address;
  }

  /// Validate IP format
  static bool validateIPFormat(String ip) {
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

  /// Test connection before actually connecting
  static Future<bool> testConnection(String ip) async {
    try {
      final socket = await Socket.connect(
        ip.split(':')[0], 
        int.parse(ip.split(':')[1]),
        timeout: Duration(seconds: 5),
      );
      await socket.close();
      return true;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}
