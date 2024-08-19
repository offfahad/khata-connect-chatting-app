import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/apis.dart';
import '../helpers/my_date_util.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../onClould/newSingleCustomerScreen.dart';
import '../providers/my_theme_provider.dart';
import 'dialogs/profile_dialog.dart';
import 'profile_image.dart';

//card to represent a single user in home screen
class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  //last message info (if null --> no message)
  Message? _message;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<MyThemeProvider>(context);
    final Color color = themeProvider.themeType ? Colors.white : Colors.black;

    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      elevation: 0.5,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        onTap: () {
          //for navigating to chat screen
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => NewSingleCustomer(widget.user)));
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) _message = list[0];

            return ListTile(
              //user profile picture
              leading: InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) => ProfileDialog(user: widget.user));
                },
                child: ProfileImage(
                    size: mq.height * .055, url: widget.user.image),
              ),

              //user name
              title: Text(
                widget.user.name,
                style: TextStyle(color: color),
              ),

              //last message
              subtitle: Text(
                _message != null
                    ? _message!.type == Type.image
                        ? 'image'
                        : _message!.msg
                    : widget.user.about,
                style: TextStyle(color: color),
                maxLines: 1,
              ),

              //last message time with unread message count indicator
              trailing: _message == null
                  ? null //show nothing when no message is sent
                  : StreamBuilder<int>(
                      stream: APIs.getUnreadMessageCount(widget.user),
                      builder: (context, unreadSnapshot) {
                        int unreadCount = unreadSnapshot.data ?? 0;

                        return unreadCount > 0
                            ? Stack(
                                alignment: Alignment.center,
                                children: [
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(255, 0, 230, 119),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '$unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                MyDateUtil.getLastMessageTime(
                                    context: context, time: _message!.sent),
                                style: TextStyle(
                                  color: color,
                                ),
                              );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}
