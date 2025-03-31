import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:vault_soundtrack_frontend/services/playlist_session_services.dart';
import 'package:vault_soundtrack_frontend/services/playlist_sync.services.dart';

class SessionState extends ChangeNotifier {
  // The current session ID
  String _sessionId = '';
  String _playlistId = '';
  String _sessionName = '';
  String _sessionDescription = '';
  String _hostDisplayName = '';
  bool _isHost = false;
  bool _isActive = false;
  bool _isJoining = false; // Flag to indicate if the user is joining a session

  // Getters
  String get sessionId => _sessionId;
  String get playlistId => _playlistId;
  String get sessionName => _sessionName;
  String get sessionDescription => _sessionDescription;
  String get hostDisplayName => _hostDisplayName;
  bool get isHost => _isHost;
  bool get isActive => _isActive;
  bool get isJoining => _isJoining;

  // Setup stream subscription to listen for changes in the session state
  StreamSubscription? _sessionStateSubscription;

  // Listen to session status changes in Firestore, indicate if host has started session
  void listenToSessionStatus(String sessionId) {
    // Cancel any existing subscription before creating a new one
    if (_sessionStateSubscription == null || this.sessionId != sessionId) {
      // Cancel any existing subscription before creating a new one
      _sessionStateSubscription?.cancel();

      // Set the session ID -
      setSessionId(sessionId);

      // Listen to the session changes in Firestore
      _sessionStateSubscription = FirebaseFirestore.instance
          .collection('sessions')
          .doc(sessionId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          final status =
              data['status'] ?? 'waiting'; // Default to 'waiting' if not set

          if (status == 'active' && !_isActive) {
            // Session is now active
            setIsActive(true);

            // Check if the playlist ID exists then set it
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
          } else if (status == 'ended' && _isActive) {
            // Session has ended
            setIsActive(false);
            clearSessionState(); // Clear session state when the session ends
          }
        }
      });
    }
  }

  @override
  void dispose() {
    // Cancel the subscription when the state is disposed
    _sessionStateSubscription?.cancel();
    super.dispose();
  }

  void stopListeningToSessionStatus() {
    // Cancel the subscription when the state is disposed
    _sessionStateSubscription?.cancel();

    // Reset the subscription
    _sessionStateSubscription = null;
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

      // Start listener
      listenToSessionStatus(sessionId);

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

    // Start listener
    listenToSessionStatus(sessionId);

    return session;
  }

  Future<void> joinExistingSession(String sessionId, String playlistId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Sync user's playlist with session
      await PlaylistSyncServices.syncUserPlaylist(
        sessionId: sessionId,
        playlistId: playlistId,
        userId: userId,
      );

      // Update session state
      _sessionId = sessionId;
      _playlistId = playlistId;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to join session: $e');
    }
  }

  // End session - use when the host ends the session
  Future<void> endSession(String sessionId) async {
    try {
      await PlaylistSessionServices.updateSessionStatus(sessionId, "ended");

      // Clear the session state after changing the status
      clearSessionState();
    } catch (e) {
      throw Exception('Failed to end session - $e');
    }
  }

  // Clear the session state - use when leaving a session
  void clearSessionState() {
    // First stop listening to session status changes - avoids memory leaks and unnecessary updates
    stopListeningToSessionStatus();

    // Clear the session state
    _sessionId = '';
    _playlistId = '';
    _sessionName = '';
    _sessionDescription = '';
    _hostDisplayName = '';
    _isHost = false;
    _isActive = false;
    notifyListeners();
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

  void setIsJoining(bool isJoining) {
    _isJoining = isJoining;
    notifyListeners();
  }
}
