import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'cast_session_event.dart';
part 'cast_session_state.dart';

class CastSessionBloc extends Bloc<CastSessionEvent, CastSessionState> {
  CastSessionBloc() : super(CastSessionInitial()) {
    on<CastSessionEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
