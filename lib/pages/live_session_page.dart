import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vault_soundtrack_frontend/services/database_services.dart';
import 'package:vault_soundtrack_frontend/state/session_state.dart';
import 'package:vault_soundtrack_frontend/widgets/playlist_header.dart';
import 'package:vault_soundtrack_frontend/widgets/track_card.dart';
import 'package:vault_soundtrack_frontend/models/track.dart';
import 'package:vault_soundtrack_frontend/services/playlist_session_services.dart';
import 'package:vault_soundtrack_frontend/utils/ui_helpers.dart';

// Import local models and services
import '../models/playlist.dart';

/// LiveSessionPage: A StatefulWidget that displays the user's listening history
/// This is the main screen that shows all songs the user has played
class LiveSessionPage extends StatefulWidget {
  const LiveSessionPage({Key? key}) : super(key: key);

  @override
  State<LiveSessionPage> createState() => _LiveSessionPageState();
}

class _LiveSessionPageState extends State<LiveSessionPage> {
  /// The state class for LiveSessionPage
  /// Manages the data and UI updates for the listening history

  @override
  void initState() {
    super.initState();

    // Get session state from the Provider
    // final sessionState = Provider.of<SessionState>(context, listen: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('session state active didChanged running');

    // Check if session is ended and needs to redirect
    final sessionState = Provider.of<SessionState>(context);
    print('session state active didChanged: ${sessionState.isActive}');

    if (!sessionState.isActive) {
      // Session is ended, stop listening before redirecting
      sessionState.stopListeningToSessionStatus();

      // Use addPostFrameCallback to ensure the navigation happens after the build is complete.
      // otherwise potential error trying to navigate while the widget is still building

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });

      // If session is ended, stop listening to session status
      return;
    }

    final sessionId = sessionState.sessionId;

    // Is this needed?
    // if (sessionId.isEmpty) {
    //   throw Exception('Session ID state is empty');
    // }
    sessionState.listenToSessionStatus(sessionId);
  }

  Future<void> handleSavePlaylist() async {
    try {
      // Get session id from the Provider
      final sessionState = Provider.of<SessionState>(context, listen: false);
      if (sessionState.sessionId.isEmpty) {
        throw Exception('Session ID state is empty');
      }
      final success =
          await PlaylistSessionServices.savePlaylist(sessionState.sessionId);
      if (success) {
        // TODO: Update 'save' button to show 'saved'

        // Show a success message to the user
        UIHelpers.showSnackBar(context, 'Playlist saved successfully!',
            isError: false);
      } else {
        UIHelpers.showSnackBar(context, 'Failed to save playlist',
            isError: true);
        throw Exception('Failed to save playlist');
      }
    } catch (e) {
      UIHelpers.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      throw Exception('Error saving playlist: $e');
    }
  }

  void handleEndSession() async {
    try {
      final sessionState = Provider.of<SessionState>(context, listen: false);
      final sessionId = sessionState.sessionId;

      if (sessionId.isEmpty) {
        throw Exception('Session ID state is empty');
      }

      sessionState.endSession(sessionId);
    } catch (e) {
      UIHelpers.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      throw Exception('Error ending session: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get session state
    final sessionState = Provider.of<SessionState>(context);
    final playlistId = sessionState.playlistId;
    final isHost = sessionState.isHost;

    if (playlistId.isEmpty) {
      return const Center(
        child: Text('No playlist ID found'),
      );
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              // Get session ID from provider
              final sessionId =
                  Provider.of<SessionState>(context, listen: false).sessionId;
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Session QR Code'),
                  content: QrImageView(
                    data: sessionId,
                    // version: QrVersions.auto,
                    size: 200.0,
                  ),
                  // Image.network(
                  //   'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=$sessionId',
                  //   height: 200,
                  //   width: 200,
                  // ),
                  actions: [
                    TextButton(
                      child: const Text('Close'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<Playlist>(
        stream: _getPlaylistStream(playlistId),
        builder: (context, snapshot) {
          // Handle different states of the future
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading spinner while data is being fetched
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // Show error message if data fetching failed
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.tracks.isEmpty) {
            // Show message when no history data exists
            return const Center(
              child: Text('No listening history found'),
            );
          } else {
            Playlist playlist = snapshot.data!;

            print(
                'snapshot.data!.tracks.length: ${snapshot.data!.tracks.length}');
            // Build a scrollable list of history items when data is available
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  PlaylistHeader(
                    item: playlist,
                    isHost: isHost,
                    handleEndSession: handleEndSession,
                    handleSavePlaylist: handleSavePlaylist,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: playlist.tracks.length, // Also fixed itemCount
                      itemBuilder: (context, index) {
                        Track track = playlist.tracks[index];
                        return TrackCard(item: track);
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // Stream to listen to playlist changes from Firestore
  Stream<Playlist> _getPlaylistStream(String playlistId) {
    // final databaseServices =
    //     DatabaseServices(); // Create an instance of DatabaseServices
// Check if playlistId is empty or null
    if (playlistId.isEmpty) {
      // Return an empty stream that emits an error
      return Stream.error('Invalid playlist ID');
    }

    try {
      return FirebaseFirestore.instance
          .collection('playlists')
          .doc(playlistId)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists) {
          return Playlist.fromFirestore(snapshot);
        }
        throw Exception('Playlist not found');
      });
    } catch (e) {
      print('Error creating stream: $e');
      return Stream.error('Failed to create playlist stream: $e');
    }
  }
}
