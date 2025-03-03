import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../models/listening_history_item.dart';
import '../utils/constants.dart';

class UserServices {
  // check if user has linked Spotify account

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

  // Get all playlist sessions
  static Future<List<String>> getPlaylistSessions() async {
    // await user id token
    final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();

    try {
      // Otherwise, make the real API call
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/playlist-sessions/get-sessions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        return responseData.map((item) => item.toString()).toList();
      } else {
        throw Exception(
            'Failed to get playlist sessions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get playlist sessions: $e');
    }
  }
}
