// Entity representing a file transfer in a chat
class FileMessage {
  final String id;
  final String senderId;
  final String fileName;
  final String fileExtension;
  final int fileSize;
  final String filePath; // Path where the file is stored locally
  final DateTime timestamp;
  final bool isMe;

  FileMessage({
    required this.id,
    required this.senderId,
    required this.fileName,
    required this.fileExtension,
    required this.fileSize,
    required this.filePath,
    required this.timestamp,
    required this.isMe,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'fileName': fileName,
    'fileExtension': fileExtension,
    'fileSize': fileSize,
    'filePath': filePath,
    'timestamp': timestamp.toIso8601String(),
    'isMe': isMe,
  };

  factory FileMessage.fromJson(Map<String, dynamic> json) => FileMessage(
    id: json['id'],
    senderId: json['senderId'],
    fileName: json['fileName'],
    fileExtension: json['fileExtension'],
    fileSize: json['fileSize'],
    filePath: json['filePath'],
    timestamp: DateTime.parse(json['timestamp']),
    isMe: json['isMe'],
  );
}
