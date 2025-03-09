import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:vault_soundtrack_frontend/models/playlist.dart';
import 'package:vault_soundtrack_frontend/models/track.dart';

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
  static Future<void> joinPlaylistSession() async {
    // await user id token
    final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();

    // api call
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/playlist-sessions/join-session'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        return print('Joined playlist session');
      } else {
        throw Exception(
            'Failed to join the playlist session: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to join playlist session: $e');
    }
  }

  // Get all playlist sessions for a user (host)
  static Future<List<String>> getUserPlaylistSessions() async {
    // await user id token
    final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();

    // two api calls
    // 1. get playlist sessions Ids for current user from user collection
    // 2. get playlist sessions from playlist-sessions collection

    try {
      // Get playlist sessions Ids for current user from user collection

      // Get sessions from playlist-sessions collection
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/playlist-sessions/get-sessions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        final List<String> data =
            responseData.map((item) => item.toString()).toList();
        print(data);
        return responseData.map((item) => item.toString()).toList();
      } else {
        throw Exception(
            'Failed to get playlist sessions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get playlist sessions: $e');
    }
  }

  static Future<List<Track>> createBasePlaylist() async {
    try {
      final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/playlist-sessions/create-playlist'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        // Parse the response body into a Map first
        final Map<String, dynamic> responseData = json.decode(response.body);

        // debug print the response data
        print('Response data: $responseData');

        // Get the tracks array from the appropriate field (adjust based on your API response)
        final List<dynamic> tracksJson = responseData['listeningHistory'] ?? [];

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
    print('User token: $userToken');

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
}
