import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, danger }

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  // final ButtonVariant variant;

  const MyButton({
    super.key,
    required this.text,
    required this.onTap,
    // this.variant = ButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    // return GestureDetector(
    //   onTap: onTap,
    //   child: Container(
    //     width: double.infinity,
    //     padding: const EdgeInsets.symmetric(vertical: 15),
    //     // decoration: BoxDecoration(
    //     //   color: Theme.of(context).colorScheme.primary,
    //     //   borderRadius: BorderRadius.circular(12),
    //     // ),
    //     child: Center(
    //       child: Text(
    //         text,
    //         style: TextStyle(
    //           color: Theme.of(context).colorScheme.primary,
    //           fontWeight: FontWeight.bold,
    //           fontSize: 16,
    //         ),
    //       ),
    //     ),
    //   ),
    // );

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            Theme.of(context).colorScheme.tertiary, // Spotify green
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Lets go!',
            style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
