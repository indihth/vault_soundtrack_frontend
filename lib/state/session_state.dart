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

  // current session users? update UI as users join

  // Getters
  String get sessionId => _sessionId;
  String get playlistId => _playlistId;
  String get sessionName => _sessionName;
  String get sessionDescription => _sessionDescription;
  String get hostDisplayName => _hostDisplayName;
  bool get isHost => _isHost;
  bool get isActive => _isActive;

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
      final isActive = true; // The session is active when created
      // Set the session ID
      setSessionName(sessionName);
      setSessionId(sessionId);
      setSessionDescription(sessionDescription);
      setHostDisplayName(hostDisplayName);
      setIsHost(isHost);
      setIsActive(isActive);

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
    final isActive = true; // The session is active when joined
    // Set the session ID
    setSessionName(sessionName);
    setSessionId(sessionId);
    setSessionDescription(sessionDescription);
    setHostDisplayName(hostDisplayName);
    setIsHost(isHost);
    setIsActive(isActive);

    print(
        '--------------------------------------------- session state ID: $sessionId');

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
