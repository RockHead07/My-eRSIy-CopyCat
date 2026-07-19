import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Observer global BLoC untuk keperluan debugging.
///
/// Setiap perubahan state, event, error, maupun transisi akan
/// dicetak ke console (hanya di mode debug). Di production build,
/// [kDebugMode] bernilai `false` sehingga tidak ada output apapun
/// dan tidak mempengaruhi performa.
///
/// Cara membaca log:
///  • [onChange]   → state berubah (Cubit)
///  • [onTransition] → event -> state (Bloc penuh)
///  • [onError]    → ada exception di dalam Cubit/Bloc
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      debugPrint(
        '[BLoC] ${bloc.runtimeType} '
        '| ${change.currentState} → ${change.nextState}',
      );
    }
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      debugPrint(
        '[BLoC] ${bloc.runtimeType} '
        '| event: ${transition.event} '
        '| ${transition.currentState} → ${transition.nextState}',
      );
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('[BLoC ERROR] ${bloc.runtimeType}: $error\n$stackTrace');
    }
    super.onError(bloc, error, stackTrace);
  }
}
