import 'dart:io';
import 'dart:convert';
import 'dart:async';
import '../../domain/entities/peer.dart';

class ChatConnection {
  final Peer peer;
  Socket? _socket;
  final StreamController<String> _messageController = StreamController<String>.broadcast();

  Stream<String> get messages => _messageController.stream;

  ChatConnection(this.peer);

  /// Establishes a connection to a peer
  Future<void> connect() async {
    try {
      _socket = await Socket.connect(peer.ipAddress, 8889); // Using a dedicated chat port
      print("Sadeem Bridge: Connected to ${peer.deviceName} at ${peer.ipAddress}");
      
      _listenForMessages();
      _sendHandshake();
    } catch (e) {
      print("Sadeem Bridge Error: Could not connect to ${peer.deviceName}: $e");
      rethrow;
    }
  }

  /// Starts a server to accept incoming chat connections
  static Future<void> startChatServer(Function(Socket) onConnect) async {
    try {
      ServerSocket server = await ServerSocket.bind(InternetAddress.anyIPv4, 8889);
      print("Sadeem Bridge: Chat server listening on port 8889...");
      
      server.listen((Socket socket) {
        onConnect(socket);
      });
    } catch (e) {
      print("Sadeem Bridge Server Error: $e");
    }
  }

  /// Attaches an existing socket (from the server) to this connection object
  void attachSocket(Socket socket) {
    _socket = socket;
    _listenForMessages();
  }

  void _sendHandshake() {
    sendMessage("SADEEM_HANDSHAKE:Hello from ${peer.id}");
  }

  void _listenForMessages() {
    _socket!.listen(
      (List<int> data) {
        String message = utf8.decode(data);
        if (message.startsWith("SADEEM_HANDSHAKE:")) {
          print("Sadeem Bridge: Handshake received: ${message}");
        } else {
          _messageController.add(message);
        }
      },
      onError: (error) {
        print("Sadeem Bridge: Connection error with ${peer.deviceName}: $error");
        disconnect();
      },
      onDone: () {
        print("Sadeem Bridge: Connection closed by ${peer.deviceName}");
        disconnect();
      },
    );
  }

  Future<void> sendMessage(String text) async {
    if (_socket == null) throw Exception("Not connected to peer");
    _socket!.write(text);
  }

  void disconnect() {
    _socket?.destroy();
    _messageController.close();
  }
}
