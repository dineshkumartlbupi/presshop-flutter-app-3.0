import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/verify_otp.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/social_register_user.dart';
import '../../domain/usecases/send_otp.dart';
import 'verification_event.dart';
import 'verification_state.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  final VerifyOtp verifyOtp;
  final RegisterUser registerUser;
  final SocialRegisterUser socialRegisterUser;
  final SendOtp sendOtp;

  VerificationBloc({
    required this.verifyOtp,
    required this.registerUser,
    required this.socialRegisterUser,
    required this.sendOtp,
  }) : super(VerificationInitial()) {
    on<VerifyOtpSubmitted>(_onVerifyOtpSubmitted);
    on<ResendOtpRequested>(_onResendOtpRequested);
    on<RegistrationRequested>(_onRegistrationRequested);
  }

  Future<void> _onVerifyOtpSubmitted(
    VerifyOtpSubmitted event,
    Emitter<VerificationState> emit,
  ) async {
    emit(VerificationLoading());
    final result = await verifyOtp(VerifyOtpParams(
      phone: event.phone,
      email: event.email,
      otp: event.otp,
    ));

    result.fold(
      (failure) => emit(VerificationError(failure.message)),
      (success) => emit(VerifyOtpSuccess()),
    );
  }

  Future<void> _onResendOtpRequested(
    ResendOtpRequested event,
    Emitter<VerificationState> emit,
  ) async {
    // Dont emit loading to avoid flicker of full screen loader?
    // Or do emit loading. Legacy showed nothing but cleared timer.
    // Let's emit nothing but snackbar logic via listener. 
    // Wait, we need to make the API call.
    final result = await sendOtp(RegisterParams(data: event.params));
    result.fold(
      (failure) => emit(VerificationError(failure.message)),
      (success) => emit(const ResendOtpSuccess("OTP sent successfully")),
    );
  }

  Future<void> _onRegistrationRequested(
    RegistrationRequested event,
    Emitter<VerificationState> emit,
  ) async {
    emit(VerificationLoading());
    
    final params = Map<String, dynamic>.from(event.params);
    if (event.imagePath != null && event.imagePath!.isNotEmpty) {
      params['_imagePath'] = event.imagePath;
    }

    if (event.isSocial) {
      final result = await socialRegisterUser(SocialRegisterParams(data: params));
      result.fold(
        (failure) => emit(VerificationError(failure.message)),
        (user) => emit(RegistrationSuccess(user)),
      );
    } else {
      final result = await registerUser(RegisterParams(data: params));
      result.fold(
        (failure) => emit(VerificationError(failure.message)),
        (user) => emit(RegistrationSuccess(user)),
      );
    }
  }
}
