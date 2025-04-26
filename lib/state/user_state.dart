import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vault_soundtrack_frontend/services/user_services.dart';

class UserState extends ChangeNotifier {
  String _displayName = '';
  String _spotifyDisplayName = '';
  bool _isNewUser = false;
  bool _isSpotifyConnected = true;
  bool _isLoggingOut = false;

  String get displayName => _displayName;
  String get spotifyDisplayName => _spotifyDisplayName;
  bool get isNewUser => _isNewUser;
  bool get isSpotifyConnected => _isSpotifyConnected;
  bool get isLoggingOut => _isLoggingOut;

  void setNewUserFlag() {
    _isNewUser = true;
    notifyListeners();
  }

  void clearNewUserFlag() {
    _isNewUser = false;
    notifyListeners();
  }

  void setDisplayName(String name) {
    _displayName = name;
    notifyListeners();
  }

  void setSpotifyDisplayName(String name) {
    _spotifyDisplayName = name;
    notifyListeners();
  }

  void setSpotifyConnection(bool isConnected) {
    _isSpotifyConnected = isConnected;
    notifyListeners();
  }

  void startLogout() {
    _isLoggingOut = true;
    notifyListeners();
  }

  void endLogout() {
    _isLoggingOut = false;
    notifyListeners();
  }

  void resetState() {
    _displayName = '';
    _isNewUser = false;
    _isSpotifyConnected = true;
    _isLoggingOut = false;
    notifyListeners();
  }

  Future<void> updateUserState() async {
    final user = FirebaseAuth.instance.currentUser; // get the current user
    if (user != null) {
      setDisplayName(user.displayName ?? 'User');
      // Check Spotify connection
      bool isConnected = await checkSpotifyConnection();
      setSpotifyConnection(isConnected);
    }
  }

  Future<bool> checkSpotifyConnection() async {
    // Implement actual Spotify connection check here
    try {
      // make api call to check Spotify connection - returns boolean
      final isConnected = await UserServices.checkSpotifyConnection();

      return isConnected;
    } catch (e) {
      return false;
    }
  }

  Future<void> createUserDocument(String username) async {
    try {
      final userData = await UserServices.creatUserDocument(username);
      setDisplayName(userData['username'] ?? username);
      setSpotifyConnection(false);
    } catch (e) {
      print('Error creating user document: $e');
      rethrow;
    }
  }
}
