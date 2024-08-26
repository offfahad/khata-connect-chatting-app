import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import Clipboard package
import 'package:flutter_notifications/api/apis.dart';
import 'package:flutter_notifications/helpers/dialogs.dart';
import 'package:flutter_notifications/models/chat_user.dart'; // Ensure you import the appropriate model
import 'package:flutter_notifications/models/message.dart';
import 'package:flutter_notifications/models/newTransactionsModel.dart';
import 'package:gallery_saver_updated/gallery_saver.dart';
import '../helpers/my_date_util.dart';

class MessageCard extends StatelessWidget {
  final Message message;
  final String currentUserImageUrl;
  final String chatUserImageUrl;
  final bool isChatUserOnline;

  const MessageCard({
    Key? key,
    required this.message,
    required this.currentUserImageUrl,
    required this.chatUserImageUrl,
    required this.isChatUserOnline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = message.fromId == APIs.user.uid;

    if (!isCurrentUser && message.read.isEmpty) {
      APIs.updateMessageReadStatus(message);
    }

    return GestureDetector(
      onLongPress: () => _showBottomSheet(context, isCurrentUser),
      child: Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: isCurrentUser
                ? _buildCurrentUserMessage(context)
                : _buildChatUserMessage(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCurrentUserMessage(BuildContext context) {
    return [
      Flexible(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 218, 255, 176),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            border: Border.all(color: Colors.lightGreen),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              message.type == Type.text
                  ? Text(
                      message.msg,
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    )
                  : ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(15),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: message.msg,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image,
                          size: 70,
                        ),
                      ),
                    ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    MyDateUtil.getFormattedTime(
                        context: context, time: message.sent),
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.done_all_rounded,
                    color: message.read.isNotEmpty ? Colors.blue : Colors.grey,
                    size: 10,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 8),
      Stack(
        children: [
          CircleAvatar(
            radius: 15.0,
            backgroundImage: NetworkImage(currentUserImageUrl),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              height: 10.0,
              width: 10.0,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.0),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildChatUserMessage(BuildContext context) {
    return [
      Stack(
        children: [
          CircleAvatar(
            radius: 15.0,
            backgroundImage: NetworkImage(chatUserImageUrl),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              height: 10.0,
              width: 10.0,
              decoration: BoxDecoration(
                color: isChatUserOnline ? Colors.green : Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.0),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(width: 8),
      Flexible(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 221, 245, 255),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            border: Border.all(color: Colors.lightBlue),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              message.type == Type.text
                  ? Text(
                      message.msg,
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    )
                  : ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(15),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: message.msg,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image,
                          size: 70,
                        ),
                      ),
                    ),
              const SizedBox(height: 4),
              Text(
                MyDateUtil.getFormattedTime(
                    context: context, time: message.sent),
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  void _showBottomSheet(BuildContext context, bool isCurrentUser) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              children: [
                if (message.type == Type.image)
                  // Show Save Image options if the message contains an image
                  ...[
                  ListTile(
                    leading: const Icon(
                      Icons.download,
                      color: Colors.blue,
                    ),
                    title: const Text('Save Image'),
                    onTap: () async {
                      try {
                        log('Image Url: ${message.msg}');
                        bool? success = await GallerySaver.saveImage(
                          message.msg,
                          albumName: 'Khata Connect',
                        );
                        Navigator.pop(context); // Hide the bottom sheet
                        if (success != null && success) {
                          Dialogs.showSnackbar(
                              context, 'Image Successfully Saved!');
                        }
                      } catch (e) {
                        log('Error While Saving Image: $e');
                        Dialogs.showSnackbar(context, 'Error Saving Image');
                      }
                    },
                  ),
                  if (isCurrentUser)
                    ListTile(
                      leading: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      title: const Text('Delete'),
                      onTap: () async {
                        // Implement the delete functionality
                        await APIs.deleteMessage(message);
                        Navigator.pop(context); // Hide the bottom sheet
                        Dialogs.showSnackbar(context, 'Image Deleted!');
                      },
                    ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.remove_red_eye,
                      color: Colors.green,
                    ),
                    title: Text(
                        'Sent At: ${MyDateUtil.getFormattedTime(context: context, time: message.sent)}'),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.remove_red_eye,
                      color: Colors.blue,
                    ),
                    title: Text(
                        'Read At: ${message.read.isNotEmpty ? '${MyDateUtil.getMessageTime(context: context, time: message.read)}' : 'Not seen yet'}'),
                  ),
                ] else
                // Default options if the message does not contain an image
                if (isCurrentUser) ...[
                  ListTile(
                    leading: const Icon(
                      Icons.copy_all_rounded,
                      color: Colors.blue,
                    ),
                    title: const Text('Copy'),
                    onTap: () async {
                      // Copy the message text to clipboard
                      await Clipboard.setData(ClipboardData(text: message.msg));
                      // Show a snackbar to confirm the copy action
                      Navigator.pop(context); // Hide the bottom sheet
                      Dialogs.showSnackbar(context, 'Message Copied!');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.edit,
                      color: Colors.blue,
                    ),
                    title: const Text('Edit'),
                    onTap: () {
                      // Implement edit functionality
                      _showEditMessageDialog(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    title: const Text('Delete'),
                    onTap: () async {
                      // Call delete function
                      await APIs.deleteMessage(message);
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.remove_red_eye,
                      color: Colors.green,
                    ),
                    title: Text(
                        'Sent At: ${MyDateUtil.getFormattedTime(context: context, time: message.sent)}'),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.remove_red_eye,
                      color: Colors.blue,
                    ),
                    title: Text(
                        'Read At: ${message.read.isNotEmpty ? '${MyDateUtil.getMessageTime(context: context, time: message.read)}' : 'Not seen yet'}'),
                  ),
                ] else ...[
                  ListTile(
                    leading: const Icon(
                      Icons.copy_all_rounded,
                      color: Colors.blue,
                    ),
                    title: const Text('Copy'),
                    onTap: () async {
                      // Copy the message text to clipboard
                      await Clipboard.setData(ClipboardData(text: message.msg));
                      // Show a snackbar to confirm the copy action
                      Navigator.pop(context); // Hide the bottom sheet
                      Dialogs.showSnackbar(context, 'Message Copied!');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.remove_red_eye,
                      color: Colors.green,
                    ),
                    title: Text(
                        'Sent At: ${MyDateUtil.getFormattedTime(context: context, time: message.sent)}'),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.remove_red_eye,
                      color: Colors.blue,
                    ),
                    title: Text(
                        'Read At: ${message.read.isNotEmpty ? '${MyDateUtil.getMessageTime(context: context, time: message.read)}' : 'Not seen yet'}'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveImage() {
    // Implement the logic to save the image.
    // This might include downloading the image from a URL and saving it to local storage.
  }

  void _showEditMessageDialog(BuildContext context) {
    final TextEditingController _controller =
        TextEditingController(text: message.msg);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Message'),
          content: TextField(
            controller: _controller,
            maxLines: null, // Allows multiple lines
            decoration: const InputDecoration(
              hintText: 'Enter your updated message',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel button
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updatedMessage = _controller.text.trim();
                if (updatedMessage.isNotEmpty) {
                  await APIs.updateMessage(message, updatedMessage);
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
