import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:vault_soundtrack_frontend/services/playlist_session_services.dart';
import 'package:vault_soundtrack_frontend/services/user_services.dart';

class SessionState extends ChangeNotifier {
  // The current session ID
  String _sessionId = '';
  String _playlistId = '';
  String _sessionName = '';
  String _sessionDescription = '';
  String _hostDisplayName = '';
  bool _isHost = false;
  bool _isActive = false;
  bool _isWaiting = false;

  bool _isJoining = false;
  bool _isViewingMode = false;

  // Variables for viewing past sessions - these won't affect the active session
  String _viewingSessionId = '';
  String _viewingPlaylistId = '';
  String _viewingSessionName = '';
  String _viewingSessionDescription = '';
  String _viewingHostDisplayName = '';

  // Past sessions - used to store the past sessions of the user
  List<Map<String, dynamic>> _pastSessions = [];
  bool _isLoading = false; // flag for sessions loading

  // Track users in session as they join
  List<Map<String, dynamic>> _sessionUsers = [];

  // Getters - dynamically returns viewingMode or active session data
  String get sessionId => _isViewingMode ? _viewingSessionId : _sessionId;
  String get playlistId => _isViewingMode ? _viewingPlaylistId : _playlistId;
  String get sessionName => _isViewingMode ? _viewingSessionName : _sessionName;
  String get sessionDescription =>
      _isViewingMode ? _viewingSessionDescription : _sessionDescription;
  String get hostDisplayName =>
      _isViewingMode ? _viewingHostDisplayName : _hostDisplayName;
  bool get isHost => _isHost;
  bool get isActive => _isActive;
  bool get isWaiting => _isWaiting;
  bool get isJoining => _isJoining;
  List<Map<String, dynamic>> get pastSessions => _pastSessions;
  List<Map<String, dynamic>> get sessionUsers => _sessionUsers;
  bool get isLoading => _isLoading;
  bool get isViewingMode => _isViewingMode;

  // Setup stream subscription to listen for changes in the session state
  StreamSubscription? _sessionStateSubscription;

  // Methods

  // view ended session
  Future<void> viewPastSession(
      String sessionId, Map<String, dynamic> session) async {
    try {
      // Use the viewing-specific state variables instead of updating active session data
      _viewingSessionId = sessionId;
      _viewingSessionName = session['sessionName'] ?? '';
      _viewingSessionDescription = session['description'] ?? '';
      _viewingHostDisplayName = session['hostDisplayName'] ?? '';
      _viewingPlaylistId = session['playlistId'] ?? '';

      // Set viewing mode to true
      setViewingMode(true);
    } catch (e) {
      throw Exception('Failed to view past session - $e');
    }
  }

  // Clear viewing state when exiting viewing mode
  void clearViewingState() {
    _viewingSessionId = '';
    _viewingPlaylistId = '';
    _viewingSessionName = '';
    _viewingSessionDescription = '';
    _viewingHostDisplayName = '';
    _isViewingMode = false;
    notifyListeners();
  }

