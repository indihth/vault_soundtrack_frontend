import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final TextEditingController controller;

  const MyTextField({
    super.key,
    required this.hintText,
    this.textInputType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    required this.obscureText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: textInputType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      decoration: InputDecoration(
        // focusColor: Theme.of(context).colorScheme.inversePrimary,
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
        // suffixIcon: IconButton(
        //     onPressed: () {
        //       controller.clear(); // clear text field when icon clicked
        //     },
        //     icon: Icon(Icons.clear)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ),
    );
  }
}
