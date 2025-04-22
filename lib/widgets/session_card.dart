import 'package:flutter/material.dart';

class SessionCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  const SessionCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      // height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                // width: 150,
                // height: 150,
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 8.0),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8.0),
          // Text(
          //   description,
          //   style: Theme.of(context).textTheme.bodySmall,
          // ),
          // const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
