class PlaylistSession {
  final String id;
  final List<String> userIds;
  final String timestamp;

  PlaylistSession({
    required this.id,
    required this.userIds,
    required this.timestamp,
  });

// The factory constructor takes a JSON object and returns a type safe DART object
  factory PlaylistSession.fromJson(Map<String, dynamic> json) {
    return PlaylistSession(
      id: json['id'] ?? '',
      userIds: json['userIds'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}

// Example playlist session object
// playlists: {
//   sessionId1: {
//     users: {
//       userId1: { listeningHistory: [songId1, songId2, ...], votes: { songId3: 1, songId4: -1, ... } },
//       userId2: { listeningHistory: [songId5, songId6, ...], votes: { songId1: 1, songId7: -1, ... } },
//       // ... more users ...
//     },
//     playlist: [songIdA, songIdB, songIdC, ...] // Ordered array of song IDs
//   },
//   sessionId2: { ... },
//   // ... more sessions ...
// }
