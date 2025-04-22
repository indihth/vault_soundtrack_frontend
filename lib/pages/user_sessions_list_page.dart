import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/services/user_services.dart';
import 'package:vault_soundtrack_frontend/state/session_state.dart';
import 'package:vault_soundtrack_frontend/utils/ui_helpers.dart';
import 'package:vault_soundtrack_frontend/widgets/session_card.dart';

class UserSessionsListPage extends StatelessWidget {
  const UserSessionsListPage({Key? key}) : super(key: key);

  Future<void> _handleSessionSelect(
      BuildContext context, Map<String, dynamic> session) async {
    // BuildContext context, DocumentSnapshot session) async {
    try {
      final sessionState = Provider.of<SessionState>(context, listen: false);
      await sessionState.reOpenSession(session['id'], session);

      // Navigate to live session
      Navigator.pushReplacementNamed(context, '/live-session');
    } catch (e) {
      UIHelpers.showSnackBar(context, 'Error loading session: $e',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Sessions'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: UserServices.getUserSessions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data ?? [];

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return GestureDetector(
                onTap: () => _handleSessionSelect(context, session),
                child: SessionCard(
                  title: session['sessionName'] ?? 'Unnamed Session',
                  description: session['description'] ?? 'No description',
                  imageUrl: session['topTrackImageUrl'] ?? 'No image',
                ),
              );
              // return ListTile(
              //   title: Text(session['sessionName'] ?? 'Unnamed Session'),
              //   subtitle: Text(session['description'] ?? 'No description'),
              //   onTap: () => _handleSessionSelect(context, session),
              // );
            },
          );
        },
      ),
    );
  }
}
