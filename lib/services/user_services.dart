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

      // only return if
      if (response.statusCode == 200 || response.statusCode == 204) {
        final data = json.decode(response.body);
        return data['spotifyConnected'] ?? false; // api returns boolean
      } else {
        // throw erorr if status code is not 200
        throw Exception(
            'Failed to connect, status code - ${response.statusCode}');
      }
    } catch (e) {
      print('Error checking Spotify connection: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getUserSessions() async {
    try {
      final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (userToken == null) return [];

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/sessions'),
        headers: {
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('User sessions: $data');
        return List<Map<String, dynamic>>.from(data['sessions'] ??
            []); // cast to specific type - make a model class later
      } else {
        throw Exception(
            'Failed to get sessions, status code - ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting user sessions: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> creatUserDocument(String username) async {
    try {
      final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      print('userToken: $userToken');

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/user/create-user'),
        headers: {
          'Authorization': 'Bearer $userToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'username': username}), // empty body
      );

      if (response.statusCode != 200) {
        print('Response: ${response.body}');
        throw Exception(
            'Failed to create user, status code - ${response.statusCode}');
      }

      final Map<String, dynamic> responseData = json.decode(response.body);
      print('User created: $responseData');
      return responseData['user']; // return user data
    } catch (e) {
      print('Error creating new user: $e');
      rethrow;
    }
  }
}
