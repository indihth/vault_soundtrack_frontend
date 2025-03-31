import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/models/track.dart';
import 'package:vault_soundtrack_frontend/services/voting.services.dart';
import 'package:vault_soundtrack_frontend/state/session_state.dart';
import 'package:vault_soundtrack_frontend/utils/ui_helpers.dart';

mixin VotingMixin<T extends StatefulWidget> on State<T> {
  bool isUpVoted = false;
  bool isDownVoted = false;
  bool isUpVoteLoading = false;
  bool isDownVoteLoading = false;

  void _addUpVote() {
    setState(() {
      isUpVoted = true;
    });
  }

  void _removeUpVote() {
    setState(() {
      isUpVoted = false;
    });
  }

  void _addDownVote() {
    setState(() {
      isDownVoted = true;
    });
  }

  void _removeDownVote() {
    setState(() {
      isDownVoted = false;
    });
  }

  void updateVoteUI(String voteType) {
    if (voteType == 'up') {
      if (isUpVoted) {
        _removeUpVote();
        isUpVoteLoading = true;
      } else if (isDownVoted) {
        _addUpVote();
        _removeDownVote();
        isUpVoteLoading = true;
        isDownVoteLoading = true;
      } else {
        _addUpVote();
        isUpVoteLoading = true;
      }
    } else if (voteType == 'down') {
      if (isDownVoted) {
        _removeDownVote();
        isDownVoteLoading = true;
      } else if (isUpVoted) {
        _addDownVote();
        _removeUpVote();
        isUpVoteLoading = true;
        isDownVoteLoading = true;
      } else {
        _addDownVote();
        isDownVoteLoading = true;
      }
    }
  }

  Future<void> handleVote(
      BuildContext context, Track track, String voteType) async {
    final originalIsUpVoted = isUpVoted;
    final originalIsDownVoted = isDownVoted;

    updateVoteUI(voteType);

    try {
      final sessionState = Provider.of<SessionState>(context, listen: false);
      if (sessionState.sessionId.isEmpty) {
        throw Exception('Session ID state is empty');
      }

      await VotingServices.handleVote(
        sessionState.sessionId,
        sessionState.playlistId,
        track.trackId,
        voteType,
      );

      setState(() {
        isUpVoteLoading = false;
        isDownVoteLoading = false;
      });
    } catch (e) {
      setState(() {
        isUpVoted = originalIsUpVoted;
        isDownVoted = originalIsDownVoted;
        isUpVoteLoading = false;
        isDownVoteLoading = false;
      });

      UIHelpers.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      throw Exception('Failed to vote on song: $e');
    }
  }
}
