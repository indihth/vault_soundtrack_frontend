import 'package:flutter/material.dart';

class VoteIcon extends StatelessWidget {
  final bool isUpVote;
  final bool isVoted;
  final bool isLoading;
  final int voteCount;
  final VoidCallback onTap;

  const VoteIcon({
    Key? key,
    required this.isUpVote,
    required this.isVoted,
    required this.isLoading,
    required this.voteCount,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            isUpVote // dynamically display up or down vote icon
                ? (isVoted ? Icons.thumb_up : Icons.thumb_up_alt_outlined)
                : (isVoted ? Icons.thumb_down : Icons.thumb_down_alt_outlined),
            color: isUpVote ? Colors.blue : Colors.grey,
          ),
          const SizedBox(height: 4.0),
          SizedBox(
            height: 16.0,
            width: 16.0,
            child: isLoading // takes loading state for up/down vote
                ? Center(
                    child: SizedBox(
                      height: 12.0,
                      width: 12.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      voteCount.toString(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12.0,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
