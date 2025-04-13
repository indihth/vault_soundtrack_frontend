import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vault_soundtrack_frontend/utils/constants.dart';

class SessionImageServices extends ChangeNotifier {
  File? _image;
  String? _downloadUrl;
  bool _isUploading = false;
  String? _error;

  // Getters
  File? get image => _image;
  String? get downloadUrl => _downloadUrl;
  bool get isUploading => _isUploading;
  String? get error => _error;

// define the image picker instance
  final ImagePicker _picker = ImagePicker();

  Future<void> pickAndUploadImage({required String sessionId}) async {
    try {
      // set initial states and notify listeners
      _error = null;
      _isUploading = true;
      notifyListeners();

      // pick image from gallery
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) {
        _isUploading = false;
        notifyListeners();
        return;
      }

      _image = File(picked.path);

      // create filename using sessionId and current timestamp
      final now = DateTime.now();
      final fileName = '${sessionId}_${now.millisecondsSinceEpoch}.jpg';

      // upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('session_images')
          .child(fileName);

      await storageRef.putFile(_image!);
      final _downloadUrl = await storageRef.getDownloadURL();

      // add image url to session document in Firestore
      _addImageUrlToSession(sessionId, _downloadUrl);
    } catch (e) {
      _error = 'Upload failed: ${e.toString()}';
      throw Exception('Failed to upload image: $e');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<String> _addImageUrlToSession(
      String sessionId, String imageUrl) async {
    try {
      final userToken = await FirebaseAuth.instance.currentUser?.getIdToken();

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/sessions/$sessionId/image'),
        headers: {
          'Authorization': 'Bearer $userToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'imageUrl': imageUrl,
          'sessionId': sessionId,
        }),
      );

      if (response.statusCode == 200) {
        return imageUrl;
      } else {
        _error = 'Failed to add image URL to session: ${response.statusCode}';
        notifyListeners();
        throw Exception('Failed to add image URL to session');
      }
    } catch (e) {
      _error = 'Failed to add image URL to session: ${e.toString()}';
      notifyListeners();
      throw Exception('Failed to add image URL to session: $e');
    }
  }

  void clear() {
    _image = null;
    _downloadUrl = null;
    _isUploading = false;
    _error = null;
    notifyListeners();
  }
}
