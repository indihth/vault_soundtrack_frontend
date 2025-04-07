// import 'package:vault_soundtrack_frontend/models/track.dart';

// class Playlist {
//   final String title;
//   final String description;
//   final List<Track> tracks;
//   final List<String> trackOrder;

//   Playlist(
//       {required this.title,
//       required this.description,
//       required this.tracks,
//       required this.trackOrder});

//   // // Factory method to convert JSON into a Playlist object
//   // factory Playlist.fromJson(Map<String, dynamic> json) {
//   //   return Playlist(
//   //     title: json['title'],
//   //     description: json['description'],
//   //     tracks: (json['tracks'] as Map<String, dynamic>)
//   //         .values
//   //         .map((item) => Track.fromJson(item as Map<String, dynamic>))
//   //         .toList(),
//   //   );
//   // }
//   factory Playlist.fromJson(Map<String, dynamic> json) {
//     List<Track> tracksList = [];
//     if (json['tracks'] != null) {
//       tracksList = (json['tracks'] as List)
//           .map((trackJson) => Track.fromJson(trackJson))
//           .toList();
//     }

//     return Playlist(
//       title: json['title'] ?? '',
//       description: json['description'] ?? '',
//       tracks: tracksList,
//       trackOrder: json['trackOrder'] != null
//           ? List<String>.from(json['trackOrder'])
//           : [],
//     );
//   }
// }
