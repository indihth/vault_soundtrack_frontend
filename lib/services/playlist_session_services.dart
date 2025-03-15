import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:vault_soundtrack_frontend/models/playlist.dart';
import 'package:vault_soundtrack_frontend/models/track.dart';
import 'package:vault_soundtrack_frontend/models/user_profile.dart';

import '../models/listening_history_item.dart';
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

  static Future<List<Track>> createBasePlaylist() async {
    try {
      final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      const sessionId = ApiConstants.sessionId;

      final response = await http.post(
        Uri.parse(
            '${ApiConstants.baseUrl}/playlist-sessions/$sessionId/create-playlist'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        // Parse the response body into a Map first
        final Map<String, dynamic> responseData = json.decode(response.body);

        // debug print the response data

        // Get the tracks array from the appropriate field (adjust based on your API response)
        final List<dynamic> tracksJson = responseData['data']['tracks'];

        // Convert each item in the list to a Track object
        return tracksJson
            .map((trackJson) => Track.fromJson(trackJson))
            .toList();
      } else {
        throw Exception('Failed to get playlist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create base playlist: $e');
    }
  }

  // Create new playlist session
  static Future<String> createPlaylistSession() async {
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
      );

      if (response.statusCode == 200) {
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

  static Future<void> savePlaylist() async {
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

      if (response.statusCode == 200) {
        print('Saved playlist');
      } else {
        throw Exception('Failed to save playlist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to save playlist: $e');
    }
  }
}
