import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/state/user_state.dart';
import 'package:vault_soundtrack_frontend/widgets/my_button.dart';
import 'package:vault_soundtrack_frontend/widgets/my_text_field.dart';
import 'package:vault_soundtrack_frontend/helper/helper_functions.dart';
import 'package:vault_soundtrack_frontend/widgets/scroll_wrapper.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPwController = TextEditingController();

  late UserState _userState;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize UserState
    _userState = Provider.of<UserState>(context, listen: false);
  }

  // sign user in method
  void registerUser() async {
    // check if passwords match
    if (passwordController.text != confirmPwController.text) {
      // if passwords don't match, show error message
      displayMessageToUser(context, "Passwords do not match, try again");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // register user
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);
      // update user display name - handle on backend? or update immediately?

      // Set display name - working??
      await userCredential.user?.updateDisplayName(usernameController.text);

      // Update UserState
      _userState.setDisplayName(usernameController.text);
      _userState.setNewUserFlag();

      print("User registered: ${userCredential.user?.uid}");

      // add user document to firestore
      await _userState.createUserDocument(usernameController.text);

      print("User document created");
    } on FirebaseAuthException catch (e) {
      displayMessageToUser(context, e.code); // display error message to user
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // custom widget with scrollable functionality
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

                  Text(
                    'T H E  V A U L T',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: 25),

                  const SizedBox(height: 25),

                  // username textfield
                  MyTextField(
                    controller: usernameController,
                    hintText: 'Username',
                    obscureText: false,
                  ),

                  const SizedBox(height: 10),
                  // username textfield
                  MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                  ),

                  const SizedBox(height: 10),

                  // password textfield
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),

                  const SizedBox(height: 10),

                  // confirm password textfield
                  MyTextField(
                    controller: confirmPwController,
                    hintText: 'Confirm password',
                    obscureText: true,
                  ),

                  const SizedBox(height: 10),

                  // forgot password?
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // sign in button
                  MyButton(
                    text: 'Register',
                    onTap: isLoading ? null : registerUser,
                  ),

                  const SizedBox(height: 50),

                  // not a member? register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("ALready have an account?",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary)),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text("Login Here",
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
