import 'dart:async';
import '../data/repositories/chat_repository.dart';
import '../domain/entities/peer.dart';
import '../domain/entities/message.dart';

class ChatManager {
  final ChatRepository _repository = ChatRepository();
  
  // Map to keep track of message history for each peer
  final Map<String, List<Message>> _histories = {};
  
  // Stream to notify UI when a new message arrives for a specific peer
  final StreamController<Message> _messageStream = StreamController<Message>.broadcast();
  Stream<Message> get messageStream => _messageStream.stream;

  ChatManager() {
    _repository.initIncomingConnectionHandler();
  }

  Future<void> connectToPeer(Peer peer) async {
    final connection = await _repository.connectToPeer(peer);
    
    // Listen for messages from this connection and pipe them to the global stream
    connection.messages.listen((text) {
      final msg = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: peer.id,
        text: text,
        timestamp: DateTime.now(),
        isMe: false,
      );
      _saveMessage(peer.id, msg);
      _messageStream.add(msg);
    });
  }

  Future<void> sendMessage(String peerId, String text) async {
    final connection = _repository.getConnection(peerId);
    if (connection == null) throw Exception("No active connection to peer");

    await connection.sendMessage(text);
    
    final msg = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: "me",
      text: text,
      timestamp: DateTime.now(),
      isMe: true,
    );
    _saveMessage(peerId, msg);
    _messageStream.add(msg);
  }

  void _saveMessage(String peerId, Message msg) {
    _histories.putIfAbsent(peerId, () => []);
    _histories[peerId]!.add(msg);
  }

  List<Message> getMessagesForPeer(String peerId) {
    return _histories[peerId] ?? [];
  }
}
