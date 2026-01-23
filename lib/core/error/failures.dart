import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({required this.message});
  final String message;

  @override
  List<Object> get props => [message];
}

class UsernameAlreadyExistsFailure extends Failure {
  const UsernameAlreadyExistsFailure({required super.message});
}

// General Failures
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No Internet Connection'});
}

class UserNotRegisteredFailure extends Failure {
  const UserNotRegisteredFailure({required super.message});
}

class LocationFailure extends Failure {
  const LocationFailure({required super.message});
}
