import 'package:flutter/material.dart';
import 'package:flutter_notifications/api/apis.dart';
import 'package:flutter_notifications/models/comments.dart';

class CommentCard extends StatelessWidget {
  final CommentFirebase comment;

  const CommentCard({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = comment.fromId ==
        APIs.user.uid; // Assuming 'user.uid' is the current user's ID

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blueAccent : Colors.green,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          comment.commentText,
          style: TextStyle(
            color: isCurrentUser ? Colors.white : Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }
}


