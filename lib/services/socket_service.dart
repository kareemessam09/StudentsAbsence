import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/api_config.dart';
import '../utils/app_logger.dart';

/// Socket.IO Service for real-time notifications
class SocketService {
  IO.Socket? _socket;
  bool _isConnected = false;
  String? _token;

  // Callbacks for different events
  Function(Map<String, dynamic>)? onNotificationCreated;
  Function(Map<String, dynamic>)? onNotificationUpdated;
  Function(String)? onNotificationDeleted;

  bool get isConnected => _isConnected;

  /// Initialize socket connection with authentication token
  void connect(String token) {
    if (_socket != null && _isConnected) {
      AppLogger.socket('Socket already connected');
      return;
    }

    _token = token;

    AppLogger.socket('Connecting to socket: ${ApiConfig.socketUrl}');

    _socket = IO.io(
      ApiConfig.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket']) // Use WebSocket transport
          .disableAutoConnect() // Manually control connection
          .setAuth({'token': token}) // Send JWT token for authentication
          .build(),
    );

    _setupEventListeners();
    _socket!.connect();
  }

  /// Setup all socket event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      _isConnected = true;
      AppLogger.success('Socket connected', tag: 'SocketService');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      AppLogger.warning('Socket disconnected', tag: 'SocketService');
    });

    _socket!.onConnectError((error) {
      AppLogger.error(
        'Socket connection error',
        tag: 'SocketService',
        error: error,
      );
    });

    _socket!.onError((error) {
      AppLogger.error('Socket error', tag: 'SocketService', error: error);
    });

    // Notification events
    _socket!.on('notification:created', (data) {
      AppLogger.socket('New notification created: $data');
      if (onNotificationCreated != null && data is Map<String, dynamic>) {
        onNotificationCreated!(data);
      }
    });

    _socket!.on('notification:updated', (data) {
      AppLogger.socket('Notification updated: $data');
      if (onNotificationUpdated != null && data is Map<String, dynamic>) {
        onNotificationUpdated!(data);
      }
    });

    _socket!.on('notification:deleted', (data) {
      AppLogger.socket('Notification deleted: $data');
      if (onNotificationDeleted != null && data is String) {
        onNotificationDeleted!(data);
      }
    });
  }

  /// Disconnect socket
  void disconnect() {
    if (_socket != null) {
      AppLogger.socket('Disconnecting socket');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      _token = null;
    }
  }

  /// Reconnect with existing token
  void reconnect() {
    if (_token != null) {
      disconnect();
      connect(_token!);
    } else {
      AppLogger.error(
        'Cannot reconnect: No token available',
        tag: 'SocketService',
      );
    }
  }

  /// Check if socket needs reconnection
  void ensureConnected(String token) {
    if (!_isConnected || _token != token) {
      disconnect();
      connect(token);
    }
  }

  /// Emit a custom event (if needed in future)
  void emit(String event, dynamic data) {
    if (_socket != null && _isConnected) {
      _socket!.emit(event, data);
      AppLogger.socket('Emitted event: $event with data: $data');
    } else {
      AppLogger.error(
        'Cannot emit: Socket not connected',
        tag: 'SocketService',
      );
    }
  }
}
