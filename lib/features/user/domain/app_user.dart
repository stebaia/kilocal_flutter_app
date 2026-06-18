import 'package:equatable/equatable.dart';

/// Authenticated user returned by `GET /users/me`.
///
/// `id` is `myId` and is used as a variable for most GraphQL profile/percorso
/// queries.
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.roleName,
  });

  final String id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? roleName;

  String? get displayName {
    final buffer = StringBuffer();
    if (firstName != null && firstName!.isNotEmpty) buffer.write(firstName);
    if (lastName != null && lastName!.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(lastName);
    }
    return buffer.isEmpty ? null : buffer.toString();
  }

  @override
  List<Object?> get props => [id, email, firstName, lastName, roleName];
}
