import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notifications/main.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../../api/apis.dart';
import '../../helpers/dialogs.dart';
import '../../models/chat_user.dart';
import '../../providers/my_theme_provider.dart';
import '../../widgets/chat_user_card.dart';
import '../../widgets/profile_image.dart';
import '../chatbot/ai_screen.dart';
import '../userProfile/profile_screen.dart';

// Home screen where all available contacts are shown
class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  // For storing all users
  List<ChatUser> _list = [];

  // For storing searched items
  final List<ChatUser> _searchList = [];
  // For storing search status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    // Updating user active status according to lifecycle events
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
      // For hiding keyboard when a tap is detected on screen
      child: Scaffold(
        // App bar
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'View Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(user: APIs.me),
                ),
              );
            },
            icon: const ProfileImage(size: 32),
          ),
          title: _isSearching
              ? TextField(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Name, Email, ...',
                  ),
                  autofocus: true,
                  style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                  onChanged: (val) {
                    _searchList.clear();

                    val = val.toLowerCase();

                    for (var i in _list) {
                      if (i.name.toLowerCase().contains(val) ||
                          i.email.toLowerCase().contains(val)) {
                        _searchList.add(i);
                      }
                    }
                    setState(() {});
                  },
                )
              : const Text(
                  'Khata Connect',
                  style: TextStyle(fontSize: 16),
                ),
          actions: [
            IconButton(
              tooltip: 'Search',
              onPressed: () => setState(() => _isSearching = !_isSearching),
              icon: Icon(_isSearching
                  ? CupertinoIcons.clear_circled_solid
                  : CupertinoIcons.search),
              iconSize: 16,
            ),
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

        // Floating button to add a new user
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                backgroundColor: Colors.white,
                heroTag: null,
                onPressed:_addChatUserDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add User'),
              ),
              const SizedBox(width: 10),
              FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AiScreen()),
                  );
                },
                child: Lottie.asset('assets/lottie/ai.json', width: 40),
              ),
            ],
          ),
        ),

        // Body
        body: StreamBuilder(
          stream: APIs.getMyUsersId(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.none:
                return const Center(child: CircularProgressIndicator());

              case ConnectionState.active:
              case ConnectionState.done:
                return StreamBuilder(
                  stream: APIs.getAllUsers(
                    snapshot.data?.docs.map((e) => e.id).toList() ?? [],
                  ),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const Center(child: CircularProgressIndicator());

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
                                    : _list[index],
                              );
                            },
                          );
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
    );
  }

  // Separate method for adding a new chat user
  void _addChatUserDialog() {
    String email = '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: 10,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        title: const Row(
          children: [
            Icon(Icons.person_add, size: 28),
            SizedBox(width: 10),
            Text('Add User'),
          ],
        ),
        content: TextFormField(
          maxLines: null,
          onChanged: (value) => email = value,
          decoration: const InputDecoration(
            hintText: 'Email Id',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16),
            ),
          ),
          MaterialButton(
            onPressed: () async {
              Navigator.pop(context);
              String trimmedEmail = email.trim();
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
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
   void _showAddUserBottomSheet() {
    String input = '';

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add User',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter email or phone number',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: (value) {
                input = value;
              },
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
                
                onPressed: () async {
                  Navigator.pop(context);
                  String trimmedInput = input.trim();
                  if (trimmedInput.isNotEmpty) {
                    await APIs.addChatUserBottomSheet(trimmedInput).then((value) {
                      if (!value) {
                        Dialogs.showSnackbar(
                            context, 'User does not exist or cannot be added!');
                      }
                    });
                  }
                },
                icon: const Icon(Icons.person_add, color: Colors.white,),
                label: const Text('Add User', style: TextStyle(color: Colors.white),),
                
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    
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
