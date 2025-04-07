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

  // Create _sessionState variable to access session state in multiple methods
  late SessionState _sessionState;

  // Hanles UI when ending session
  bool _isEnding = false;

  @override
  void initState() {
    super.initState();

    _sessionState = Provider.of<SessionState>(context, listen: false);
    // _initializeSession();
  }

  Future<void> _initializeSession() async {
    _sessionState = Provider.of<SessionState>(context, listen: false);

    try {
      if (_sessionState.isJoining) {
        await _sessionState.joinExistingSession(
          _sessionState.sessionId,
          _sessionState.playlistId,
        );
        // Show success message
        UIHelpers.showSnackBar(context, 'Successfully joined session');
      }

      // Continue with regular session initialization
      // ...existing initialization code...
    } catch (e) {
      UIHelpers.showSnackBar(
        context,
        'Failed to initialize session: ${e.toString()}',
        isError: true,
      );
      Navigator.pop(context); // Return to previous screen on error
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('session state active didChanged running');

    // Check if session is ended and needs to redirect

    if (!_sessionState.isActive) {
      // Session is ended, stop listening before redirecting
      _sessionState.stopListeningToSessionStatus();

      // Clear session state
      // _sessionState.clearSessionState();

      // Use addPostFrameCallback to ensure the navigation happens after the build is complete.
      // otherwise potential error trying to navigate while the widget is still building
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   Navigator.pushReplacementNamed(context, '/home').then((_) {
      //     // reset _isEnding to false after navigation
      //     setState(() {
      //       _isEnding = false;
      //     });
      //   });
      // });

      // Navigate to home page
      // navigateAndClearState();

      // If session is ended, stop listening to session status
      return;
    }

    final sessionId = _sessionState.sessionId;

    // Is this needed?
    // if (sessionId.isEmpty) {
    //   throw Exception('Session ID state is empty');
    // }
    _sessionState.listenToSessionStatus(sessionId);
  }

  Future<void> handleSavePlaylist() async {
    try {
      // Get session id from the Provider
      if (_sessionState.sessionId.isEmpty) {
        throw Exception('Session ID state is empty');
      }
      final success =
          await PlaylistSessionServices.savePlaylist(_sessionState.sessionId);
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

  Future<void> navigateAndClearState() async {
    try {
      // // set _isEnding to true to show loading spinner
      // setState(() {
      //   _isEnding = true;
      // });
      // navigate first
      await Navigator.pushReplacementNamed(context, '/home');

      // only if navigation complete, clear state
      _sessionState.clearSessionState();
    } catch (e) {
      // Handle any errors that occur during navigation
      UIHelpers.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      throw Exception('Error navigating to home: $e');
    } finally {
      // Reset _isEnding to false after navigation
      setState(() {
        _isEnding = false;
      });
    }
  }

  void handleEndSession() async {
    try {
      // Close the dialog
      Navigator.of(context).pop();

      // set _isEnding to true to show loading spinner
      setState(() {
        _isEnding = true;
      });

      final sessionId = _sessionState.sessionId;

      if (sessionId.isEmpty) {
        throw Exception('Session ID state is empty');
      }

      await _sessionState.endSession(sessionId);

      await navigateAndClearState();

      //reset _isEnding to false after session ended
      setState(() {
        _isEnding = false;
      });
    } catch (e) {
      // Reset _isEnding to false in case of error
      setState(() {
        _isEnding = false;
      });

      // Display error message to the user
      UIHelpers.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      throw Exception('Error ending session: $e');
    } finally {
      // reset _isEnding
    }
  }

  @override
  void dispose() {
    // Getting error calling an ancestor widget in the dispose method
    // Cancel any active session state subscription when the widget is disposed

    // Clear session state when widget is disposed, avoid 'no playlist ID' error
    // _sessionState.clearSessionState();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get session state
    final playlistId = _sessionState.playlistId;
    final isHost = _sessionState.isHost;

    if (_isEnding) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            DefaultTextStyle(
              // required because rendering before Scaffold is built
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14.0,
              ),
              child: Text('Ending session...'),
            ),
          ],
        ),
      );
    } else

    // Shows error message if no playlist Id is found but not when ending session
    // (handles clearing session state more gracefully in the UI)
    if (playlistId.isEmpty) {
      return const Center(
        child: DefaultTextStyle(
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.0,
            ),
            child: Text('No playlist ID found')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              // Get session ID from provider
              final sessionId = _sessionState.sessionId;
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
