import 'package:flutter/material.dart';
import 'package:vault_soundtrack_frontend/components/my_button.dart';
import 'package:vault_soundtrack_frontend/components/my_text_field.dart';

class LoginPage extends StatelessWidget {
  // text controller
  final TextEditingController emailController = TextEditingController();

  // password controller
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  void login() {
    print('Email: ${emailController.text}');
    print('Password: ${passwordController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // logo
              Icon(
                Icons.person,
                size: 80,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),

              const SizedBox(height: 25),

              // app name
              Text(
                'T H E  V A U L T',
                style: TextStyle(fontSize: 20),
              ),

              const SizedBox(height: 25),

              // email input
              MyTextField(
                  hintText: 'Email',
                  obscureText: false,
                  controller: emailController),

              const SizedBox(height: 10),
              //password input
              MyTextField(
                  hintText: 'Password',
                  obscureText: true,
                  controller: passwordController),

              const SizedBox(height: 10),

              // forgot password
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Forgot password?",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary)),
                ],
              ),
              // login button
              MyButton(
                text: 'Login',
                onTap: login,
              ),

              const SizedBox(height: 10),

              // no account? register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary)),
                  const SizedBox(width: 5),
                  Text("Register Here",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
