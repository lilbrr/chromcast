import 'package:flutter/material.dart';

import '../widgets/app_launcher_row.dart';
import '../widgets/cast_connect_button.dart';
import '../widgets/media_controls.dart';
import '../widgets/media_preview.dart';
import '../widgets/timer_button.dart';
import '../widgets/timer_display.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Bouton de connexion Chromecast en haut à droite
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: CastConnectButton()),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Ligne timer : bouton roue + affichage décompte
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: const [
                  TimerButton(),
                  SizedBox(width: 16),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TimerDisplay(),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Préview du média en cours
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: MediaPreview(),
            ),

            // Contrôles : précédent, volume, suivant
            const MediaControls(),

            const Spacer(),

            const Divider(height: 1),

            // Boutons apps en bas
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: AppLauncherRow(),
            ),
          ],
        ),
      ),
    );
  }
}
