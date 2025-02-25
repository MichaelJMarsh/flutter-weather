import 'package:flutter/foundation.dart';

import 'package:domain/domain.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// The implementation of [AuthenticationService] using Firebase Authentication.
class FirebaseAuthenticationPlugin implements AuthenticationService {
  /// Creates a new [FirebaseAuthenticationPlugin].
  FirebaseAuthenticationPlugin({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  /// The user ID of the currently authenticated user.
  @override
  String get userId => _firebaseAuth.currentUser?.uid ?? '';

  /// Ensures the user is authenticated and returns their user ID.
  @override
  Future<String> authenticate() async {
    var user = _firebaseAuth.currentUser;

    if (user == null) {
      final result = await _firebaseAuth.signInAnonymously();
      user = result.user;

      debugPrint("✅ Anonymous sign-in successful: ${user?.uid}");
    } else {
      debugPrint("✅ User already signed in: ${user.uid}");
    }

    return user!.uid;
  }
}
