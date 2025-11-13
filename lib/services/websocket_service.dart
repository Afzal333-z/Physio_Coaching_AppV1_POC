import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _messageController;
  Stream<Map<String, dynamic>>? _messageStream;

  Stream<Map<String, dynamic>>? get messageStream => _messageStream;

  void connect(String sessionCode, String userId) {
    final wsUrl = 'ws://localhost:8000/ws/$sessionCode/$userId';
    
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _messageController = StreamController<Map<String, dynamic>>.broadcast();
      
      _messageStream = _channel!.stream.map((message) {
        return jsonDecode(message as String) as Map<String, dynamic>;
      });

      _messageStream!.listen(
        (data) {
          _messageController?.add(data);
        },
        onError: (error) {
          print('WebSocket error: $error');
        },
        onDone: () {
          print('WebSocket closed');
        },
      );
    } catch (e) {
      print('Error connecting WebSocket: $e');
    }
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _messageController?.close();
    _channel = null;
    _messageController = null;
    _messageStream = null;
  }

  bool get isConnected => _channel != null;
}

