import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppLauncherRow extends StatelessWidget {
  const AppLauncherRow({super.key});

  // Définition des apps avec leur deep link et fallback Play Store
  static const _apps = [
    _AppConfig(
      label: 'Crunchyroll',
      deepLink: 'crunchyroll://',
      fallbackUrl:
          'https://play.google.com/store/apps/details?id=com.crunchyroll.crunchyroid',
      backgroundColor: Color(0xFFF47521),
      textColor: Colors.white,
    ),
    _AppConfig(
      label: 'Canal+',
      deepLink: 'canalplus://',
      fallbackUrl:
          'https://play.google.com/store/apps/details?id=com.canalplus.mycanal',
      backgroundColor: Color(0xFF003087),
      textColor: Colors.white,
    ),
    _AppConfig(
      label: 'Netflix',
      deepLink: 'netflix://',
      fallbackUrl:
          'https://play.google.com/store/apps/details?id=com.netflix.mediaclient',
      backgroundColor: Color(0xFFE50914),
      textColor: Colors.white,
    ),
    _AppConfig(
      label: 'YouTube',
      deepLink: 'youtube://',
      fallbackUrl:
          'https://play.google.com/store/apps/details?id=com.google.android.youtube',
      backgroundColor: Colors.white,
      textColor: Colors.black87,
    ),
  ];

  Future<void> _launchApp(_AppConfig app, BuildContext context) async {
    final deepLinkUri = Uri.parse(app.deepLink);
    final fallbackUri = Uri.parse(app.fallbackUrl);

    // Essaie d'abord d'ouvrir l'app via deep link
    if (await canLaunchUrl(deepLinkUri)) {
      await launchUrl(deepLinkUri);
    } else {
      // App non installée → ouvre le Play Store
      if (await canLaunchUrl(fallbackUri)) {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Impossible d\'ouvrir ${app.label}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _apps
            .map(
              (app) =>
                  _AppButton(app: app, onTap: () => _launchApp(app, context)),
            )
            .toList(),
      ),
    );
  }
}

class _AppButton extends StatelessWidget {
  final _AppConfig app;
  final VoidCallback onTap;

  const _AppButton({required this.app, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 40,
        decoration: BoxDecoration(
          color: app.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: app.backgroundColor == Colors.white
              ? Border.all(color: Colors.grey[300]!)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            app.label,
            style: TextStyle(
              color: app.textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

// Modèle de configuration d'une app
class _AppConfig {
  final String label;
  final String deepLink;
  final String fallbackUrl;
  final Color backgroundColor;
  final Color textColor;

  const _AppConfig({
    required this.label,
    required this.deepLink,
    required this.fallbackUrl,
    required this.backgroundColor,
    required this.textColor,
  });
}
