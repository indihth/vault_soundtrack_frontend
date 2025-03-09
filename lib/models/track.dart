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

// Using a facotry constructor offers more control and enable type checking
// handling the JSON parsing here is good practice (Separation of Concerns)

// The factory constructor takes a JSON object and returns a type safe Track DART object
  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] ?? '',
      artistName: json['artistName'] ?? '',
      songName: json['songName'] ?? '',
      albumName: json['albumName'] ?? '',
      albumArtworkUrl: json['albumArtworkUrl'] ?? '',
    );
  }
}
