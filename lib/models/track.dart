class Track {
  final String trackId;
  final String songName;
  final String artistName;
  final String albumName;
  final String albumArtworkUrl;
  final int upVotes;
  final int downVotes;
  final Map<String, dynamic> votedBy; // Changed type to be more flexible

  Track({
    required this.trackId,
    required this.songName,
    required this.artistName,
    required this.albumName,
    required this.albumArtworkUrl,
    required this.upVotes,
    required this.downVotes,
    required this.votedBy,
  });

// Using a facotry constructor offers more control and enable type checking
// handling the JSON parsing here is good practice (Separation of Concerns)

// The factory constructor takes a JSON object and returns a type safe Track DART object
  factory Track.fromMap(Map<String, dynamic> data) {
    return Track(
      trackId: data['trackId'] ?? '',
      artistName: data['artistName'] ?? '',
      songName: data['songName'] ?? '',
      albumName: data['albumName'] ?? '',
      albumArtworkUrl: data['albumArtworkUrl'] ?? '',
      upVotes: data['upVotes'] ?? 0,
      downVotes: data['downVotes'] ?? 0,
      votedBy: (data['votedBy'] as Map<String, dynamic>?) ??
          {}, // Cast and provide default empty map
    );
  }
}
