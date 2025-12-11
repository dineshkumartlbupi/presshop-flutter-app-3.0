import 'package:equatable/equatable.dart';

class AdminContactInfo extends Equatable {
  final String email;

  const AdminContactInfo({required this.email});

  @override
  List<Object> get props => [email];
}
