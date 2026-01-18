import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';
import '../constants/app_constants.dart';

/// Service for Socket.IO real-time communication
class SocketService extends GetxService {
  late IO.Socket socket;
  final RxBool isConnected = false.obs;
  
  /// Initialize socket connection
  Future<SocketService> init() async {
    try {
      socket = IO.io(
        AppConstants.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setExtraHeaders({'foo': 'bar'})
            .build(),
      );
      
      _setupListeners();
      connect();
      
      return this;
    } catch (e) {
      print('Socket initialization error: $e');
      return this;
    }
  }
  
  /// Setup socket event listeners
  void _setupListeners() {
    socket.onConnect((_) {
      print('Socket connected');
      isConnected.value = true;
    });
    
    socket.onDisconnect((_) {
      print('Socket disconnected');
      isConnected.value = false;
    });
    
    socket.onConnectError((error) {
      print('Socket connection error: $error');
      isConnected.value = false;
    });
    
    socket.onError((error) {
      print('Socket error: $error');
    });
  }
  
  /// Connect to socket server
  void connect() {
    if (!socket.connected) {
      socket.connect();
    }
  }
  
  /// Disconnect from socket server
  void disconnect() {
    if (socket.connected) {
      socket.disconnect();
    }
  }
  
  /// Listen to a specific event
  void on(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }
  
  /// Emit an event
  void emit(String event, dynamic data) {
    socket.emit(event, data);
  }
  
  /// Remove listener for a specific event
  void off(String event) {
    socket.off(event);
  }
  
  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
