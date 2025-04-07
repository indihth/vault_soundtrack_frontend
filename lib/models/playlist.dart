import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vault_soundtrack_frontend/models/track.dart';

class Playlist {
  final String title;
  final String description;
  final List<Track> tracks;

  Playlist(
      {required this.title, required this.description, required this.tracks});

  factory Playlist.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, Track> tracksMap = {};

    // Process the tracks map where trackId is the key
    if (data['tracks'] != null && data['tracks'] is Map) {
      // Convert each entry in the tracks map to a Track object
      (data['tracks'] as Map<String, dynamic>).forEach((trackId, trackData) {
        // Make sure trackData includes the trackId
        if (trackData is Map<String, dynamic>) {
          Map<String, dynamic> trackWithId = {
            ...trackData,
            'trackId': trackId,
          };
          tracksMap[trackId] = Track.fromMap(trackWithId);
        }
      });
    }

    // Get track order from API
    List<String> order =
        data['trackOrder'] != null ? List<String>.from(data['trackOrder']) : [];

    // Create ordered tracks list based on trackOrder
    List<Track> orderedTracks = [];
    for (String id in order) {
      if (tracksMap.containsKey(id)) {
        orderedTracks.add(tracksMap[id]!);
      }
    }

    // If some tracks aren't in the order, add them at the end
    if (tracksMap.isNotEmpty) {
      for (var trackId in tracksMap.keys) {
        if (!order.contains(trackId)) {
          orderedTracks.add(tracksMap[trackId]!);
        }
      }
    }

    return Playlist(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      tracks: orderedTracks,
    );
  }

  // factory Playlist.fromJson(Map<String, dynamic> json) {
  //   // Create a map to store tracks by ID for quick lookup
  //   Map<String, Track> tracksMap = {};

  //   // Process the tracks map where trackId is the key
  //   if (json['tracks'] != null && json['tracks'] is Map) {
  //     // Convert each entry in the tracks map to a Track object
  //     (json['tracks'] as Map<String, dynamic>).forEach((trackId, trackData) {
  //       // Make sure trackData includes the trackId
  //       if (trackData is Map<String, dynamic>) {
  //         Map<String, dynamic> trackWithId = {
  //           ...trackData,
  //           'trackId': trackId,
  //         };
  //         tracksMap[trackId] = Track.fromJson(trackWithId);
  //       }
  //     });
  //   }

  //   // Get track order from API
  //   List<String> order =
  //       json['trackOrder'] != null ? List<String>.from(json['trackOrder']) : [];

  //   // Create ordered tracks list based on trackOrder
  //   List<Track> orderedTracks = [];
  //   for (String id in order) {
  //     if (tracksMap.containsKey(id)) {
  //       orderedTracks.add(tracksMap[id]!);
  //     }
  //   }

  //   // If some tracks aren't in the order, add them at the end
  //   if (tracksMap.isNotEmpty) {
  //     for (var trackId in tracksMap.keys) {
  //       if (!order.contains(trackId)) {
  //         orderedTracks.add(tracksMap[trackId]!);
  //       }
  //     }
  //   }

  //   return Playlist(
  //     title: json['title'] ?? '',
  //     description: json['description'] ?? '',
  //     tracks: orderedTracks,
  //   );
  // }
}
