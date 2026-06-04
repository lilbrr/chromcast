part of 'cast_session_bloc.dart';

abstract class CastSessionState {}

// État initial, pas encore de session
class CastSessionInitial extends CastSessionState {}

// En cours de connexion à un appareil
class CastSessionConnecting extends CastSessionState {
  final GoogleCastDevice device;
  CastSessionConnecting(this.device);
}

// Connecté — on expose le nom de l'appareil
class CastSessionConnected extends CastSessionState {
  final String deviceName;
  CastSessionConnected(this.deviceName);
}

// Déconnecté
class CastSessionDisconnected extends CastSessionState {}

// Erreur de connexion
class CastSessionError extends CastSessionState {
  final String message;
  CastSessionError(this.message);
}
