import 'dart:io';
import 'dart:convert';
import 'dart:async';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/peer.dart';

class P2PDiscoveryService {
  RawDatagramSocket? _socket;
  final StreamController<Peer> _discoveryController = StreamController<Peer>.broadcast();

  Stream<Peer> get discoveredPeers => _discoveryController.stream;

  /// Starts listening for discovery requests from other peers
  Future<void> startListening() async {
    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, SadeemConstants.discoveryPort);
      print("Sadeem Radar: Listening on port ${SadeemConstants.discoveryPort}...");

      _socket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? dg = _socket!.receive();
          if (dg != null) {
            String message = utf8.decode(dg.data);
            if (message == SadeemConstants.discoveryPayload) {
              print("Sadeem Radar: Discovery request received from ${dg.address.address}");
              _sendResponse(dg.address, dg.port);
            } else if (message.startsWith("SADEEM_RESPONSE:")) {
              _handleResponse(message, dg.address.address);
            }
          }
        }
      });
    } catch (e) {
      print("Sadeem Radar Error: ${e.toString()}");
    }
  }

  /// Sends a discovery request to the entire local network
  void broadcastDiscovery() async {
    if (_socket == null) await startListening();
    
    print("Sadeem Radar: Sending discovery pulse...");
    _socket!.send(
      utf8.encode(SadeemConstants.discoveryPayload),
      InternetAddress("255.255.255.255"), 
      SadeemConstants.discoveryPort,
    );
  }

  /// Responds to a discovery request so the requester knows we are here
  void _sendResponse(InternetAddress address, int port) {
    // In a real app, we would send device name and a unique ID here
    String response = "SADEEM_RESPONSE:Sadeem_User_${address.address.hashCode}";
    _socket!.send(utf8.encode(response), address, port);
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
  }

  void stop() {
    _socket?.close();
    _discoveryController.close();
  }
}
