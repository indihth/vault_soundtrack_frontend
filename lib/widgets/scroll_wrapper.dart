import 'package:flutter/material.dart';

class ScrollWrapper extends StatelessWidget {
  final Widget child;
  final bool reverse;

  const ScrollWrapper({
    super.key,
    required this.child,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: reverse,
      physics: const BouncingScrollPhysics(),
      child: child,
    );
  }
}
