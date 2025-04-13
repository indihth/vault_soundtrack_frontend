import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/services/session_image_services.dart';
import 'package:vault_soundtrack_frontend/state/session_state.dart';

class ImageUploadBtn extends StatelessWidget {
  const ImageUploadBtn({super.key});

  @override
  Widget build(BuildContext context) {
    // get sessionId from state
    final sessionId =
        Provider.of<SessionState>(context, listen: false).sessionId;

    return Consumer<SessionImageServices>(
      builder: (context, imageServices, child) {
        return Column(
          children: [
            if (imageServices.isUploading) const CircularProgressIndicator(),
            if (imageServices.downloadUrl != null)
              Image.network(
                  imageServices.downloadUrl!), // display image if available
            if (imageServices.error != null)
              Text(imageServices.error!,
                  style: TextStyle(color: Colors.red)), // display errors is any
            ElevatedButton(
              onPressed: imageServices.isUploading
                  ? null
                  : () {
                      context.read<SessionImageServices>().pickAndUploadImage(
                            sessionId: sessionId,
                          );
                    },
              child: const Text('Upload Image'),
            ),
          ],
        );
      },
    );
  }
}
