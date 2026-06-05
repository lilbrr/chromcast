import 'package:flutter/material.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';

class MediaPreview extends StatelessWidget {
  const MediaPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GoggleCastMediaStatus?>(
      stream: GoogleCastRemoteMediaClient.instance.mediaStatusStream,
      builder: (context, snapshot) {
        final isConnected =
            GoogleCastSessionManager.instance.connectionState ==
            GoogleCastConnectState.connected;

        if (!isConnected) {
          return _EmptyPreview(
            message: 'Connecte-toi à un Chromecast\npour commencer',
            icon: Icons.cast,
          );
        }

        final mediaStatus = snapshot.data;

        // Connecté mais rien ne joue
        if (mediaStatus == null) {
          return _EmptyPreview(
            message: 'Lance une vidéo depuis\nYouTube, Netflix...',
            icon: Icons.play_circle_outline,
          );
        }

        final metadata = mediaStatus.mediaInformation?.metadata;
        final title = metadata?.extractedTitle ?? 'Lecture en cours';
        final subtitle = metadata?.extractedSubtitle ?? '';
        final imageUrl = metadata?.images?.isNotEmpty == true
            ? metadata!.images!.first.url
            : null;

        final isPlaying =
            mediaStatus.playerState == CastMediaPlayerState.playing;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Miniature
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl as String,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _PlaceholderImage(),
                        )
                      : _PlaceholderImage(),
                ),
              ),

              // Infos + état
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Icône play/pause
                    Icon(
                      isPlaying
                          ? Icons.play_circle_filled
                          : Icons.pause_circle_filled,
                      color: Colors.white70,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    // Titre et sous-titre
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle.isNotEmpty)
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  final String message;
  final IconData icon;

  const _EmptyPreview({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Icon(Icons.movie, size: 48, color: Colors.white24),
      ),
    );
  }
}
