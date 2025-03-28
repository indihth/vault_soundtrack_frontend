import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vault_soundtrack_frontend/utils/constants.dart';

class VotingServices {
  // Cast vote for track
  static Future<Map<String, dynamic>> handleVote(
      sessionId, playlistId, trackId, voteType) async {
    // api post request with playlistId, trackId, userId and voteType (upvote or downvote)
    try {
      final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/playlist-sessions/$sessionId/vote'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        // Sending data in JSON format to the API
        body: json.encode({
          'playlistId': playlistId,
          'trackId': trackId,
          'voteType': voteType
        }),
      );

      if (response.statusCode == 200) {
        print('Cast vote successfully');
        // return true;
        final Map<String, dynamic> responseData = json.decode(response.body);
        return {"success": true, "data": responseData['session']};
      } else {
        throw Exception(
            'Failed to cast vote: ${response.statusCode} and ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to cast vote: $e');
    }
  }

  // api post request with playlistId, trackId, userId and voteType (upvote or downvote)

  // Handle vote response
  // Update track vote count in UI?
  // Update track vote status
  // Update user vote status

  // Handle removal of track?
}
