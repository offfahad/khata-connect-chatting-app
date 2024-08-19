import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../../api/apis.dart';
import '../../helpers/dialogs.dart';
import '../../main.dart';
import '../../models/chat_user.dart';
import '../../providers/my_theme_provider.dart';
import '../../widgets/chat_user_card.dart';
import '../../widgets/profile_image.dart';
import '../chatbot/ai_screen.dart';
import '../userProfile/profile_screen.dart';

//home screen -- where all available contacts are shown
class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  // for storing all users
  List<ChatUser> _list = [];

  // for storing searched items
  final List<ChatUser> _searchList = [];
  // for storing search status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    //for updating user active status according to lifecycle events
    //resume -- active or online
    //pause  -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeStatus = Provider.of<MyThemeProvider>(context);

    return GestureDetector(
      //for hiding keyboard when a tap is detected on screen

      onTap: FocusScope.of(context).unfocus,
      child: PopScope(
        // onWillPop: () {
        //   if (_isSearching) {
        //     setState(() {
        //       _isSearching = !_isSearching;
        //     });
        //     return Future.value(false);
        //   } else {
        //     return Future.value(true);
        //   }
        // },

        //if search is on & back button is pressed then close search
        //or else simple close current screen on back button click
        canPop: false,
        onPopInvoked: (_) {
          if (_isSearching) {
            setState(() => _isSearching = !_isSearching);
            return;
          }

          // some delay before pop
          Future.delayed(
              const Duration(milliseconds: 300), SystemNavigator.pop);
        },

        //
        child: Scaffold(
          //app bar
          appBar: AppBar(
            //view profile
            leading: IconButton(
              tooltip: 'View Profile',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProfileScreen(user: APIs.me)));
              },
              icon: const ProfileImage(size: 32),
            ),

            //title
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: 'Name, Email, ...'),
                    autofocus: true,
                    style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                    //when search text changes then updated search list
                    onChanged: (val) {
                      //search logic
                      _searchList.clear();

                      val = val.toLowerCase();

                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val) ||
                            i.email.toLowerCase().contains(val)) {
                          _searchList.add(i);
                        }
                      }
                      setState(() => _searchList);
                    },
                  )
                : const Text(
                    'Khata Connect',
                    style: TextStyle(fontSize: 16),
                  ),
            actions: [
              //search user button
              IconButton(
                tooltip: 'Search',
                onPressed: () => setState(() => _isSearching = !_isSearching),
                icon: Icon(_isSearching
                    ? CupertinoIcons.clear_circled_solid
                    : CupertinoIcons.search),
                iconSize: 16,
              ),

              //add new user
              // IconButton(
              //   onPressed: () {
              //     themeStatus.setTheme = !themeStatus.themeType;
              //   },
              //   icon: Icon(themeStatus.themeType
              //       ? Icons.dark_mode_outlined
              //       : Icons.light_mode_outlined),
              //       iconSize: 16,
              // ),
              IconButton(
                onPressed: () {
                  String message =
                      'Hi, I would like to invite you to use this amazing app. Download it here: [app_link]';
                  Share.share(message, subject: 'App Invitation');
                },
                icon: const Icon(Icons.share),
                iconSize: 16,
              ),
            ],
          ),

          //floating button to add new user
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                    backgroundColor: Colors.white,
                    heroTag: null,
                    //backgroundColor: const Color.fromARGB(255, 179, 35, 35),
                    onPressed: () {
                      //for showing progress dialog
                      _addChatUserDialog();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add User')),
                const SizedBox(
                  width: 10,
                ),
                FloatingActionButton(
                    backgroundColor: Colors.white,
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const AiScreen()));
                    },
                    child: Lottie.asset('assets/lottie/ai.json', width: 40)),
              ],
            ),
          ),

          //body
          body: StreamBuilder(
            stream: APIs.getMyUsersId(),

            //get id of only known users
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                //if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());

                //if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: APIs.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                    //get only those user, who's ids are provided
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                        // return const Center(
                        //     child: CircularProgressIndicator());

                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => ChatUser.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                itemCount: _isSearching
                                    ? _searchList.length
                                    : _list.length,
                                padding: EdgeInsets.only(top: mq.height * .01),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ChatUserCard(
                                      user: _isSearching
                                          ? _searchList[index]
                                          : _list[index]);
                                });
                          } else {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30),
                                child: Text(
                                  'No connections found. Please add a user first!',
                                  style: TextStyle(fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }
                      }
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  void _addChatUserDialog() {
    String email = '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding:
            const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        title: const Row(
          children: [
            Icon(
              Icons.person_add,
              size: 28,
            ),
            SizedBox(
              width: 10,
            ),
            Text('Add User')
          ],
        ),
        content: TextFormField(
          maxLines: null,
          onChanged: (value) => email = value,
          decoration: const InputDecoration(
              hintText: 'Email Id',
              prefixIcon: Icon(
                Icons.email,
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)))),
        ),
        actions: [
          //cancel button
          MaterialButton(
            onPressed: () {
              //hide alert dialog
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          //add button
          MaterialButton(
            onPressed: () async {
              //hide alert dialog
              Navigator.pop(context);
              String trimmedEmail = email.trim(); // Trim spaces
              if (trimmedEmail.isNotEmpty) {
                await APIs.addChatUser(trimmedEmail).then((value) {
                  if (!value) {
                    Dialogs.showSnackbar(context, 'User does not Exist!');
                  }
                });
              }
            },
            child: const Text(
              'Add',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
    );
  }
}