  // load past sessions if not already loaded or force refresh
  Future<void> loadPastSessions({bool forceRefresh = false}) async {
    // skip if already loading or if data exists and no force refresh
    if (_isLoading || (_pastSessions.isNotEmpty && !forceRefresh)) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      var userSessions = await UserServices.getUserSessions();

      // seperate active sessions from past sessions
      var activeSessions = userSessions.where((session) {
        return session['status'] == 'active' || session['status'] == 'waiting';
      }).toList();

      _pastSessions = userSessions.where((session) {
        return session['status'] == 'ended';
      }).toList();

      print('active sessions: $activeSessions');
      print('past sessions: $_pastSessions');
    } catch (e) {
      print('Error loading sessions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refreshSessions() {
    // called when a a user is done with a new session
    loadPastSessions(forceRefresh: true);
  }

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

          // parse session users and update state
          _parseSessionUsers(data);

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
          } else if (status == 'waiting' && !_isWaiting) {
            // Session is in waiting status
            setIsWaiting(true);
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

// handle session users - convert from Map to List
  void _parseSessionUsers(Map<String, dynamic> data) {
    final users = data['users'];

    // clear existing users when no users in data
    if (users == null) {
      _sessionUsers = [];
      notifyListeners();
      return;
    }

    try {
      // use .entries.map to convert to a list of maps
      _sessionUsers = users.entries.map<Map<String, dynamic>>((entry) {
        final userData = entry.value;
        if (userData is Map<String, dynamic>) {
          return {
            // 'userId': entry.key,
            'displayName': userData['displayName'] ?? 'Unknown',
            // 'isHost': userData['isHost'] ?? false,
            // 'isActive': userData['isActive'] ?? false,
          };
        } else {
          // Fallback for simple string values
          return {
            // 'userId': entry.key,
            'displayName': userData.toString(),
            // 'isHost': false,
            // 'isActive': true,
          };
        }
      }).toList();
      print('########################## session users: $_sessionUsers');
      notifyListeners();
    } catch (e) {
      print('Error parsing session users: $e');
      _sessionUsers = []; // reset to empty list on error
      notifyListeners();
    }
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

  Future<Map<String, dynamic>> joinSession(String sessionId,
      {bool isLateJoin = false}) async {
    // Join a session - use the Services class directly to join a session
    final session = await PlaylistSessionServices.joinPlaylistSession(sessionId,
        isLateJoin: isLateJoin);

    final sessionName = session['data']['sessionName'];
    final sessionDescription = session['data']['description'];
    final hostDisplayName = session['data']['hostDisplayName'];
    final playlistId = session['data']['playlistId']; // for late joins only
    final isHost = false;
    setSessionName(sessionName);
    setSessionId(sessionId);
    setSessionDescription(sessionDescription);
    setHostDisplayName(hostDisplayName);
    setIsHost(isHost);

    print('playlistId: ${session['data']}');

    // for late join only
    if (isLateJoin && playlistId != null) {
      setPlaylistId(playlistId);
      setIsActive(true); // immediately set to active
    }

    // Start listener
    listenToSessionStatus(sessionId);

    return session;
  }

  Future<void> joinExistingSession(String sessionId, String playlistId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Sync user's playlist with session
      await PlaylistSessionServices.syncPlaylist(
        sessionId: sessionId,
        playlistId: playlistId,
        userId: userId,
      );

      // Update session state
      _sessionId = sessionId;
      _playlistId = playlistId;
      notifyListeners();

      // Start listener
      listenToSessionStatus(sessionId);
    } catch (e) {
      throw Exception('Failed to join session: $e');
    }
  }

  // End session - use when the host ends the session
  Future<Map<String, dynamic>> endSession(String sessionId) async {
    try {
      await PlaylistSessionServices.updateSessionStatus(sessionId, "ended");

      // Clear the session state after changing the status - BUG: causing 'no playlistId' onscreen error
      // clearSessionState();
      return {'status': 'ended'};
    } catch (e) {
      throw Exception('Failed to end session - $e');
    }
  }

  // Re-open session
  Future<void> reOpenSession(
      String sessionId, Map<String, dynamic> session) async {
    // Future<void> reOpenSession(String sessionId, DocumentSnapshot session) async {
    try {
      await PlaylistSessionServices.updateSessionStatus(sessionId, 'active');

      // Update session state
      // final data = session.data() as Map<String, dynamic>;

      // Load new session data into state
      setSessionId(sessionId);
      // setSessionId(session.id);
      setSessionName(session['sessionName'] ?? '');
      setSessionDescription(session['description'] ?? '');
      setHostDisplayName(session['hostDisplayName'] ?? '');
      setIsHost(true); // Set for testing

      // For joining directly to the live session page
      setPlaylistId(session['playlistId'] ?? '');
      setIsActive(true);

      // Start listener
      listenToSessionStatus(sessionId);
    } catch (e) {
      throw Exception('Failed to re-open session - $e');
    }
  }

  @override
  void dispose() {
    // Cancel the subscription when the state is disposed
    _sessionStateSubscription?.cancel();
    super.dispose();
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
    _isWaiting = false;
    // Don't clear viewing mode or viewing data here
    notifyListeners();
  }

  void setViewingMode(bool isViewing) {
    _isViewingMode = isViewing;
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

  void setIsWaiting(bool isWaiting) {
    _isWaiting = isWaiting;
    notifyListeners();
  }

  void setIsJoining(bool isJoining) {
    _isJoining = isJoining;
    notifyListeners();
  }
}
