import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/state/session_state.dart';

class CurrentSessionCard extends StatelessWidget {
  const CurrentSessionCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionState>(
      builder: (context, sessionState, _) {
        // initial load of sessions
        if (sessionState.sessionId.isEmpty) {
          return const SizedBox.shrink(); // No sessions to display
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Current Session",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            GestureDetector(
              onTap: () {
                // Navigate to the session page
                Navigator.pushNamed(
                    context, '/session/${sessionState.sessionId}');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sessionState.sessionName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        sessionState.sessionDescription,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      // ListView.separated(
                      //   scrollDirection: Axis.horizontal,
                      //   itemCount: users.length,
                      //   separatorBuilder: (context, index) =>
                      //       const SizedBox(width: 5),
                      //   itemBuilder: (context, index) {
                      //     return CircleAvatar(
                      //       radius: 15,
                      //       backgroundImage: NetworkImage(users[index]),
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                  Text("Hosted by ${sessionState.hostDisplayName}",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          )),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
