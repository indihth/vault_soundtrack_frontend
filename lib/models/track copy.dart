class Track {
  final String trackId;
  final String songName;
  final String artistName;
  final String albumName;
  final String albumArtworkUrl;
  final int upVotes;
  final int udownVotes;
  final Map<String, dynamic> votedBy; // Changed type to be more flexible

  Track({
    required this.trackId,
    required this.songName,
    required this.artistName,
    required this.albumName,
    required this.albumArtworkUrl,
    required this.upVotes,
    required this.udownVotes,
    required this.votedBy,
  });

// Using a facotry constructor offers more control and enable type checking
// handling the JSON parsing here is good practice (Separation of Concerns)

// The factory constructor takes a JSON object and returns a type safe Track DART object
  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      trackId: json['trackId'] ?? '',
      artistName: json['artistName'] ?? '',
      songName: json['songName'] ?? '',
      albumName: json['albumName'] ?? '',
      albumArtworkUrl: json['albumArtworkUrl'] ?? '',
      upVotes: json['upVotes'] ?? 0,
      udownVotes: json['downVotes'] ?? 0,
      votedBy: (json['votedBy'] as Map<String, dynamic>?) ??
          {}, // Cast and provide default empty map
    );
  }
}
