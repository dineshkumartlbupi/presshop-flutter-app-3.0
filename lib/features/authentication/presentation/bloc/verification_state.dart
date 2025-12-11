import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class VerificationState extends Equatable {
  const VerificationState();
  
  @override
  List<Object> get props => [];
}

class VerificationInitial extends VerificationState {}

class VerificationLoading extends VerificationState {}

class VerifyOtpSuccess extends VerificationState {}

class ResendOtpSuccess extends VerificationState {
  final String message;
  const ResendOtpSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class RegistrationSuccess extends VerificationState {
  final User user;
  final bool isSourceDataOpened; // Legacy flags
  final String sourceDataType;

  const RegistrationSuccess(this.user, {
      this.isSourceDataOpened = false,
      this.sourceDataType = '',
  });

  @override
  List<Object> get props => [user, isSourceDataOpened, sourceDataType];
}

class VerificationError extends VerificationState {
  final String message;
  const VerificationError(this.message);

  @override
  List<Object> get props => [message];
}
