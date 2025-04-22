import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/models/playlist.dart';
import 'package:vault_soundtrack_frontend/state/user_state.dart';

import '../models/listening_history_item.dart';
import '../utils/constants.dart';
import '../utils/ui_helpers.dart';
import '../mock/mock_data.dart';

class SpotifyServices {
  static Future<Map<String, dynamic>> createPlaylist() async {
    try {
      // await user id token
      final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();

      // make the API request
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/spotify/playlist'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userToken}',
        },
      );

      // Parse the JSON string into a Dart Map
      Map<String, dynamic> responseData = json.decode(response.body);

      // if (response.statusCode == 200) {
      //   //     final playlistId = json.decode(response.body)['playlistId'];

      //   //      final url = "spotify://playlist/$playlistId"; // Deep link to open in app
      //   // final webUrl = "https://open.spotify.com/playlist/$playlistId"; // Fallback

      //   // if (await canLaunchUrl(Uri.parse(url))) {
      //   //   await launchUrl(Uri.parse(url)); // Try opening in Spotify app
      //   // } else {
      //   //   await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication); // Open in browser
      //   // }

      //   // Now you can access the playlistURL property
      //   print('Playlist URL: ${responseData['playlistURL']}');
      //   return responseData['requiresAuth'];
      //   // return print(responseData['playlistURL']);
      // } else {
      //   throw Exception(
      //       'Failed to create playlist: ${response.statusCode} - ${responseData['error']} - ${responseData['requiresAuth']}');
      // }
      return responseData;
    } catch (e) {
      throw Exception('Failed to create playlist: $e.');
    }
  }

  // get playlist by id
  // static Future<void> getPlaylistById(String playlistId) async {
  static Future<Playlist> getPlaylistById() async {
    try {
      String playlistId = '5xwdCq1yNx3UoecU7OeDVb';
      // await user id token
      final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      print('userToken: $userToken');

      // make the API request
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/spotify/playlist?id=$playlistId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userToken}',
        },
      );

      if (response.statusCode == 200) {
        return Playlist.fromFirestore(json.decode(response.body));
      } else {
        throw Exception('Failed to get playlist');
      }
    } catch (e) {
      print('Error getting playlist: $e');
      throw Exception('Failed to get playlist: $e');
    }
  }

  static Future<List<ListeningHistoryItem>> getListeningHistory() async {
    // Return mock data if useMockData is true
    if (ApiConstants.useMockData) {
      // Add a small delay to simulate network request
      await Future.delayed(const Duration(seconds: 1));
      return MockData.getMockListeningHistory();
    }

    // await user id token
    final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();

    // Otherwise, make the real API call
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/spotify/top'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${userToken}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => ListeningHistoryItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load listening history');
    }
  }

  static Future<void> startAuthFlow(
      BuildContext context, Function(bool success) onAuthSuccess) async {
    // BuildContext context, VoidCallback onAuthSuccess) async {
    try {
      UIHelpers.showLoadingIndicator(context);

      // get current userId Firebase Id token
      final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();

      // encode the userToken token to send to the server - only if it's not null otherwise runtime error
      final encodedUserToken = userToken != null
          ? Uri.encodeComponent(userToken)
          : throw Exception('User token not available');

      // start the Spotify authentication flow using flutter_web_auth package, passsing userToken as query parameter

      final result = await FlutterWebAuth2.authenticate(
        url: '${ApiConstants.baseUrl}/spotify/login?token=$encodedUserToken',
        callbackUrlScheme: "spotifyauth",
      );

      // hide loading indicator
      UIHelpers.hideDialog(context);

      // Update UserState
      context.read<UserState>().setSpotifyConnection(true);

      // if authentication was successful browser will auto close when redirected to callbackUrlScheme
      onAuthSuccess(true);

      // success message
      UIHelpers.showSnackBar(context, 'Successfully connected to Spotify!');
    } catch (e) {
      // hide loading indicator if it's showing
      UIHelpers.hideDialog(context);

      // Send success callback with false to indicate failure
      onAuthSuccess(false);
      // Authentication was canceled or failed
      UIHelpers.showSnackBar(
        context,
        'Failed to connect to Spotify: ${e.toString()}',
        isError: true,
      );
      print('Failed to connect to Spotify: ${e.toString()}');
    }
  }
}
