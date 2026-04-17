import 'package:equatable/equatable.dart';

/// Abstract [Failure] hierarchy used in the domain layer.
///
/// Repository methods return [Failure] objects instead of throwing exceptions,
/// allowing use-cases to handle errors declaratively.
sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

final class FirestoreFailure extends Failure {
  const FirestoreFailure(super.message);
}

final class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

final class GeneralFailure extends Failure {
  const GeneralFailure([super.message = 'An unexpected error occurred.']);
}

final class PermissionFailure extends Failure {
  const PermissionFailure(
      [super.message =
          'You do not have permission to perform this action.']);
}
