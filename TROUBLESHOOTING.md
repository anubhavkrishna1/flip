# Clipboard Sync - Connection Troubleshooting Guide

## Common Connection Issues and Solutions

### 1. "Failed to connect" Error

**Possible Causes:**
- Host server is not running
- Incorrect IP address
- Network connectivity issue
- Firewall blocking connection

**Solutions:**
1. **Verify Host is Running**: Make sure the host device has the app running in Host mode
2. **Check IP Address**: 
   - Go to Settings on the host device
   - Copy the exact IP:Port shown (e.g., 192.168.1.100:5000)
   - Use this exact address on the client
3. **Network Check**: Both devices must be on the same network (WiFi)
4. **Try Different Formats**:
   - With port: `192.168.1.100:5000`
   - Without port: `192.168.1.100` (app will add :5000 automatically)

### 2. Connection Drops Frequently

**Solutions:**
- Keep the app in foreground on both devices
- Check if the network is stable
- Restart both host and client apps

### 3. QR Code Scanning Issues

**Solutions:**
- Ensure good lighting when scanning
- Hold camera steady
- Make sure QR code is fully visible in the scanner frame
- Try manual IP entry if scanning fails

### 4. No Clipboard Sync

**Solutions:**
- Check connection status indicator (should be green)
- Try sending a test message
- Restart the connection if needed

### 5. Network Discovery

**To find your host IP address:**
1. Turn on Host mode
2. Go to Settings
3. The IP address will be displayed in the "Server Details" section

**Network Requirements:**
- Both devices must be on the same WiFi network
- Port 5000 should not be blocked by firewall
- Some corporate/public WiFi networks may block device-to-device communication

### 6. Testing Connection

The app now includes automatic connection testing:
- It will validate the IP format
- Test if the host is reachable
- Provide specific error messages

### 7. Debug Information

Check the Flutter debug console for detailed error messages:
- Connection attempts are logged
- WebSocket errors are displayed
- Use this information to identify specific issues

---

## Quick Setup Steps

### Host Setup:
1. Open the app
2. Ensure "Host Mode" is ON (toggle switch)
3. Go to Settings to see/share the QR code
4. Share IP address with clients

### Client Setup:
1. Open the app  
2. Turn OFF "Host Mode" (toggle switch)
3. Either:
   - Scan the QR code from host, OR
   - Manually enter the host IP address
4. Click "Connect"

### Testing:
1. Type text in "Enter text to sync" field
2. Click "Send & Copy"
3. Text should appear on all connected devices
