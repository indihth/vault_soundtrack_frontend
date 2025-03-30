import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:vault_soundtrack_frontend/services/playlist_session_services.dart';

class SessionState extends ChangeNotifier {
  // The current session ID
  String _sessionId = '';
  String _playlistId = '';
  String _sessionName = '';
  String _sessionDescription = '';
  String _hostDisplayName = '';
  bool _isHost = false;
  bool _isActive = false;

  // Getters
  String get sessionId => _sessionId;
  String get playlistId => _playlistId;
  String get sessionName => _sessionName;
  String get sessionDescription => _sessionDescription;
  String get hostDisplayName => _hostDisplayName;
  bool get isHost => _isHost;
  bool get isActive => _isActive;

  // Setup stream subscription to listen for changes in the session state
  StreamSubscription? _sessionStateSubscription;

  // Listen to session status changes in Firestore, indicate if host has started session
  void listenToSessionStatus(String sessionId) {
    // Cancel any existing subscription before creating a new one
    _sessionStateSubscription?.cancel();

    // Listen to the session changes in Firestore
    _sessionStateSubscription = FirebaseFirestore.instance
        .collection('sessions')
        .doc(sessionId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final status =
            data['status'] ?? 'something'; // Default to 'waiting' if not set
        print('--------------------------------------------- status: $status');

        if (status == 'active' && !_isActive) {
          // Session is now active
          setIsActive(true);

          if (data['playlistId'] != null) {
            final playlistId = data['playlistId'] as String;
            setPlaylistId(
                playlistId); // needed for redirect to live session page
          } else {
            throw Exception(
                'Playlist ID is null - cannot redirect to live session page');
          }

          // Notify listeners of the change
          notifyListeners();
        }
      }
    });
  }

  @override
  void dispose() {
    // Cancel the subscription when the state is disposed
    _sessionStateSubscription?.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>> createSession(
      String title, String description) async {
    try {
      // Create a new session - use the Services class directly to create a session
      final session = await PlaylistSessionServices.createPlaylistSession(
          title, description);

      final sessionName = session['data']['sessionName'];
      final sessionId = session['data']['sessionId'];
      final sessionDescription = session['data']['description'];
      final hostDisplayName = session['data']['hostDisplayName'];
      final isHost = true; // The user who creates the session is the host
      // Set the session ID
      setSessionName(sessionName);
      setSessionId(sessionId);
      setSessionDescription(sessionDescription);
      setHostDisplayName(hostDisplayName);
      setIsHost(isHost);

      return session;
    } catch (e) {
      throw Exception('Failed to create session - $e');
    }
  }

  Future<Map<String, dynamic>> joinSession(String sessionId) async {
    // Join a session - use the Services class directly to join a session
    final session =
        await PlaylistSessionServices.joinPlaylistSession(sessionId);

    final sessionName = session['data']['sessionName'];
    final sessionDescription = session['data']['description'];
    final hostDisplayName = session['data']['hostDisplayName'];
    final isHost = false; // The user who joins the session is not the host
    // Set the session ID
    setSessionName(sessionName);
    setSessionId(sessionId);
    setSessionDescription(sessionDescription);
    setHostDisplayName(hostDisplayName);
    setIsHost(isHost);

    print(
        '--------------------------------------------- session state status at join: $isActive');

    return session;
  }

  // Set the current session ID
  void setSessionId(String sessionId) {
    _sessionId = sessionId;
    notifyListeners(); // Notify listeners of the change
  }

  void setPlaylistId(String playlistId) {
    _playlistId = playlistId;
    notifyListeners();
  }

  void setSessionName(String sessionName) {
    _sessionName = sessionName;
    notifyListeners();
  }

  void setSessionDescription(String sessionDescription) {
    _sessionDescription = sessionDescription;
    notifyListeners();
  }

  void setHostDisplayName(String hostDisplayName) {
    _hostDisplayName = hostDisplayName;
    notifyListeners();
  }

  void setIsHost(bool isHost) {
    _isHost = isHost;
    notifyListeners();
  }

  void setIsActive(bool isActive) {
    _isActive = isActive;
    notifyListeners();
  }
}
