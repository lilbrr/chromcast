import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/cast_timer/cast_timer_bloc.dart';

class TimerButton extends StatelessWidget {
  const TimerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CastTimerBloc, CastTimerState>(
      builder: (context, state) {
        final isRunning = state is CastTimerRunning;

        return ElevatedButton.icon(
          onPressed: () =>
              isRunning ? _showCancelDialog(context) : _showTimePicker(context),
          icon: Icon(isRunning ? Icons.timer_off : Icons.timer, size: 18),
          label: Text(isRunning ? 'Annuler timer' : 'Set timer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isRunning ? Colors.red[400] : null,
            foregroundColor: isRunning ? Colors.white : null,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        );
      },
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final bloc = context.read<CastTimerBloc>();

    // Roue style Android native
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 1, minute: 0),
      initialEntryMode: TimePickerEntryMode.dialOnly,
      helpText: 'Durée du minuteur',
      confirmText: 'Lancer',
      cancelText: 'Annuler',
      builder: (context, child) {
        // Force le format 24h pour avoir 0-23h sur la roue
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final duration = Duration(hours: picked.hour, minutes: picked.minute);
      // Sécurité : on refuse un timer à 0
      if (duration.inSeconds > 0) {
        bloc.add(CastTimerStarted(duration));
      }
    }
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Annuler le timer ?'),
        content: const Text(
          'Le Chromecast continuera à jouer mais ne s\'arrêtera plus automatiquement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Garder'),
          ),
          TextButton(
            onPressed: () {
              context.read<CastTimerBloc>().add(CastTimerCancelled());
              Navigator.pop(context);
            },
            child: const Text(
              'Annuler le timer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
