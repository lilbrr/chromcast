import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';

part 'cast_timer_event.dart';
part 'cast_timer_state.dart';

class CastTimerBloc extends Bloc<CastTimerEvent, CastTimerState> {
  Timer? _ticker;

  CastTimerBloc() : super(CastTimerInitial()) {
    on<CastTimerStarted>(_onStarted);
    on<_CastTimerTicked>(_onTicked);
    on<CastTimerCancelled>(_onCancelled);
  }

  Future<void> _onStarted(
    CastTimerStarted event,
    Emitter<CastTimerState> emit,
  ) async {
    _ticker?.cancel();
    emit(CastTimerRunning(event.duration));

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state;
      if (current is CastTimerRunning) {
        final newRemaining = current.remaining - const Duration(seconds: 1);
        add(_CastTimerTicked(newRemaining));
      }
    });
  }

  Future<void> _onTicked(
    _CastTimerTicked event,
    Emitter<CastTimerState> emit,
  ) async {
    if (event.remaining.inSeconds <= 0) {
      _ticker?.cancel();
      debugPrint('⏰ Timer expiré — tentative arrêt Cast');
      await _stopCasting();
      debugPrint('⏰ Stop casting appelé');
      emit(CastTimerExpired());
    } else {
      emit(CastTimerRunning(event.remaining));
    }
  }

  void _onCancelled(CastTimerCancelled event, Emitter<CastTimerState> emit) {
    _ticker?.cancel();
    emit(CastTimerStopped());
  }

  Future<void> _stopCasting() async {
    try {
      debugPrint('⏰ Timer expiré — tentative arrêt Cast');
      // D'abord on se connecte à l'appareil pour prendre le contrôle
      final device = GoogleCastDiscoveryManager.instance.devices.first;
      await GoogleCastSessionManager.instance.startSessionWithDevice(device);

      // Petit délai pour laisser la connexion s'établir
      await Future.delayed(const Duration(seconds: 2));

      // Puis on coupe
      await GoogleCastSessionManager.instance.endSessionAndStopCasting();
      debugPrint('⏰ Stop casting appelé');
    } catch (e) {
      debugPrint('Erreur stop casting: $e');
    }
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
