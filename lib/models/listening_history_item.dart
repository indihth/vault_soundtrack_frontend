import 'package:intl/intl.dart';

class ListeningHistoryItem {
  final String id;
  final String songName;
  final String artistName;
  final String albumName;
  final String albumArtworkUrl;

  ListeningHistoryItem({
    required this.id,
    required this.songName,
    required this.artistName,
    required this.albumName,
    required this.albumArtworkUrl,
  });

// Using a facotry constructor offers more control and enable type checking
// handling the JSON parsing here is good practice (Separation of Concerns)

// The factory constructor takes a JSON object and returns a type safe ListeningHistoryItem DART object
  factory ListeningHistoryItem.fromJson(Map<String, dynamic> json) {
    return ListeningHistoryItem(
      id: json['id'] ?? '',
      artistName: json['artistName'] ?? '',
      songName: json['songName'] ?? '',
      albumName: json['albumName'] ?? '',
      albumArtworkUrl: json['albumArtworkUrl'] ?? '',
    );
  }
}
