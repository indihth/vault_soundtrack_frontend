import 'package:flutter/material.dart';
import 'package:vault_soundtrack_frontend/components/playlist_header.dart';
import 'package:vault_soundtrack_frontend/components/track_card.dart';
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

/// The state class for LiveSessionPage
/// Manages the data and UI updates for the listening history
class _LiveSessionPageState extends State<LiveSessionPage> {
  // Future that will hold the list of listening history items when loaded
  late Future<List<Track>> _playlistFuture;

  // Dummy playlist data for testing
  static final Playlist dummyPlaylist = Playlist(
    name: 'My Awesome Playlist',
    image: 'https://example.com/playlist-cover.jpg',
    users: ['Alice', 'Bob', 'Charlie'],
  );

  @override
  void initState() {
    super.initState();
    // Load the listening history when the widget is first created
    _loadPlaylist();
  }

  /// Loads or reloads the listening history data from the service
  /// Updates the state to trigger a UI rebuild with the new data
  void _loadPlaylist() {
    setState(() {
      // Call the service to get listening history and update the future
      _playlistFuture = PlaylistSessionServices.loadPlaylist();
    });
  }

  Future<void> handleSavePlaylist() async {
    try {
      final success = await PlaylistSessionServices.savePlaylist();
      if (success) {
        // TODO: Update 'save' button to show 'saved'

        // Show a success message to the user
        UIHelpers.showSnackBar(context, 'Playlist saved successfully!',
            isError: false);
      } else {
        UIHelpers.showSnackBar(context, 'Failed to save playlist',
            isError: true);
      }
    } catch (e) {
      UIHelpers.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
    }
  }

  void handleEndSession() {
    // Implement end session functionality here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          // Title and subtitle for the listening history component
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PlaylistHeader(
              item: dummyPlaylist,
              handleEndSession: handleEndSession,
              handleSavePlaylist: handleSavePlaylist,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Track>>(
              // FutureBuilder handles async data loading states
              future: _playlistFuture,
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
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // Show message when no history data exists
                  return const Center(
                    child: Text('No listening history found'),
                  );
                } else {
                  // Build a scrollable list of history items when data is available
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.data![index];
                      // Create a card for each history item
                      return TrackCard(item: item);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
