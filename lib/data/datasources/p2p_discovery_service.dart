import 'dart:io';
import 'dart:convert';
import 'dart:async';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/peer.dart';

class P2PDiscoveryService {
  RawDatagramSocket? _socket;
  final StreamController<Peer> _discoveryController = StreamController<Peer>.broadcast();
  final StreamController<String> _statusController = StreamController<String>.broadcast();

  Stream<Peer> get discoveredPeers => _discoveryController.stream;
  Stream<String> get statusStream => _statusController.stream;

  void _log(String message) {
    _statusController.add(message);
    print("Sadeem Radar: $message");
  }

  /// Starts listening for discovery requests from other peers
  Future<void> startListening() async {
    try {
      if (_socket != null) return;
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, SadeemConstants.discoveryPort);
      _log("Listening on port ${SadeemConstants.discoveryPort}...");

      _socket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? dg = _socket!.receive();
          if (dg != null) {
            String message = utf8.decode(dg.data);
            if (message == SadeemConstants.discoveryPayload) {
              _log("Discovery request received from ${dg.address.address}");
              _sendResponse(dg.address, dg.port);
            } else if (message.startsWith("SADEEM_RESPONSE:")) {
              _log("Response received from ${dg.address.address}");
              _handleResponse(message, dg.address.address);
            }
          }
        }
      }, onError: (e) {
        _log("Socket Error: $e");
      });
    } catch (e) {
      _log("Bind Error: ${e.toString()}");
    }
  }

  /// Sends a discovery request to the entire local network
  void broadcastDiscovery() async {
    try {
      if (_socket == null) await startListening();
      
      _log("Sending discovery pulse...");
      _socket!.send(
        utf8.encode(SadeemConstants.discoveryPayload),
        InternetAddress("255.255.255.255"), 
        SadeemConstants.discoveryPort,
      );
    } catch (e) {
      _log("Broadcast Error: $e");
    }
  }

  /// Responds to a discovery request so the requester knows we are here
  void _sendResponse(InternetAddress address, int port) {
    String response = "SADEEM_RESPONSE:Sadeem_User_${address.address.hashCode}";
    _socket!.send(utf8.encode(response), address, port);
    _log("Sent response to ${address.address}");
  }

  /// Processes the response from another peer and adds them to the discovery stream
  void _handleResponse(String message, String ip) {
    String deviceName = message.replaceFirst("SADEEM_RESPONSE:", "");
    Peer peer = Peer(
      id: deviceName,
      ipAddress: ip,
      deviceName: deviceName,
      lastSeen: DateTime.now(),
    );
    _discoveryController.add(peer);
    _log("Found peer: $deviceName");
  }

  void stop() {
    _socket?.close();
    _socket = null;
    _discoveryController.close();
    _statusController.close();
  }
}
