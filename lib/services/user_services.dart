import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class UserServices {
  static Future<bool> checkSpotifyConnection() async {
    try {
      final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (userToken == null) return false;

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/spotify-status'),
        headers: {
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['spotifyConnected'] ?? false; // api returns boolean
      }
      return false;
    } catch (e) {
      print('Error checking Spotify connection: $e');
      return false;
    }
  }
}
