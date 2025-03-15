import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vault_soundtrack_frontend/models/playlist.dart';
import 'package:vault_soundtrack_frontend/models/track.dart';
import 'package:vault_soundtrack_frontend/models/user_profile.dart';

import '../utils/constants.dart';

class PlaylistSessionServices {
  // Get one playlist session
  static Future<void> getPlaylistSession() async {
    // await user id token
    final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();

    // session must be referenced in 'user' collection for host
  }

  // Join a playlist session
  static Future<bool> joinPlaylistSession() async {
    // await user id token
    final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    const sessionId = ApiConstants.sessionId;

    try {
      final response = await http.put(
        Uri.parse(
            '${ApiConstants.baseUrl}/playlist-sessions/$sessionId/join-session'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        print('Joined playlist session');
        return true;
      } else {
        throw Exception(
            'Failed to join the playlist session: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to join playlist session: $e');
    }
  }

  // Get all playlist sessions for a user (host)
  static Future<List<UserProfile>> getSessionUsers() async {
    // await user id token
    final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    const sessionId = ApiConstants.sessionId;

    try {
      // Get users in current session
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/playlist-sessions/$sessionId/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        print('Got users response: ${response.body}');

        final Map<String, dynamic> responseData = json.decode(response.body);

        final Map<String, dynamic> usersJson = responseData['data'];

        List<UserProfile> users = [];
        usersJson.forEach((userId, userData) {
          // Add the userId to the userData map
          Map<String, dynamic> userDataWithId = {...userData, 'userId': userId};
          users.add(UserProfile.fromJson(userDataWithId));
        });

        return users;
      } else {
        throw Exception(
            'Failed to get users from session: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get users from session: $e');
    }
  }

  static Future<Playlist> loadPlaylist() async {
    try {
      final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      const sessionId = ApiConstants.sessionId;

      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/playlist-sessions/$sessionId/load-playlist'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Debug print to see the structure
        print('Response data: $responseData');
        print('Playlist data: ${responseData['data']}');

        if (responseData['data'] == null) {
          throw Exception('No playlist data received from server');
        }

        final playlist = Playlist.fromJson(responseData['data']);
        // Debug print the created playlist
        print('Created playlist: $playlist');
        return playlist;
      } else {
        throw Exception('Failed to get playlist: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error loading playlist: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to create base playlist: $e');
    }
  }

  // Create new playlist session
  static Future<String> createPlaylistSession(
      String title, String description) async {
    // await user id token
    final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();

    try {
      // Otherwise, make the real API call
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/playlist-sessions/create-session'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: json.encode({'title': title, 'description': description}),
      );

      if (response.statusCode == 200) {
        // TODO: forward user to session share page with session id

        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['data'];
      } else {
        throw Exception(
            'Failed to create playlist session: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create playlist session: $e');
    }
  }

  static Future<bool> savePlaylist() async {
// await user id token
    final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    const sessionId = ApiConstants.sessionId;

    try {
      final response = await http.post(
        Uri.parse(
            '${ApiConstants.baseUrl}/playlist-sessions/$sessionId/save-playlist'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      return response.statusCode == 200; // Return true if successful
    } catch (e) {
      throw Exception('Failed to save playlist: $e');
    }
  }
}
