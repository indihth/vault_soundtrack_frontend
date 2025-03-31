import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:vault_soundtrack_frontend/utils/constants.dart';

class PlaylistSyncServices {
  static Future<void> syncUserPlaylist({
    required String sessionId,
    required String playlistId,
    required String userId,
  }) async {
    try {
      final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();

      final response = await http.put(
        Uri.parse(
            '${ApiConstants.baseUrl}/playlist-sessions/$sessionId/join-session'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: json.encode({
          'userId': userId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to sync playlist');
      }
    } catch (e) {
      throw Exception('Failed to sync playlist: $e');
    }
  }
}
