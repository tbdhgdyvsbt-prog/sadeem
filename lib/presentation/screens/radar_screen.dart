import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../domain/entities/peer.dart';
import '../../data/datasources/p2p_discovery_service.dart';
import 'space_background.dart';

class RadarScreen extends StatefulWidget {
  final Function(Peer) onPeerSelected;
  const RadarScreen({super.key, required this.onPeerSelected});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> with SingleTickerProviderStateMixin {
  final P2PDiscoveryService _discoveryService = P2PDiscoveryService();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _discoveryService.startListening();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _discoveryService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SpaceBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Discovery Radar", style: TextStyle(color: SadeemColors.starWhite)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulsing Radar Ring
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 200 * _pulseController.value,
                          height: 200 * _pulseController.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: SadeemColors.neonCyan.withOpacity(1 - _pulseController.value),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),
                    // Center Radar Core
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [SadeemColors.neonCyan, SadeemColors.nebulaPurple],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: SadeemColors.neonCyan.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.radar, color: SadeemColors.starWhite, size: 40),
                    ),
                  ],
                ),
              ),
            ),
            _buildPeerList(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: SadeemColors.neonCyan,
          onPressed: () => _discoveryService.broadcastDiscovery(),
          child: const Icon(Icons.send, color: SadeemColors.deepSpace),
        ),
      ),
    );
  }

  Widget _buildPeerList() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SadeemColors.deepSpace.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border(top: BorderSide(color: SadeemColors.neonCyan.withOpacity(0.3))),
      ),
      child: StreamBuilder<Peer>(
        stream: _discoveryService.discoveredPeers,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text("Searching for cosmic entities...", 
              style: TextStyle(color: SadeemColors.starWhite, fontSize: 16)),
            );
          }
          
          // Note: In a real app, we would maintain a list of peers.
          // For this demo, we'll just show the latest discovered peer.
          final peer = snapshot.data!;
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: SadeemColors.nebulaPurple,
              child: Icon(Icons.person, color: SadeemColors.starWhite),
            ),
            title: Text(peer.deviceName, style: const TextStyle(color: SadeemColors.starWhite)),
            subtitle: Text(peer.ipAddress, style: const TextStyle(color: SadeemColors.starWhite54)),
            trailing: const Icon(Icons.chevron_right, color: SadeemColors.neonCyan),
            onTap: () => widget.onPeerSelected(peer),
          );
        },
      ),
    );
  }
}
