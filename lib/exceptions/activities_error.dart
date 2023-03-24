import 'package:equatable/equatable.dart';

abstract class ActivitiesError extends Equatable {
  final String? code;
  final String? message;

  const ActivitiesError(this.code, this.message);
}

class GetActivitiesError extends ActivitiesError {
  const GetActivitiesError({
    String? code,
    String? message,
  }) : super(code, message);

  static GetActivitiesError get unknown => const GetActivitiesError(
        code: 'unknown',
        message: 'Unknown get random activities error.',
      );

  @override
  List<Object?> get props => [
        code,
        message,
      ];
}
