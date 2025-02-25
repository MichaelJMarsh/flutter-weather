import 'package:domain/src/model/user_settings.dart';

/// The interface for interacting with the user settings on a remote database.
abstract class RemoteSettingsService {
  /// Fetches the user settings from a remote database.
  Future<UserSettings> fetchSettings(String userId);

  /// Saves the user settings to a remote database.
  Future<void> saveSettings(String userId, UserSettings settings);
}
