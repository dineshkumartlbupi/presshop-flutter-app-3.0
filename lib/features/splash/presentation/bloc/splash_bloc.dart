import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../../../authentication/domain/usecases/check_auth_status.dart';
import '../../../authentication/domain/usecases/get_profile.dart'; 
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final CheckAuthStatus checkAuthStatus;
  final GetProfile getProfile;

  SplashBloc({
    required this.checkAuthStatus,
    required this.getProfile,
  }) : super(SplashInitial()) {
    on<AppStarted>((event, emit) async {
      emit(SplashLoading());
      await Future.delayed(const Duration(seconds: 2)); // Artificial delay
      
      final result = await checkAuthStatus(NoParams());
      await result.fold(
        (failure) async => emit(SplashUnauthenticated()), 
        (isLoggedIn) async {
          if (isLoggedIn) {
             final profileResult = await getProfile(NoParams());
             profileResult.fold(
               (failure) => emit(SplashUnauthenticated()), // Token maybe expired
               (user) => emit(SplashAuthenticated()),
             );
          } else {
             emit(SplashUnauthenticated());
          }
        },
      );
    });
  }
}
