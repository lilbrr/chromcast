import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';

class CastTimerService {
  Timer? _timer;
  Duration _remaining = const Duration(hours: 1);

  // Démarre le décompte
  void startTimer({
    Duration duration = const Duration(hours: 1),
    VoidCallback? onTick, // appelé chaque seconde pour mettre à jour l'UI
    VoidCallback? onExpired, // appelé quand le timer expire
  }) {
    _remaining = duration;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remaining -= const Duration(seconds: 1);
      onTick?.call();

      if (_remaining.inSeconds <= 0) {
        timer.cancel();
        _stopCasting();
        onExpired?.call();
      }
    });
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Duration get remaining => _remaining;
  bool get isRunning => _timer?.isActive ?? false;

  Future<void> _stopCasting() async {
    // Vérifie qu'une session est active avant d'essayer de la couper
    final state = GoogleCastSessionManager.instance.connectionState;
    if (state == GoogleCastConnectState.ConnectionStateConnected) {
      await GoogleCastSessionManager.instance.endSessionAndStopCasting();
    }
  }
}
