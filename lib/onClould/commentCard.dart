import 'package:flutter/material.dart';
import 'package:flutter_notifications/api/apis.dart';
import 'package:flutter_notifications/models/comments.dart';

class CommentCard extends StatelessWidget {
  final CommentFirebase comment;
  final String currentUserImageUrl; // Current user's image URL
  final String chatUserImageUrl; // Chat user's image URL

  const CommentCard({
    Key? key,
    required this.comment,
    required this.currentUserImageUrl, // Pass the current user's image URL
    required this.chatUserImageUrl, // Pass the chat user's image URL
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = comment.fromId == APIs.user.uid;

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: isCurrentUser
              ? [
                  // Comment text
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        comment.commentText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0), // Space between text and avatar
                  // Current user's avatar
                  CircleAvatar(
                    radius: 15.0, // Small size for the avatar
                    backgroundImage: NetworkImage(currentUserImageUrl),
                  ),
                ]
              : [
                  // Chat user's avatar
                  CircleAvatar(
                    radius: 15.0, // Small size for the avatar
                    backgroundImage: NetworkImage(chatUserImageUrl),
                  ),
                  const SizedBox(width: 8.0), // Space between avatar and text
                  // Comment text
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        comment.commentText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}
