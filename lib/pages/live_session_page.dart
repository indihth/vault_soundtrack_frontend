import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:vault_soundtrack_frontend/components/track_card.dart';
import 'package:vault_soundtrack_frontend/models/track.dart';
import 'package:vault_soundtrack_frontend/services/playlist_session_services.dart';

// Import local models and services
import '../models/listening_history_item.dart';
import '../services/spotify_services.dart';

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

  @override
  void initState() {
    super.initState();
    // Load the listening history when the widget is first created
    _loadListeningHistory();
  }

  /// Loads or reloads the listening history data from the service
  /// Updates the state to trigger a UI rebuild with the new data
  void _loadListeningHistory() {
    setState(() {
      // Call the service to get listening history and update the future
      _playlistFuture = PlaylistSessionServices.createBasePlaylist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // Refresh button in the app bar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadListeningHistory, // Reload history when pressed
          ),
        ],
      ),
      body: RefreshIndicator(
        // Pull-to-refresh functionality
        onRefresh: () async {
          _loadListeningHistory();
        },
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
    );
  }
}
