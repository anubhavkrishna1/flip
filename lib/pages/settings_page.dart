import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../controllers/theme_controller.dart';

class SettingsPage extends StatelessWidget {
  final String localIP;
  final bool isHost;
  final int connectedClientsCount;
  final ThemeController? themeController;

  const SettingsPage({
    Key? key,
    required this.localIP,
    required this.isHost,
    required this.connectedClientsCount,
    this.themeController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'App Information',
          ),
        ],
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
                        Icon(Icons.info_outline, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Server Information',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Server Details:',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          SelectableText('IP Address: $localIP:5000'),
                          SizedBox(height: 4),
                          SelectableText('Connected Clients: $connectedClientsCount'),
                          SizedBox(height: 8),
                          Text(
                            'Tip: Use the QR code button in the main screen to share connection info.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
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
                      Icon(Icons.palette, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Theme',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (themeController != null) ...[
                    Row(
                      children: [
                        Text(
                          'Appearance:',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        DropdownButton<ThemeMode>(
                          value: themeController!.themeMode,
                          onChanged: (ThemeMode? newMode) {
                            if (newMode != null) {
                              themeController!.setThemeMode(newMode);
                            }
                          },
                          items: ThemeMode.values.map((ThemeMode mode) {
                            return DropdownMenuItem<ThemeMode>(
                              value: mode,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    ThemeController.getThemeModeIcon(mode),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(ThemeController.getThemeModeString(mode)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Choose your preferred theme. System will follow your device settings.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Theme controller not available',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
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
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
              SizedBox(width: 8),
              Text('About Flip'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Logo and Name
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/logo_256.png',
                            width: 64,
                            height: 64,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to icon if image fails to load
                              return Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.content_copy,
                                  size: 32,
                                  color: Theme.of(context).primaryColor,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Flip',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Version ${packageInfo.version}${packageInfo.buildNumber.isNotEmpty ? '+${packageInfo.buildNumber}' : ''}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                
                // Description
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'A clipboard sync application that enables sharing clipboard content across devices on your local network using WebSockets.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 16),
                
                // Features
                Text(
                  'Features',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                _buildFeatureItem('🔄', 'Real-time clipboard synchronization'),
                _buildFeatureItem('🌐', 'Local network communication'),
                _buildFeatureItem('📱', 'Cross-platform support (Android, Linux, Web)'),
                _buildFeatureItem('🔐', 'Secure WebSocket connections'),
                _buildFeatureItem('📋', 'QR code sharing for easy connection'),
                _buildFeatureItem('🎨', 'Multiple theme support (Light, Dark, System)'),
                SizedBox(height: 16),
                
                // Developer Info
                Text(
                  'Developer',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'anubhavkrishna1',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 16),
                
                // Technical Info
                Text(
                  'Technical Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                _buildTechnicalItem('Framework', 'Flutter 3.32.5'),
                _buildTechnicalItem('Protocol', 'WebSocket (ws://)'),
                _buildTechnicalItem('Port', '5000'),
                _buildTechnicalItem('Network', 'Local Area Network (LAN)'),
                SizedBox(height: 16),
                
                // License
                Text(
                  'License',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Open Source Software',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Copy app info to clipboard
                final appInfo = '''
${packageInfo.appName} - Clipboard Sync App
Version: ${packageInfo.version}${packageInfo.buildNumber.isNotEmpty ? '+${packageInfo.buildNumber}' : ''}
Package: ${packageInfo.packageName}
Developer: anubhavkrishna1
Framework: Flutter 3.32.5
Description: A clipboard sync application that enables sharing clipboard content across devices on your local network using WebSockets.
''';
                Clipboard.setData(ClipboardData(text: appInfo));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('App information copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.of(context).pop();
              },
              child: Text('Copy Info'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
