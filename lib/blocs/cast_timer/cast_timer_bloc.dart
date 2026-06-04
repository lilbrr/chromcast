import 'dart:async';

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
      await _stopCasting();
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
    final connectState = GoogleCastSessionManager.instance.connectionState;
    if (connectState == GoogleCastConnectState.connected) {
      await GoogleCastSessionManager.instance.endSessionAndStopCasting();
    }
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
