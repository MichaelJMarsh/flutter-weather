import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

/// The implementation of the [RemoteSettingsService] with Firestore.
class FirestoreSettingsPlugin implements RemoteSettingsService {
  /// Creates a new [FirestoreSettingsPlugin].
  const FirestoreSettingsPlugin({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// The collection reference for the users.
  CollectionReference get _usersCollection {
    return _firestore.collection(UserSettingsField.users);
  }

  @override
  Future<UserSettings> fetchSettings(String userId) async {
    final doc =
        await _usersCollection
            .doc(userId)
            .collection(UserSettingsField.settings)
            .doc(UserSettingsField.userSettings)
            .get();

    if (!doc.exists) {
      return const UserSettings(
        themeMode: ThemeMode.light,
        timeFormat: TimeFormat.twentyFourHour,
        temperatureUnit: TemperatureUnit.celsius,
      );
    }

    final data = doc.data() as Map<String, dynamic>;
    return UserSettings(
      themeMode: ThemeMode.fromName(
        data[UserSettingsField.themeMode] as String?,
      ),
      timeFormat: TimeFormat.fromName(
        data[UserSettingsField.timeFormat] as String?,
      ),
      temperatureUnit: TemperatureUnit.fromName(
        data[UserSettingsField.temperatureUnit] as String?,
      ),
    );
  }

  @override
  Future<void> saveSettings(String userId, UserSettings settings) async {
    final data = {
      UserSettingsField.themeMode: settings.themeMode.name,
      UserSettingsField.timeFormat: settings.timeFormat.name,
      UserSettingsField.temperatureUnit: settings.temperatureUnit.name,
    };

    await _usersCollection
        .doc(userId)
        .collection(UserSettingsField.settings)
        .doc(UserSettingsField.userSettings)
        .set(data, SetOptions(merge: true));
  }
}

/// Contains the field names for the Firestore user settings.
@immutable
abstract class UserSettingsField {
  const UserSettingsField._();

  /// The users collection.
  static const users = 'users';

  /// The settings collection.
  static const settings = 'settings';

  /// The settings document.
  static const userSettings = 'userSettings';

  /// Theme mode setting.
  static const themeMode = 'themeMode';

  /// Time format setting.
  static const timeFormat = 'timeFormat';

  /// Temperature unit setting.
  static const temperatureUnit = 'temperatureUnit';
}
