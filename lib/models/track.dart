class Track {
  final String trackId;
  final String songName;
  final String artistName;
  final String albumName;
  final String albumArtworkUrl;
  final int upVotes;
  final int downVotes;
  final Map<String, VoteStatus> votedBy;

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

  // Helper methods to check if the current user has voted on this track - use in UI
  bool hasUserUpVoted(String? userId) {
    if (userId == null) return false;
    return votedBy[userId]?.upVoted ?? false;
  }

  bool hasUserDownVoted(String? userId) {
    if (userId == null) return false;
    return votedBy[userId]?.downVoted ?? false;
  }

  factory Track.fromMap(Map<String, dynamic> data) {
    final votedByData = data['votedBy'] as Map<String, dynamic>? ?? {};
    return Track(
      trackId: data['trackId'] ?? '',
      artistName: data['artistName'] ?? '',
      songName: data['songName'] ?? '',
      albumName: data['albumName'] ?? '',
      albumArtworkUrl: data['albumArtworkUrl'] ?? '',
      upVotes: data['upVotes'] ?? 0,
      downVotes: data['downVotes'] ?? 0,
      votedBy: votedByData.map(
        (userId, votes) => MapEntry(
          userId,
          VoteStatus.fromMap(votes as Map<String, dynamic>),
        ),
      ),
    );
  }
}

// Needs own class as it's a nested object
class VoteStatus {
  final bool upVoted;
  final bool downVoted;

  VoteStatus({
    required this.upVoted,
    required this.downVoted,
  });

  factory VoteStatus.fromMap(Map<String, dynamic> data) {
    return VoteStatus(
      upVoted: data['upVoted'] ?? false,
      downVoted: data['downVoted'] ?? false,
    );
  }
}
