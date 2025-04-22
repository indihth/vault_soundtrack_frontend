import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/services/database_services.dart';
import 'package:vault_soundtrack_frontend/state/session_state.dart';
import 'package:vault_soundtrack_frontend/utils/ui_helpers.dart';

class SessionListPage extends StatelessWidget {
  const SessionListPage({Key? key}) : super(key: key);

  Future<void> _handleSessionSelect(
      BuildContext context, DocumentSnapshot session) async {
    try {
      final sessionState = Provider.of<SessionState>(context, listen: false);
      // await sessionState.reOpenSession(session.id, session);

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
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseServices.getCollectionStream('sessions'),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['sessionName'] ?? 'Unnamed Session'),
                subtitle: Text(data['description'] ?? 'No description'),
                onTap: () => _handleSessionSelect(context, doc),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
