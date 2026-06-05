import 'package:flutter/material.dart';
import 'package:flutter_chrome_cast/entities/cast_media_status.dart';
import 'package:flutter_chrome_cast/enums.dart';
import 'package:flutter_chrome_cast/media.dart';
import 'package:flutter_chrome_cast/session.dart';

class MediaControls extends StatelessWidget {
  const MediaControls({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GoggleCastMediaStatus?>(
      stream: GoogleCastRemoteMediaClient.instance.mediaStatusStream,
      builder: (context, snapshot) {
        final isConnected =
            GoogleCastSessionManager.instance.connectionState ==
            GoogleCastConnectState.connected;

        // Si pas connecté, on masque les contrôles
        if (!isConnected) return const SizedBox.shrink();

        final mediaStatus = snapshot.data;
        final volume =
            GoogleCastSessionManager
                .instance
                .currentSession
                ?.currentDeviceVolume ??
            1.0;

        return Column(
          children: [
            // Boutons précédent / suivant
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Précédent
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.skip_previous_rounded),
                  onPressed: () async {
                    await GoogleCastRemoteMediaClient.instance.queuePrevItem();
                  },
                ),

                // Suivant
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.skip_next_rounded),
                  onPressed: () async {
                    await GoogleCastRemoteMediaClient.instance.queueNextItem();
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Barre de volume
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Icon(Icons.volume_down, size: 20),
                  Expanded(
                    child: Slider(
                      value: volume.clamp(0.0, 1.0),
                      min: 0.0,
                      max: 1.0,
                      onChanged: (value) {
                        GoogleCastSessionManager.instance.setDeviceVolume(
                          value,
                        );
                      },
                    ),
                  ),
                  const Icon(Icons.volume_up, size: 20),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
