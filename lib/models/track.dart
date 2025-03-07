class Track {
  final String id;
  final String songName;
  final String artistName;
  final String albumName;
  final String albumArtworkUrl;

  Track({
    required this.id,
    required this.songName,
    required this.artistName,
    required this.albumName,
    required this.albumArtworkUrl,
  });

  // Using a factory constructor offers more control and enables type checking
  // handling the JSON parsing here is good practice (Separation of Concerns)

  // The factory constructor takes a JSON object and returns a type safe Track DART object
  factory Track.fromJson(Map<String, dynamic> json) {
    // Handle Spotify API format where track info might be nested
    final track =
        json['track'] ?? json; // Handle both nested and flat structures
    final artists = track['artists'] as List<dynamic>? ?? [];
    final album = track['album'] as Map<String, dynamic>? ?? {};
    final images = album['images'] as List<dynamic>? ?? [];

    return Track(
      id: track['id'] ?? '',
      songName: track['name'] ?? '',
      artistName: artists.isNotEmpty ? artists[0]['name'] : '',
      albumName: album['name'] ?? '',
      albumArtworkUrl: images.isNotEmpty ? images[0]['url'] : '',
    );
  }
}
