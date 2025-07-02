# Flip - Clipboard over Local Network

Flip is a cross-platform application that allows you to share your clipboard content across devices on your local network.

## Features

*   **Cross-platform:** Works on Android, iOS, Windows, macOS, and Linux.
*   **Real-time:** Clipboard content is shared instantly using WebSockets.
*   **Easy setup:** Connect devices by scanning a QR code.
*   **Secure:** Your data stays within your local network.

## How it works

Flip starts a local HTTP server on one device. Other devices can connect to it by scanning a QR code, which contains the server's local IP address and port. Once connected, the devices communicate over a WebSocket connection to share clipboard content in real-time.

## Usage

1.  **Start the server:** Launch the Flip application on one of your devices. This will be the "server" device. A QR code will be displayed.
2.  **Connect a client:** On another device, launch the Flip application and use the "Scan QR code" feature to scan the QR code displayed on the server device.
3.  **Share:** Now, whenever you copy text on one device, it will be instantly available on the clipboard of the other connected devices.
