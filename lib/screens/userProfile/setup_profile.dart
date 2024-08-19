import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_notifications/main.dart';
import 'package:flutter_notifications/models/chat_user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_notifications/api/apis.dart';
import 'package:flutter_notifications/helpers/dialogs.dart';
import 'package:flutter_notifications/screens/messages/messages_screen.dart';
import 'package:flutter_notifications/widgets/profile_image.dart';

class SetupProfile extends StatefulWidget {
  final ChatUser user;
  const SetupProfile({super.key, required this.user});

  @override
  State<SetupProfile> createState() => _SetupProfileState();
}

class _SetupProfileState extends State<SetupProfile> {
  final _formKey = GlobalKey<FormState>();
  String? _image;
  final RegExp _phoneRegExp = RegExp(r'^03\d{9}$');
  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(title: const Text('Setup Profile')),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(width: mq.width, height: mq.height * .04),
                  Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(mq.height * .1)),
                              child: Image.file(File(_image!),
                                  width: mq.height * .2,
                                  height: mq.height * .2,
                                  fit: BoxFit.cover))
                          : ProfileImage(
                              size: mq.height * .2,
                              url: widget.user.image,
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 1,
                          onPressed: _showBottomSheet,
                          shape: const CircleBorder(),
                          color: Colors.white,
                          child: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: mq.height * .03),
                  Text(widget.user.email,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 16)),
                  SizedBox(height: mq.height * .03),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      hintText: 'eg. Muhammad Fahad',
                      labelText: 'Name',
                    ),
                  ),
                  SizedBox(height: mq.height * .02),
                  TextFormField(
                    initialValue: widget.user.address,
                    onSaved: (val) => APIs.me.address = val ?? '',
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Address is required';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      hintText:
                          'eg. Village, Sheikh.M ; Moh, Haji Abad , Peshawar',
                      labelText: 'Address',
                    ),
                  ),
                  SizedBox(height: mq.height * .02),
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    initialValue: widget.user.phoneNo,
                    onSaved: (val) => APIs.me.phoneNo = val ?? '',
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Required Field';
                      } else if (!_phoneRegExp.hasMatch(val)) {
                        return 'Invalid Phone Number';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      hintText: 'eg. 03137426256',
                      labelText: 'Phone',
                    ),
                  ),
                  SizedBox(height: mq.height * .02),
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'About section is required';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.info_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      hintText: 'eg. Software Engineer at GulzarSoft',
                      labelText: 'About',
                    ),
                  ),
                  SizedBox(height: mq.height * .02),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        Dialogs.showLoading(context);
                        _formKey.currentState!.save();
                        try {
                          await APIs.updateUserInfo();
                          Dialogs.showSnackbar(
                              context, 'Profile Completed Successfully!');
                          Navigator.pop(context); // Close the loading dialog
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MessageScreen()));
                        } catch (e, s) {
                          log('Error updating profile: $e');
                          log('Stack trace: $s');
                          Navigator.pop(context); // Close the loading dialog
                          Dialogs.showSnackbar(context,
                              'Failed to update profile. Please try again.');
                        }
                      }
                    },
                    label: const Text('DONE', style: TextStyle(fontSize: 16)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding:
              EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
          children: [
            const Text(
              'Pick Profile Picture',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: mq.height * .02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize: Size(mq.width * .3, mq.height * .15),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      log('Image Path: ${image.path}');
                      setState(() {
                        _image = image.path;
                      });

                      await APIs.updateProfilePicture(File(_image!));

                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: Image.asset('assets/images/add_image.png'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize: Size(mq.width * .3, mq.height * .15),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      log('Image Path: ${image.path}');
                      setState(() {
                        _image = image.path;
                      });

                      await APIs.updateProfilePicture(File(_image!));

                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: Image.asset('assets/images/camera.png'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
