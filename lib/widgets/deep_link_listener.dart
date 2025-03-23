import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeepLinkListener extends StatefulWidget {
  const DeepLinkListener({super.key, required this.child});
  final Widget child;

  @override
  State<DeepLinkListener> createState() => _DeepLinkListenerState();
}

class _DeepLinkListenerState extends State<DeepLinkListener> {
  @override
  void initState() {
    final appLinks = AppLinks();

    // subscribe to incoming links
    final sub = appLinks.uriLinkStream.listen((Uri uri) {
      print('Received uri: ${uri.toString()}');

      final id = uri.pathSegments.lastOrNull;

      // if the path is 'join-session' and there is an id
      // push the join-session page with the id as an argument
      if (uri.pathSegments.first == 'join-session' && id != null) {
        Navigator.of(context).pushNamed('/join-session', arguments: id);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
