import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vault_soundtrack_frontend/models/playlist.dart';
import 'package:vault_soundtrack_frontend/models/user_profile.dart';

import '../utils/constants.dart';

class PlaylistSessionServices {
  // Get all playlist sessions
  static Future<void> getPlaylistSessionsByUser() async {
    // await user id token
    final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();

    // session must be referenced in 'user' collection for host
  }

  // Join a playlist session - dynamic handling for late joins too
  static Future<Map<String, dynamic>> joinPlaylistSession(String sessionId,
      {bool isLateJoin = false}) async {
    print("sessionId in services: $sessionId");
    // await user id token

    try {
      final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();

      final endpoint = isLateJoin
          ? 'join-late'
          : 'join-session'; // determine endpoint needed base on isLateJoin

      print('isLateJoin: $isLateJoin');
      final response = await http.put(
        Uri.parse(
            '${ApiConstants.baseUrl}/playlist-sessions/$sessionId/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        print('Joined playlist session');

        // return true;
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Response data: $responseData');
        if (responseData['session'] == null) {
          throw Exception('Server returned empty session data');
        }
        if (responseData['alreadyJoined'] == true) {
          print('Already joined session ************************************');
        }
        return {
          "success": true,
          "data": responseData['session'],
          "isLateJoin":
              isLateJoin // used in join-session page to redirect correctly
        };
      } else {
        throw Exception(
            'Failed to ${isLateJoin ? 'late join' : 'join'} the playlist session: ${response.statusCode} and ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to join playlist session: $e');
    }
  }

  static Future<String> startPlaylistSession(String sessionId) async {
    try {
      final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      // const sessionId = ApiConstants.sessionId;

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

        print('Created playlist: $responseData');
        if (responseData['data']['playlistId'] == null) {
          throw Exception('No playlist data received from server');
        }

        // final playlist = Playlist.fromFirestore(responseData['data']);
        // Debug print the created playlist
        print('Created playlist: $responseData');
        return responseData['data']['playlistId'];
      } else {
        throw Exception(
            'Failed to get playlist: ${response.statusCode}, message: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Error loading playlist: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to create base playlist: $e');
    }
  }

  // Update session status
  static Future<Map<String, dynamic>> updateSessionStatus(
      String sessionId, String status) async {
    try {
      final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      // const sessionId = ApiConstants.sessionId;

      final response = await http.put(
        Uri.parse(
            '${ApiConstants.baseUrl}/playlist-sessions/$sessionId/update-status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        print('Updated session status to $status');

        final Map<String, dynamic> responseData = json.decode(response.body);
        return {"success": true, "status": responseData['status']};
      } else {
        throw Exception(
            'Failed to update session status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update session status: $e');
    }
  }

  // Create new playlist session
  static Future<Map<String, dynamic>> createPlaylistSession(
      String title, String description) async {
    try {
      // await user id token
      final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      // Otherwise, make the real API call
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/playlist-sessions/create-session'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: json.encode({'title': title, 'description': description}),
      );
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return {"success": true, "data": responseData['session']};
      } else {
        return {"success": false, "error": response.statusCode};
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
      // throw Exception('Failed to create playlist session: $e');
    }
  }

  static Future<bool> savePlaylist(String sessionId) async {
// await user id token
    final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    // const sessionId = ApiConstants.sessionId;

    try {
      final response = await http.post(
        Uri.parse(
            '${ApiConstants.baseUrl}/playlist-sessions/$sessionId/save-playlist'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      print('####################### Response: ${response.body}');

      return response.statusCode == 200; // Return true if successful
    } catch (e) {
      throw Exception('Failed to save playlist: $e');
    }
  }

  // Updates playlist when users join while session if already active
  static Future<void> syncPlaylist({
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
