import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../domain/entities/peer.dart';
import '../../domain/entities/message.dart';
import '../manager/chat_manager.dart';

class ChatScreen extends StatelessWidget {
  final Peer peer;
  final ChatManager chatManager;

  const ChatScreen({super.key, required this.peer, required this.chatManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SadeemColors.deepSpace,
      appBar: AppBar(
        backgroundColor: SadeemColors.nebulaPurple.withOpacity(0.5),
        title: Text(peer.deviceName, style: const TextStyle(color: SadeemColors.starWhite)),
        iconTheme: const IconThemeData(color: SadeemColors.starWhite),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<Message>(
              stream: chatManager.messageStream,
              builder: (context, snapshot) {
                final messages = chatManager.getMessagesForPeer(peer.id);
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return ChatBubble(message: msg);
                  },
                );
              },
            ),
          ),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    final controller = TextEditingController();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: SadeemColors.nebulaPurple.withOpacity(0.2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: SadeemColors.starWhite),
              decoration: InputDecoration(
                hintText: "Send a galactic message...",
                hintStyle: TextStyle(color: SadeemColors.starWhite.withOpacity(0.5)),
                filled: true,
                fillColor: SadeemColors.deepSpace,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: SadeemColors.neonCyan),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: SadeemColors.neonCyan,
            onPressed: () {
              if (controller.text.isNotEmpty) {
                chatManager.sendMessage(peer.id, controller.text);
                controller.clear();
              }
            },
            child: const Icon(Icons.send, color: SadeemColors.deepSpace),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final Message message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? SadeemColors.nebulaPurple : SadeemColors.deepSpace,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isMe ? SadeemColors.cosmicPink : SadeemColors.neonCyan),
          boxShadow: [
            BoxShadow(
              color: isMe ? SadeemColors.cosmicPink.withOpacity(0.3) : SadeemColors.neonCyan.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          message.text,
          style: const TextStyle(color: SadeemColors.starWhite),
        ),
      ),
    );
  }
}
