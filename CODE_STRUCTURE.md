# Code Structure Documentation

This document explains the refactored code structure for better maintainability and debugging.

## File Structure

```
lib/
├── main.dart                           # App entry point and theme configuration
├── models/
│   └── connection_model.dart          # Data model for connection state
├── controllers/
│   └── theme_controller.dart          # Theme management and persistence
├── services/
│   └── websocket_service.dart         # WebSocket server and client logic
├── pages/
│   ├── clipboard_sync_page.dart       # Main page logic and state management
│   └── settings_page.dart             # Settings and information page
├── widgets/
│   ├── connection_status_widget.dart  # Connection status display
│   ├── client_connection_widget.dart  # Client connection UI
│   ├── clipboard_sync_widget.dart     # Clipboard sync UI
│   └── qr_scanner_widget.dart         # QR code scanner widget
└── utils/
    └── network_utils.dart             # Network utility functions
```

## Architecture Overview

### 1. **Models** (`models/`)
- **ConnectionModel**: Manages all connection-related state including:
  - Host/Client mode
  - WebSocket connections
  - Connected clients list
  - Connection status
  - Clipboard text

### 2. **Controllers** (`controllers/`)
- **ThemeController**: Manages application theme:
  - Light/Dark/System theme modes
  - Persistent theme preference storage
  - Theme change notifications

### 3. **Services** (`services/`)
- **WebSocketService**: Handles all WebSocket operations:
  - Server creation and management
  - Client connection logic
  - Message sending/receiving
  - Connection lifecycle management

### 4. **Pages** (`pages/`)
Main application pages:
- **ClipboardSyncPage**: Main page that orchestrates all components:
  - State management
  - UI event handling
  - Service coordination
  - Navigation
- **SettingsPage**: Settings and information display:
  - QR code generation for hosts
  - Connection details
  - Usage instructions

### 5. **Widgets** (`widgets/`)
Reusable UI components with clear responsibilities:
- **ConnectionStatusWidget**: Shows current connection status
- **ClientConnectionWidget**: UI for connecting to a host
- **ClipboardSyncWidget**: Text input and message display
- **QRScannerWidget**: QR code scanning functionality

### 6. **Utils** (`utils/`)
- **NetworkUtils**: Pure utility functions for:
  - IP address validation
  - Local IP discovery
  - Connection testing

## Benefits of This Structure

### 1. **Separation of Concerns**
- UI logic is separated from business logic
- Network operations are isolated in services
- Data models are independent of UI

### 2. **Easier Testing**
- Each component can be tested individually
- Mock services can be easily injected
- Pure functions in utils are testable without UI

### 3. **Better Debugging**
- Issues can be isolated to specific layers
- Debug information is centralized in services
- State changes are tracked in the model

### 4. **Maintainability**
- Changes to UI don't affect business logic
- New features can be added with minimal impact
- Code is more readable and organized

### 5. **Reusability**
- Widgets can be reused in different contexts
- Services can be shared across pages
- Utils can be used throughout the app

## Usage Guidelines

### Adding New Features
1. **UI Changes**: Add/modify widgets in `widgets/`
2. **Business Logic**: Update services in `services/`
3. **Data**: Modify models in `models/`
4. **Utilities**: Add helper functions to `utils/`

### Debugging
1. **UI Issues**: Check widgets and pages
2. **Connection Problems**: Look at WebSocketService
3. **State Issues**: Examine ConnectionModel
4. **Network Problems**: Debug NetworkUtils

### Testing Strategy
1. **Unit Tests**: Test utils and models
2. **Widget Tests**: Test individual widgets
3. **Integration Tests**: Test services with mock dependencies
4. **E2E Tests**: Test complete user flows

## Migration Notes

The refactoring maintains the same functionality while improving code organization:
- All existing features work the same way
- No breaking changes to the user interface
- Debug functionality is preserved
- Performance characteristics remain the same

## Next Steps

Consider these improvements for future development:
1. **State Management**: Add Provider or Bloc for better state management
2. **Error Handling**: Centralize error handling and logging
3. **Testing**: Add comprehensive test coverage
4. **Configuration**: Extract constants and configuration
5. **Localization**: Add internationalization support
