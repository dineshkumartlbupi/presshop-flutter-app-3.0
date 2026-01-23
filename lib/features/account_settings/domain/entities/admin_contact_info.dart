import 'package:equatable/equatable.dart';

class AdminContactInfo extends Equatable {
  const AdminContactInfo({required this.email});
  final String email;

  @override
  List<Object> get props => [email];
}
