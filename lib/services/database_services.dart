import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vault_soundtrack_frontend/models/playlist.dart';

class DatabaseServices {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Playlist from snapshot
  static Playlist _playlistFromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Playlist(
        title: data['title'],
        description: data['description'],
        tracks: data['tracks']);
  }

  static Future<DocumentReference> createDocument(
      String collection, Map<String, dynamic> data) async {
    final docRef = await _db.collection(collection).add(data);
    return docRef;
  }

  static Future<void> updateDocument(
      String collection, String docId, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(docId).update(data);
  }

  static Future<void> deleteDocument(String collection, String docId) async {
    await _db.collection(collection).doc(docId).delete();
  }

  static Stream<QuerySnapshot> getCollectionStream(String collection) {
    return _db.collection(collection).snapshots();
  }

  // Get a stream for a single document
  Stream<DocumentSnapshot> getDocumentStream(String collection, String docId) {
    return _db.collection(collection).doc(docId).snapshots();
  }

  static Future<DocumentSnapshot> getDocument(
      String collection, String docId) async {
    final doc = await _db.collection(collection).doc(docId).get();
    return doc;
  }
}
