import 'package:equatable/equatable.dart';

abstract class ActivitiesError extends Equatable {
  final String? code;
  final String? message;

  const ActivitiesError(this.code, this.message);
}

class GetRandomActivitiesError extends ActivitiesError {
  const GetRandomActivitiesError({
    String? code,
    String? message,
  }) : super(code, message);

  static GetRandomActivitiesError get unknown => const GetRandomActivitiesError(
        code: 'unknown',
        message: 'Unknown get random activities error.',
      );

  @override
  List<Object?> get props => [
        code,
        message,
      ];
}
