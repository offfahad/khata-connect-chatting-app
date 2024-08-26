// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import Clipboard package
import 'package:flutter_notifications/api/apis.dart';
import 'package:flutter_notifications/helpers/dialogs.dart';
import 'package:flutter_notifications/models/chat_user.dart';
import 'package:flutter_notifications/models/comments.dart';
import 'package:flutter_notifications/models/newTransactionsModel.dart';
import '../helpers/my_date_util.dart';

class CommentCard extends StatelessWidget {
  final ChatUser chatUser;
  final CommentFirebase comment;
  final TransactionFirebase transaction;
  final String currentUserImageUrl;
  final String chatUserImageUrl;
  final bool isChatUserOnline;

  const CommentCard({
    super.key,
    required this.comment,
    required this.currentUserImageUrl,
    required this.chatUserImageUrl,
    required this.transaction,
    required this.isChatUserOnline,
    required this.chatUser,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = comment.fromId == APIs.user.uid;

    if (!isCurrentUser && comment.read.isEmpty) {
      APIs.updateCommentReadStatus(comment, transaction);
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
                ? _buildCurrentUserComment(context)
                : _buildChatUserComment(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCurrentUserComment(BuildContext context) {
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
              Text(
                comment.commentText,
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    MyDateUtil.getFormattedTime(
                        context: context, time: comment.timestamp),
                    style: const TextStyle(fontSize: 9, color: Colors.black54),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.done_all_rounded,
                    color: comment.read.isNotEmpty ? Colors.blue : Colors.grey,
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

  List<Widget> _buildChatUserComment(BuildContext context) {
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
              Text(
                comment.commentText,
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
              const SizedBox(height: 4),
              Text(
                MyDateUtil.getFormattedTime(
                    context: context, time: comment.timestamp),
                style: const TextStyle(fontSize: 9, color: Colors.black54),
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
              children: isCurrentUser
                  ? [
                      ListTile(
                        leading: const Icon(Icons.copy_all_rounded, color: Colors.blue,),
                        title: const Text('Copy'),
                        onTap: () async {
                          // Copy the comment text to clipboard
                          await Clipboard.setData(
                              ClipboardData(text: comment.commentText));
                          // Show a snackbar to confirm the copy action
                          Navigator.pop(context); // Hide the bottom sheet
                          Dialogs.showSnackbar(context, 'Comment Copied!');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.edit, color: Colors.blue,),
                        title: const Text('Edit'),
                        onTap: () {
                          // Implement edit functionality
                          _showEditCommentDialog(context);
                        
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete, color: Colors.red,),
                        title: const Text('Delete'),
                        onTap: () async {
                          // Call delete function
                          await APIs.deleteComment(
                              chatUser, comment, transaction);
                          Navigator.pop(context);
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.remove_red_eye, color: Colors.green,),
                        title: Text(
                            'Sent At: ${MyDateUtil.getFormattedTime(context: context, time: comment.timestamp)}'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.remove_red_eye, color: Colors.blue,),
                        title: Text(
                            'Read At: ${comment.read.isNotEmpty ? MyDateUtil.getMessageTime(context: context, time: comment.read) : 'Not seen yet'}'),
                      ),
                    ]
                  : [
                      ListTile(
                        leading: const Icon(Icons.copy_all_rounded, color: Colors.blue,),
                        title: const Text('Copy'),
                        onTap: () async {
                          // Copy the comment text to clipboard
                          await Clipboard.setData(
                              ClipboardData(text: comment.commentText));
                          // Show a snackbar to confirm the copy action
                          Navigator.pop(context); // Hide the bottom sheet
                          Dialogs.showSnackbar(context, 'Comment Copied!');
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.remove_red_eye, color: Colors.green,),
                        title: Text(
                            'Sent At: ${MyDateUtil.getMessageTime(context: context, time: comment.timestamp)}',),
                      ),
                      ListTile(
                        leading: const Icon(Icons.remove_red_eye, color: Colors.blue,),
                        title: Text(
                            'Read At: ${comment.read.isNotEmpty ? MyDateUtil.getMessageTime(context: context, time: comment.read) : 'Not seen yet'}'),
                      ),
                    ],
              // ? 'Read At: Not seen yet'
              //  : 'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
            ),
          ),
        );
      },
    );
  }

  void _showEditCommentDialog(BuildContext context) {
    final TextEditingController _controller =
        TextEditingController(text: comment.commentText);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Comment'),
          content: TextField(
            controller: _controller,
            maxLines: null, // Allows multiple lines
            decoration: const InputDecoration(
              hintText: 'Enter your updated comment',
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
                final updatedComment = _controller.text.trim();
                if (updatedComment.isNotEmpty) {
                  await APIs.editComment(
                      chatUser, comment, transaction, updatedComment);
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
