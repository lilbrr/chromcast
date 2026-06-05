import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/cast_timer/cast_timer_bloc.dart';

class TimerDisplay extends StatelessWidget {
  const TimerDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CastTimerBloc, CastTimerState>(
      // BlocConsumer car on veut aussi réagir aux événements (snackbar)
      listener: (context, state) {
        if (state is CastTimerExpired) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⏰ Timer expiré — Chromecast arrêté. Bonne nuit !'),
              duration: Duration(seconds: 4),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is CastTimerRunning) {
          return _RunningDisplay(remaining: state.remaining);
        }

        if (state is CastTimerExpired) {
          return _StatusChip(
            icon: Icons.check_circle,
            label: 'Cast arrêté',
            color: Colors.grey,
          );
        }

        // Initial ou annulé → rien à afficher
        return const SizedBox.shrink();
      },
    );
  }
}

// Affichage du décompte actif
class _RunningDisplay extends StatelessWidget {
  final Duration remaining;
  const _RunningDisplay({required this.remaining});

  String _format(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    // Devient rouge dans les 5 dernières minutes
    final isUrgent = remaining.inMinutes < 5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.timer,
          size: 16,
          color: isUrgent ? Colors.red : Colors.orange,
        ),
        const SizedBox(width: 4),
        Text(
          _format(remaining),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: isUrgent ? Colors.red : Colors.orange,
          ),
        ),
      ],
    );
  }
}

// Chip statut (expiré)
class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
