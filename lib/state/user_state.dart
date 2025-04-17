import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserState extends ChangeNotifier {
  String _displayName = '';
  bool _isSpotifyConnected = false;

  String get displayName => _displayName;
  bool get isSpotifyConnected => _isSpotifyConnected;

  void setDisplayName(String name) {
    _displayName = name;
    notifyListeners();
  }

  void setSpotifyConnection(bool isConnected) {
    _isSpotifyConnected = isConnected;
    notifyListeners();
  }

  Future<void> updateUserState() async {
    final user = FirebaseAuth.instance.currentUser;
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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final token = await user.getIdToken();
      // Here you would typically make an API call to your backend
      // to verify the Spotify connection status
      return true; // Replace with actual implementation
    } catch (e) {
      return false;
    }
  }
}
