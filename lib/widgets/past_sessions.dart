import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/pages/live_session_page.dart';
import 'package:vault_soundtrack_frontend/state/session_state.dart';
import 'package:vault_soundtrack_frontend/utils/ui_helpers.dart';
import 'package:vault_soundtrack_frontend/widgets/session_card.dart';

class PastSessions extends StatelessWidget {
  const PastSessions({super.key});

  Future<void> _handleSessionSelect(
      BuildContext context, Map<String, dynamic> session) async {
    // BuildContext context, DocumentSnapshot session) async {
    try {
      final sessionState = Provider.of<SessionState>(context, listen: false);
      await sessionState.viewPastSession(session['id'], session);

      // Navigate to live session
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                LiveSessionPage(viewingMode: true), // indicates viewing mode
          ),
        );
      }
    } catch (e) {
      UIHelpers.showSnackBar(context, 'Error loading session: $e',
          isError: true);
    }
  }

  List<Map<String, dynamic>> sortSessionsByDate(
      List<Map<String, dynamic>> sessions) {
    if (sessions.isEmpty || sessions.length < 2) {
      return sessions; // No need to sort if empty or only one item
    }
    try {
      // make copy of sessions to avoid mutating the original list
      final sortedSessions = List<Map<String, dynamic>>.from(sessions);

      // sort by _seconds field
      sortedSessions.sort((a, b) {
        // Access the nested _seconds field
        final int secondsA = a['updatedAt']['_seconds'] as int;
        final int secondsB = b['updatedAt']['_seconds'] as int;

        return secondsB.compareTo(secondsA);
      });

      return sortedSessions;
    } catch (e) {
      print('Error sorting sessions by date: $e');
      return sessions; // return original list if sorting fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionState>(
      builder: (context, sessionState, _) {
        // initial load of sessions
        if (sessionState.pastSessions.isEmpty && !sessionState.isLoading) {
          // wrap in addPostFrameCallback to avoid calling setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            sessionState.loadPastSessions();
          });
        }

        if (sessionState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final sortedSessions = sortSessionsByDate(sessionState.pastSessions);

        return GridView.builder(
          padding: EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two columns
            childAspectRatio: 0.75, // Adjust for card dimensions
            crossAxisSpacing: 10, // Horizontal space between items
            mainAxisSpacing: 10, // Vertical space between items
          ),
          // switch fro .builder to .separated to add spacing
          // scrollDirection: Axis.horizontal,
          itemCount: sortedSessions.length,
          itemBuilder: (context, index) {
            final session = sortedSessions[index];
            return GestureDetector(
              onTap: () => _handleSessionSelect(context, session),
              child: SessionCard(
                title: session['sessionName'] ?? 'Unnamed Session',
                description: session['description'] ?? 'No description',
                imageUrl: session['topTrackImageUrl'] ?? 'No image',
              ),
            );
          },
        );
      },
    );
    // return SessionCard();
  }
}
