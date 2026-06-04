part of 'cast_timer_bloc.dart';

abstract class CastTimerState {}

// Pas de timer actif
class CastTimerInitial extends CastTimerState {}

// Timer en cours — expose le temps restant
class CastTimerRunning extends CastTimerState {
  final Duration remaining;
  CastTimerRunning(this.remaining);
}

// Timer terminé — a déclenché l'arrêt du cast
class CastTimerExpired extends CastTimerState {}

// Timer annulé par l'utilisateur
class CastTimerStopped extends CastTimerState {}
