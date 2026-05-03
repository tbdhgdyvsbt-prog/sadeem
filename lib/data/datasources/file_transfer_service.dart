import 'dart:io';
import 'dart:convert';
import 'dart:async';
import '../../domain/entities/file_message.dart';
import '../repositories/chat_repository.dart';

class FileTransferService {
  // Use a separate port for heavy file transfers to avoid blocking the chat
  static const int filePort = 8890;

  /// Sends a file to a peer
  Future<void> sendFile(String ipAddress, String filePath) async {
    File file = File(filePath);
    if (!await file.exists()) throw Exception("File not found");

    int fileSize = await file.length();
    String fileName = filePath.split('/').last;
    String fileExtension = fileName.split('.').last;

    // 1. Send metadata first so the receiver knows what's coming
    String metadata = "SADEEM_FILE_START:${fileName}|${fileExtension}|${fileSize}";
    
    try {
      Socket socket = await Socket.connect(ipAddress, filePort);
      socket.write(metadata);
      
      // Small delay to ensure metadata is processed
      await Future.delayed(const Duration(milliseconds: 100));

      // 2. Stream the file bytes
      await socket.addStream(file.openRead());
      await socket.flush();
      await socket.close();
      print("Sadeem Cargo: File $fileName sent successfully");
    } catch (e) {
      print("Sadeem Cargo Error: $e");
      rethrow;
    }
  }

  /// Starts a server to receive files from peers
  void startFileServer(Function(FileMessage) onFileReceived) {
    ServerSocket server = ServerSocket.bind(InternetAddress.anyIPv4, filePort);
    
    server.listen((Socket socket) {
      socket.listen(
        (List<int> data) async {
          // This is a simplified implementation. 
          // In a real app, we'd use a proper buffer to separate metadata from bytes.
          String header = utf8.decode(data);
          
          if (header.startsWith("SADEEM_FILE_START:")) {
            String metaPart = header.replaceFirst("SADEEM_FILE_START:", "");
            List<String> parts = metaPart.split('|');
            
            String fileName = parts[0];
            String extension = parts[1];
            int size = int.parse(parts[2]);
            
            // Create the local file and write the incoming stream
            String savePath = "/storage/emulated/0/Download/Sadeem/$fileName";
            File saveFile = File(savePath);
            
            // Ensure directory exists
            saveFile.parent.create(recursive: true);
            
            // Write the remaining data from the socket to the file
            // In a real implementation, we'd handle the stream more precisely
            await saveFile.writeAsBytes(data.sublist(header.length)); 
            
            onFileReceived(FileMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              senderId: "Remote_Peer",
              fileName: fileName,
              fileExtension: extension,
              fileSize: size,
              filePath: savePath,
              timestamp: DateTime.now(),
              isMe: true,
            ));
          }
        },
        onDone: () => socket.close(),
      );
    });
  }
}
