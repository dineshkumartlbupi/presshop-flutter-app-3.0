import 'package:flutter_bloc/flutter_bloc.dart';
import 'signup_event.dart';
import 'signup_state.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/check_username.dart';
import '../../domain/usecases/check_email.dart';
import '../../domain/usecases/check_phone.dart';
import '../../domain/usecases/get_avatars.dart';
import '../../domain/usecases/verify_referral_code.dart';
import '../../domain/usecases/social_exists.dart';
import '../../domain/usecases/social_register_user.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final RegisterUser registerUser;
  final SendOtp sendOtp;
  final CheckUserName checkUserName;
  final CheckEmail checkEmail;
  final CheckPhone checkPhone;
  final GetAvatars getAvatars;
  final VerifyReferralCode verifyReferralCode;
  final SocialExists socialExists;
  final SocialRegisterUser socialRegisterUser;

  SignUpBloc({
    required this.registerUser,
    required this.sendOtp,
    required this.checkUserName,
    required this.checkEmail,
    required this.checkPhone,
    required this.getAvatars,
    required this.verifyReferralCode,
    required this.socialExists,
    required this.socialRegisterUser,
  }) : super(SignUpInitial()) {
    on<SignUpSubmitted>(_onSignUpSubmitted);
    on<SocialSignUpSubmitted>(_onSocialSignUpSubmitted);
    on<CheckUserNameEvent>(_onCheckUserName);
    on<CheckEmailEvent>(_onCheckEmail);
    on<CheckPhoneEvent>(_onCheckPhone);
    on<FetchAvatarsEvent>(_onFetchAvatars);
    on<VerifyReferralCodeEvent>(_onVerifyReferralCode);
    on<CheckSocialExistsEvent>(_onCheckSocialExists);
  }

  Future<void> _onSocialSignUpSubmitted(
    SocialSignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    emit(SignUpLoading());
    final result = await socialRegisterUser(SocialRegisterParams(data: event.data));
    result.fold(
      (failure) => emit(SignUpError(message: failure.message)),
      (user) => emit(SignUpSuccess(user: user)),
    );
  }

  Future<void> _onSignUpSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    emit(SignUpLoading());
    final result = await sendOtp(RegisterParams(data: event.data));
    result.fold(
      (failure) => emit(SignUpError(message: failure.message)),
      (success) {
        emit(SignUpOtpSent(data: event.data));
      },
    );
  }

  Future<void> _onCheckUserName(
    CheckUserNameEvent event,
    Emitter<SignUpState> emit,
  ) async {
    final result = await checkUserName(event.userName);
    result.fold(
      (failure) => emit(SignUpError(message: failure.message)),
      (isAvailable) => emit(UserNameCheckResult(isAvailable)),
    );
  }

  Future<void> _onCheckEmail(
    CheckEmailEvent event,
    Emitter<SignUpState> emit,
  ) async {
    final result = await checkEmail(event.email);
    result.fold(
      (failure) => emit(SignUpError(message: failure.message)),
      (isAvailable) => emit(EmailCheckResult(isAvailable)),
    );
  }

  Future<void> _onCheckPhone(
    CheckPhoneEvent event,
    Emitter<SignUpState> emit,
  ) async {
    final result = await checkPhone(event.phone);
    result.fold(
      (failure) => emit(SignUpError(message: failure.message)),
      (isAvailable) => emit(PhoneCheckResult(isAvailable)),
    );
  }

  Future<void> _onFetchAvatars(
    FetchAvatarsEvent event,
    Emitter<SignUpState> emit,
  ) async {
    final result = await getAvatars(NoParams());
    result.fold(
      (failure) => emit(SignUpError(message: failure.message)),
      (avatars) => emit(AvatarsLoaded(avatars)),
    );
  }

  Future<void> _onVerifyReferralCode(
    VerifyReferralCodeEvent event,
    Emitter<SignUpState> emit,
  ) async {
    final result = await verifyReferralCode(event.code);
    result.fold(
      (failure) => emit(SignUpError(message: failure.message)),
      (data) => emit(ReferralCodeVerified(data)),
    );
  }

  Future<void> _onCheckSocialExists(
    CheckSocialExistsEvent event,
    Emitter<SignUpState> emit,
  ) async {
    final result = await socialExists(event.params);
    result.fold(
      (failure) => emit(SignUpError(message: failure.message)),
      (exists) => emit(SocialExistsChecked(exists)),
    );
  }
}
