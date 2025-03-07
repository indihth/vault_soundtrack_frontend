import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:vault_soundtrack_frontend/models/track.dart';
import 'package:vault_soundtrack_frontend/services/playlist_session_services.dart';

// Import local models and services
import '../models/listening_history_item.dart';
import '../services/spotify_services.dart';

/// ListeningHistoryPage: A StatefulWidget that displays the user's listening history
/// This is the main screen that shows all songs the user has played
class ListeningHistoryPage extends StatefulWidget {
  const ListeningHistoryPage({Key? key}) : super(key: key);

  @override
  State<ListeningHistoryPage> createState() => _ListeningHistoryPageState();
}

/// The state class for ListeningHistoryPage
/// Manages the data and UI updates for the listening history
class _ListeningHistoryPageState extends State<ListeningHistoryPage> {
  // Future that will hold the list of listening history items when loaded
  late Future<List<Track>> _listeningHistoryFuture;

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
      _listeningHistoryFuture = PlaylistSessionServices.createBasePlaylist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listening History'),
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
          future: _listeningHistoryFuture,
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
                  return ListeningHistoryCard(item: item);
                },
              );
            }
          },
        ),
      ),
    );
  }
}

/// ListeningHistoryCard: A widget that displays a single listening history item
/// Shows song details including artwork, name, artist, album, and when it was played
class ListeningHistoryCard extends StatelessWidget {
  // The data model containing all information about this history item
  final Track item;

  const ListeningHistoryCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2.0, // Adds a slight shadow to the card
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Album Artwork section
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(8.0), // Rounded corners for the image
              child: Image.network(
                item.albumArtworkUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                // Handle image loading errors gracefully
                errorBuilder: (context, error, stackTrace) {
                  // If image loading fails, show a placeholder
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.music_note, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 16.0), // Spacing between image and text
            // Song details section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Song name with ellipsis if too long
                  Text(
                    item.songName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow
                        .ellipsis, // Truncate with ... if text is too long
                  ),
                  const SizedBox(height: 4.0), // Vertical spacing
                  // Artist name
                  Text(
                    item.artistName,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  // Album name
                  Text(
                    item.albumName,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
