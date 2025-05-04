import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/state/user_state.dart';
import 'package:vault_soundtrack_frontend/widgets/my_button.dart';
import 'package:vault_soundtrack_frontend/widgets/my_text_field.dart';
import 'package:vault_soundtrack_frontend/helper/helper_functions.dart';
import 'package:vault_soundtrack_frontend/widgets/scroll_wrapper.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  bool isLoading = false; // loading indicator

  late UserState _userState; // user state

  @override
  void initState() {
    super.initState();

    // Initialize UserState
    _userState = Provider.of<UserState>(context, listen: false);
  }

  // sign user in method
  void login() async {
    // show loading indicator
    setState(() {
      isLoading = true;
    });

    // wraping in scheduler to ensures any animations complete before executing signin
    // smoother ui rendering and no dropped frames
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // try sign user in
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);

        // Update UserState after successful login
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          _userState.setDisplayName(user.displayName ?? 'User');
          // await _userState.updateUserState();
        }

        // hide loading indicator
        setState(() {
          isLoading = false;
        });
      } on FirebaseAuthException catch (e) {
        // hide loading indicator
        setState(() {
          isLoading = false;
        });
        displayMessageToUser(context, e.code); // display error message to user
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ScrollWrapper(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),

                  // logo
                  Icon(
                    Icons.person,
                    size: 80,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),

                  const SizedBox(height: 25),

                  Text('T H E  V A U L T',
                      style: Theme.of(context).textTheme.titleLarge),

                  const SizedBox(height: 25),

                  const SizedBox(height: 25),

                  // email textfield
                  MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    textInputType: TextInputType.emailAddress,
                    obscureText: false,
                  ),

                  const SizedBox(height: 10),

                  // password textfield
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    textInputAction: TextInputAction.done,
                    obscureText: true,
                  ),

                  const SizedBox(height: 10),

                  // forgot password?
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.end,
                  //     children: [
                  //       Text(
                  //         'Forgot Password?',
                  //         style: TextStyle(color: Colors.grey[600]),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  const SizedBox(height: 25),

                  // sign in button
                  MyButton(
                    text: 'Sign In',
                    onTap: login,
                  ),

                  const SizedBox(height: 50),

                  // or continue with
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  // not a member? register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary)),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text("Register Here",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
