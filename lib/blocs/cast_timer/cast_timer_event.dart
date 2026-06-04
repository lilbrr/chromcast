part of 'cast_timer_bloc.dart';

abstract class CastTimerEvent {}

// L'utilisateur a défini une durée et lance le timer
class CastTimerStarted extends CastTimerEvent {
  final Duration duration;
  CastTimerStarted(this.duration);
}

// Tick interne chaque seconde
class _CastTimerTicked extends CastTimerEvent {
  final Duration remaining;
  _CastTimerTicked(this.remaining);
}

// L'utilisateur annule le timer
class CastTimerCancelled extends CastTimerEvent {}
