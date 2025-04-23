import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/state/session_state.dart';

class PrimarySessionCard extends StatelessWidget {
  const PrimarySessionCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionState>(
      builder: (context, sessionState, _) {
        // if no active session, display most recent session with more details
        if (sessionState.sessionId.isEmpty) {
          // return const SizedBox(
          //   height: 40,
          // ); // No sessions to display
          // return const SizedBox.shrink(); // No sessions to display
          return SizedBox(
            height: 80,
            child: Center(
              child: Text("No active session",
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 42),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Current Session",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    // color: Color.fromARGB(255, 255, 255, 255),
                    ),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/live-session'),
                behavior: HitTestBehavior.opaque, //
                child: Container(
                  // needs to be wrapped in container to be tappable
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sessionState.sessionName,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            sessionState.sessionDescription,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                      Text("Hosted by ${sessionState.hostDisplayName}",
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              )),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
