import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

/// The implementation of the [RemoteSettingsService] with Firestore.
class FirestoreSettingsClient implements RemoteSettingsService {
  /// Creates a new [FirestoreSettingsClient].
  FirestoreSettingsClient({
    required FirebaseFirestore firestore,
    required String userId,
  }) : _userId = userId,
       _usersCollection = firestore.collection(UserSettingsField.users);

  final String _userId;
  final CollectionReference _usersCollection;

  StreamSubscription<UserSettings>? _settingsSubscription;

  @override
  UserSettings get userSettings => _userSettings;
  UserSettings _userSettings = UserSettings();

  @override
  Stream<UserSettings> get userSettingsStream =>
      _userSettingsStreamController.stream;
  final _userSettingsStreamController =
      StreamController<UserSettings>.broadcast();

  @override
  Future<void> initialize() async {
    _userSettings = await get();

    _settingsSubscription = _usersCollection
        .doc(_userId)
        .collection(UserSettingsField.settings)
        .doc(UserSettingsField.userSettings)
        .snapshots()
        .map((doc) => doc.exists ? _parseSettings(doc) : _userSettings)
        .listen(
          (settings) {
            _userSettings = settings;
            _userSettingsStreamController.add(settings);
          },
          onError: (error) => debugPrint("Error listening to settings: $error"),
        );
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    _userSettingsStreamController.close();
  }

  @override
  Future<UserSettings> get() async {
    final doc =
        await _usersCollection
            .doc(_userId)
            .collection(UserSettingsField.settings)
            .doc(UserSettingsField.userSettings)
            .get();

    if (!doc.exists) return _userSettings;

    return _parseSettings(doc);
  }

  @override
  Future<void> update(
    UserSettings Function(UserSettings) updateFunction,
  ) async {
    _userSettings = updateFunction(_userSettings);

    final data = {
      UserSettingsField.themeMode: _userSettings.themeMode.name,
      UserSettingsField.timeFormat: _userSettings.timeFormat.name,
      UserSettingsField.temperatureUnit: _userSettings.temperatureUnit.name,
    };

    await _usersCollection
        .doc(_userId)
        .collection(UserSettingsField.settings)
        .doc(UserSettingsField.userSettings)
        .set(data, SetOptions(merge: true));

    _userSettingsStreamController.add(_userSettings);
  }

  /// Parses a Firestore document into a [UserSettings] object.
  UserSettings _parseSettings(DocumentSnapshot doc) {
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
