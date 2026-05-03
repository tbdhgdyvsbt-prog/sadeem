import 'dart:io';
import '../datasources/chat_connection.dart';
import '../../domain/entities/peer.dart';

class ChatRepository {
  final Map<String, ChatConnection> _activeConnections = {};

  /// Connects to a peer and returns the connection object
  Future<ChatConnection> connectToPeer(Peer peer) async {
    if (_activeConnections.containsKey(peer.id)) {
      return _activeConnections[peer.id]!;
    }

    ChatConnection connection = ChatConnection(peer);
    await connection.connect();
    _activeConnections[peer.id] = connection;
    return connection;
  }

  /// Handles incoming chat connections from other peers
  void initIncomingConnectionHandler() {
    ChatConnection.startChatServer((Socket socket) {
      // In a real app, we'd perform a handshake first to get the peer's info
      // For now, we create a generic Peer for the incoming connection
      Peer incomingPeer = Peer(
        id: "Unknown_Peer_${socket.remoteAddress.address.hashCode}",
        ipAddress: socket.remoteAddress.address,
        deviceName: "Remote Peer",
        lastSeen: DateTime.now(),
      );

      ChatConnection connection = ChatConnection(incomingPeer);
      connection.attachSocket(socket);
      _activeConnections[incomingPeer.id] = connection;
      print("Sadeem Bridge: Accepted incoming connection from ${incomingPeer.ipAddress}");
    });
  }

  ChatConnection? getConnection(String peerId) => _activeConnections[peerId];

  void disconnectPeer(String peerId) {
    _activeConnections[peerId]?.disconnect();
    _activeConnections.remove(peerId);
  }
}
