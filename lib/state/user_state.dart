import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vault_soundtrack_frontend/services/user_services.dart';

class UserState extends ChangeNotifier {
  String _displayName = '';
  bool _isSpotifyConnected = false;

  String get displayName => _displayName;
  bool get isSpotifyConnected => _isSpotifyConnected;

  void setDisplayName(String name) {
    if (_displayName == name) return;
    _displayName = name;
    notifyListeners();
  }

  void setSpotifyConnection(bool isConnected) {
    if (_isSpotifyConnected == isConnected) return;
    _isSpotifyConnected = isConnected;
    notifyListeners();
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

  // Only call this when explicitly needed (after spotify connect/disconnect)
  Future<void> refreshSpotifyStatus() async {
    try {
      final isConnected = await UserServices.checkSpotifyConnection();
      setSpotifyConnection(isConnected);
    } catch (e) {
      setSpotifyConnection(false);
      rethrow;
    }
  }
}
