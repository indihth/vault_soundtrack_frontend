import 'package:vault_soundtrack_frontend/models/track.dart';

class Playlist {
  // final int id;
  final String title;
  // final List<String> users;
  // final String image;
  final String description;
  // final Map<String, String> externaUrls;
  // final List<Map<String, String?>> images;
  // final Map<String, String> owner;
  final List<Track> tracks;

  Playlist({
    //   required this.id,
    required this.title,
    // required this.users,
    // required this.image,
    required this.description,
    // required this.externaUrls,
    // required this.images,
    // required this.owner
    required this.tracks,
  });

  // Factory method to convert JSON into a Playlist object
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      // id: json['id'],
      title: json['title'],
      // users: json['users'],
      // image: json['image'],
      description: json['description'],
      // externaUrls: json['external_urls'],
      // images: json['images'],
      // owner: json['owner'],
      tracks:
          (json['tracks'] as List).map((item) => Track.fromJson(item)).toList(),
    );
  }
}
