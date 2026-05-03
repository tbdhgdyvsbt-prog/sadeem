import 'package:flutter/material.dart';
import 'presentation/screens/radar_screen.dart';
import 'presentation/screens/chat_screen.dart';
import 'presentation/manager/chat_manager.dart';
import 'core/theme/colors.dart';

void main() {
  runApp(const SadeemApp());
}

class SadeemApp extends StatelessWidget {
  const SadeemApp({super.key});

  @override
  Widget build(BuildContext context) {
    final chatManager = ChatManager();

    return MaterialApp(
      title: 'Sadeem',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: SadeemColors.nebulaPurple,
        scaffoldBackgroundColor: SadeemColors.deepSpace,
      ),
      home: RadarScreen(
        onPeerSelected: (peer) {
          chatManager.connectToPeer(peer);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatScreen(peer: peer, chatManager: chatManager),
            ),
          );
        },
      ),
    );
  }
}
