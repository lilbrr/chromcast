import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';

part 'cast_session_event.dart';
part 'cast_session_state.dart';

class CastSessionBloc extends Bloc<CastSessionEvent, CastSessionState> {
  StreamSubscription? _sessionSubscription;

  CastSessionBloc() : super(CastSessionInitial()) {
    on<CastSessionStarted>(_onStarted);
    on<CastSessionDeviceSelected>(_onDeviceSelected);
    on<CastSessionDisconnectRequested>(_onDisconnectRequested);
    on<_CastSessionStateChanged>(_onSessionStateChanged);
  }

  // Démarre l'écoute du stream de session natif
  Future<void> _onStarted(
    CastSessionStarted event,
    Emitter<CastSessionState> emit,
  ) async {
    await _sessionSubscription?.cancel();

    _sessionSubscription = GoogleCastSessionManager
        .instance
        .currentSessionStream
        .listen((session) {
          add(_CastSessionStateChanged(session));
        });
  }

  // L'utilisateur a sélectionné un appareil dans la liste
  Future<void> _onDeviceSelected(
    CastSessionDeviceSelected event,
    Emitter<CastSessionState> emit,
  ) async {
    emit(CastSessionConnecting(event.device));
    try {
      await GoogleCastSessionManager.instance.startSessionWithDevice(
        event.device,
      );
      // Le résultat arrivera via _onSessionStateChanged
    } catch (e) {
      emit(CastSessionError('Impossible de se connecter : $e'));
    }
  }

  // L'utilisateur veut se déconnecter
  Future<void> _onDisconnectRequested(
    CastSessionDisconnectRequested event,
    Emitter<CastSessionState> emit,
  ) async {
    await GoogleCastSessionManager.instance.endSessionAndStopCasting();
  }

  // Le SDK natif nous notifie d'un changement d'état
  void _onSessionStateChanged(
    _CastSessionStateChanged event,
    Emitter<CastSessionState> emit,
  ) {
    final connectState = GoogleCastSessionManager.instance.connectionState;

    if (connectState == GoogleCastConnectState.connected) {
      final deviceName = event.session?.device?.friendlyName ?? 'Chromecast';
      emit(CastSessionConnected(deviceName));
    } else {
      emit(CastSessionDisconnected());
    }
  }

  @override
  Future<void> close() {
    _sessionSubscription?.cancel();
    return super.close();
  }
}
