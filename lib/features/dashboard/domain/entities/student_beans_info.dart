import 'package:equatable/equatable.dart';

class StudentBeansInfo extends Equatable {
  const StudentBeansInfo(
      {this.shouldShow = false,
      this.heading = "",
      this.description = "",
      this.activationUrl = ""});
  final bool shouldShow;
  final String heading;
  final String description;
  final String activationUrl;

  @override
  List<Object?> get props => [shouldShow, heading, description, activationUrl];
}
