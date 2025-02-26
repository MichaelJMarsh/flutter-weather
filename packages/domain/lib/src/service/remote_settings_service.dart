import 'package:domain/src/model/user_settings.dart';

/// The interface for interacting with the user settings on a remote database.
abstract class RemoteSettingsService {
  /// Returns the current user settings.
  UserSettings get userSettings;

  /// The stream of user settings changes.
  Stream<UserSettings> get userSettingsStream;

  /// Initializes the service, by fetching the user settings for the given user
  /// and subscribing to changes.
  Future<void> initialize();

  /// Removes all resources used by the service.
  void dispose();

  /// Fetches the user settings from a remote database.
  Future<UserSettings> get();

  /// Saves the user settings to a remote database.
  Future<void> update(UserSettings Function(UserSettings) updateFunction);
}
