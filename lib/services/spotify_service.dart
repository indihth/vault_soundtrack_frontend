import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../models/listening_history_item.dart';
import '../utils/constants.dart';
import '../utils/ui_helpers.dart';
import '../mock/mock_data.dart';

class SpotifyService {
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
      BuildContext context, VoidCallback onAuthSuccess) async {
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
        callbackUrlScheme:
            "spotifyauth", // this should match the callbackUrlScheme in the server - custom url scheme
      );

      // hide loading indicator
      UIHelpers.hideDialog(context);

      // if authentication was successful
      // browser will auto close when redirected to callbackUrlScheme
      onAuthSuccess();

      // success message
      UIHelpers.showSnackBar(context, 'Successfully connected to Spotify!');
    } catch (e) {
      // hide loading indicator if it's showing
      UIHelpers.hideDialog(context);

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
