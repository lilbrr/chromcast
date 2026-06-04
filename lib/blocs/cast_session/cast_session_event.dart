part of 'cast_session_bloc.dart';

abstract class CastSessionEvent {}

// Démarre l'écoute de la session Cast (appelé au lancement de l'app)
class CastSessionStarted extends CastSessionEvent {}

// L'utilisateur veut se connecter à un appareil
class CastSessionDeviceSelected extends CastSessionEvent {
  final GoogleCastDevice device;
  CastSessionDeviceSelected(this.device);
}

// L'utilisateur veut se déconnecter
class CastSessionDisconnectRequested extends CastSessionEvent {}

// Événement interne : la session a changé d'état (connecté, déconnecté...)
class _CastSessionStateChanged extends CastSessionEvent {
  final GoogleCastSession? session;
  _CastSessionStateChanged(this.session);
}
