/// The interface for interacting with user authentication.
abstract class AuthenticationService {
  /// The user ID for the current user.
  String get userId;

  /// Ensures the user is authenticated.
  Future<String> authenticate();
}
