import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/services/session_image_services.dart';
import 'package:vault_soundtrack_frontend/state/session_state.dart';
import 'package:vault_soundtrack_frontend/widgets/image_upload_btn.dart';
import 'package:vault_soundtrack_frontend/widgets/my_button.dart';
import 'package:vault_soundtrack_frontend/widgets/my_text_field.dart';
import 'package:vault_soundtrack_frontend/services/playlist_session_services.dart';
import 'package:vault_soundtrack_frontend/utils/ui_helpers.dart';

class CreateSessionPage extends StatefulWidget {
  const CreateSessionPage({super.key});

  @override
  State<CreateSessionPage> createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends State<CreateSessionPage> {
  String? sessionMessage; // message from the server API request
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading =
      false; // To display loading indicator when waiting for API response

  handleStartSession() async {
    try {
      // Display loading indicator while waiting
      setState(() {
        _isLoading = true;
      });

      // Get the SessionState from the Provider as an instance
      final sessionState = Provider.of<SessionState>(context, listen: false);
      // make the API request and store in response
      final response = await sessionState.createSession(
          _titleController.text, _descriptionController.text);
      // final response = await PlaylistSessionServices.createPlaylistSession(
      //     _titleController.text, _descriptionController.text);

      // if the response is successful, navigate to the waiting room
      if (response["success"]) {
        await Navigator.pushReplacementNamed(context, '/waiting-room');

        // set state after navigation to avoid unnecessary rebuilds and flashing of previous screen
        setState(() {
          _isLoading = false;
        });
      } else {
        UIHelpers.showSnackBar(context, 'Failed to create session',
            isError: true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      UIHelpers.showSnackBar(context, 'Failed to create session - $e',
          isError: true);
      print(
          '####################################################### Failed to create session - $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // If waiting on API response, display loading indicator
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return ChangeNotifierProvider<SessionImageServices>(
      create: (context) => SessionImageServices(),
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Create Session',
                    style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 24),

                // pick image text
                // Text('Pick an image for your session',
                //     style: Theme.of(context).textTheme.titleLarge),
                // ImageUploadBtn(),
                MyTextField(
                    hintText: "Playlist title",
                    obscureText: false,
                    controller: _titleController),
                SizedBox(height: 16),
                MyTextField(
                    hintText: "Dscription",
                    obscureText: false,
                    controller: _descriptionController),
                SizedBox(height: 16),
                Text('Create Session Page'),
                MyButton(
                  text: "Create session",
                  onTap: handleStartSession,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
