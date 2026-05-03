// Entity representing a discovered peer in the network
class Peer {
  final String id;
  final String ipAddress;
  final String deviceName;
  final DateTime lastSeen;

  Peer({
    required this.id,
    required this.ipAddress,
    required this.deviceName,
    required this.lastSeen,
  });

  // Unique identifier for the peer to avoid duplicates in the list
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Peer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() => {
    'id': id,
    'ipAddress': ipAddress,
    'deviceName': deviceName,
    'lastSeen': lastSeen.toIso8601String(),
  };

  factory Peer.fromJson(Map<String, dynamic> json) => Peer(
    id: json['id'],
    ipAddress: json['ipAddress'],
    deviceName: json['deviceName'],
    lastSeen: DateTime.parse(json['lastSeen']),
  );
}
