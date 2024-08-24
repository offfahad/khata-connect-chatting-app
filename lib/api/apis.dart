import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_notifications/models/comments.dart';
import 'package:flutter_notifications/models/newTransactionsModel.dart';
import 'package:flutter_notifications/services/local_notification_service.dart';
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_user.dart';
import '../models/message.dart';
import 'notification_access_token.dart';

class APIs {
  // for authentication
  static FirebaseAuth get auth => FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // for storing self information
  static ChatUser me = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      address: '',
      phoneNo: '',
      about: '',
      image: user.photoURL.toString(),
      createdAt: '',
      isOnline: false,
      lastActive: '',
      pushToken: '');

  // to return current user
  static User get user => auth.currentUser!;

  // for accessing firebase messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('Push Token: $t');
      }
    });

    //for handling foreground messages
    FirebaseMessaging.onMessage.listen((event) async {
      LocalNotificationService().showNotification(event);
    });
  }

  // for sending push notification (Updated Codes)
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "message": {
          "token": chatUser.pushToken,
          "notification": {
            "title": me.name, //our name should be send
            "body": msg,
          },
          "data": {
            "image": me.image, // Include the image URL in the data payload
          },
        }
      };

      // Firebase Project > Project Settings > General Tab > Project ID
      const projectID = 'pushnotifications-8858c';

      // get firebase admin token
      final bearerToken = await NotificationAccessToken.getToken;

      log('bearerToken: $bearerToken');

      // handle null token
      if (bearerToken == null) return;

      var res = await post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/$projectID/messages:send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $bearerToken'
        },
        body: jsonEncode(body),
      );

      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  // for checking if user exists or not?
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // for adding an chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists

      log('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }

  // for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        //for setting user status to active
        APIs.updateActiveStatus(true);
        log('My Data: ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        address: '',
        phoneNo: '',
        about: '',
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nUserIds: $userIds');

    return firestore
        .collection('users')
        .where('id',
            whereIn: userIds.isEmpty
                ? ['']
                : userIds) //because empty list throws an error
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

// for updating user information
  static Future<void> updateUserInfo() async {
    try {
      await firestore.collection('users').doc(user.uid).update({
        'name': me.name,
        'about': me.about,
        'address': me.address,
        'phoneNo': me.phoneNo,
      });
      log('User information updated successfully');
    } catch (e, s) {
      log('Failed to update user information: $e');
      log('Stack trace: $s');
      rethrow;
    }
  }

  // update profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    //storage file ref with path
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  ///************** Chat Screen Related APIs **************

  // chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)

  // useful for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);

    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  //delete message
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }

  static Future<ChatUser?> getUserByEmail(String email) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return ChatUser.fromJson(snapshot.docs.first.data());
    }
    return null; // Return null if user not found
  }

  static Stream<int> getUnreadMessageCount(ChatUser chatUser) {
    return firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/')
        .where('read', isEqualTo: '')
        .where('fromId', isEqualTo: chatUser.id)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Delete a ChatUser document from the current user's collection
  static Future<void> deleteChatUser(ChatUser chatUser) async {
    String currentUserId = APIs.user.uid; // Get the current user ID

    try {
      // Delete the chat record from the current user's "my_users" collection
      await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('my_users')
          .doc(chatUser.id)
          .delete();

      log('Chat with ${chatUser.name} deleted successfully');
    } catch (e) {
      log('Failed to delete chat with ${chatUser.name}: $e');
    }
  }

  // ************** Transaction Related APIs **************

  // Get all transactions for a user
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllTransactions(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/transactions/')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static Future<void> updateTransactionStatus(
      ChatUser user, TransactionFirebase transaction, String newStatus) async {
    DateTime date = DateTime.now();
    try {
      // Get the reference to the specific transaction document
      final ref = firestore
          .collection('chats/${getConversationID(user.id)}/transactions/')
          .doc(transaction.id);

      // Update the status field and track who made the update
      await ref.update({
        'status': newStatus,
        'updateBy': APIs.auth.currentUser?.uid, // Ensure this is not null
        'updateTimestamp': date, // Optional: track when the update occurred
      });

      log('Transaction status updated successfully by ${APIs.auth.currentUser?.uid}');
    } catch (e, s) {
      log('Failed to update transaction status: $e');
      log('Stack trace: $s');
      rethrow;
    }
  }

  // Get the last transaction for a user
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastTransaction(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/transactions/')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots();
  }

  // Send the first transaction and add user to my users list
  static Future<void> sendFirstTransaction(
      ChatUser chatUser, TransactionFirebase transaction) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendTransaction(chatUser, transaction));
  }

  static Future<void> sendTransaction(
      ChatUser chatUser, TransactionFirebase transaction) async {
    try {
      if (transaction.id.isEmpty) {
        transaction.id = const Uuid().v4();
      }

      // Create a new transaction instance
      final transactionData = {
        'id': transaction.id,
        'toId': chatUser.id,
        'type': transaction.type,
        'amount': transaction.amount,
        'description': transaction.description,
        'status': transaction.status,
        'timestamp': transaction.timestamp,
        'fromId': user.uid,
        'updateBy': user.uid,
        'updateTimestamp': transaction.timestamp,
      };

      // Add transaction to the user's transaction collection
      final ref = firestore
          .collection('chats/${getConversationID(chatUser.id)}/transactions/');

      await ref.doc(transaction.id).set(transactionData);

      log('Transaction sent: ${transaction.amount}');
    } catch (e) {
      log('Failed to send transaction: $e');
    }
  }

  static Future<double> calculateTotalAmount(ChatUser user) async {
    try {
      double totalAmount = 0.0;
      final currentUserId = APIs.me.id;

      // Fetch all transactions
      final transactionsSnapshot = await FirebaseFirestore.instance
          .collection('chats/${getConversationID(user.id)}/transactions/')
          .orderBy('timestamp', descending: true)
          .get();

      // Calculate total amount based on transaction type and ownership
      for (var doc in transactionsSnapshot.docs) {
        final data = doc.data();
        final amount = data['amount']?.toDouble() ?? 0.0;
        final type = data['type'] as String;
        final fromId = data['fromId'] as String;

        // Adjust total amount based on transaction type and whether it's made by current user
        if (fromId == currentUserId) {
          // Transaction made by the current user
          if (type == 'credit') {
            totalAmount -= amount; // Giving money, so subtract
          } else if (type == 'debit') {
            totalAmount += amount; // Receiving money, so add
          }
        } else {
          // Transaction made by someone else
          if (type == 'credit') {
            totalAmount += amount; // Receiving money from someone else, so add
          } else if (type == 'debit') {
            totalAmount -= amount; // Giving money to someone else, so subtract
          }
        }
      }

      return totalAmount;
    } catch (e) {
      print('Failed to calculate total amount: $e');
      return 0.0;
    }
  }

  static Stream<double> calculateTotalAmountStream(ChatUser user) {
    return FirebaseFirestore.instance
        .collection('chats/${getConversationID(user.id)}/transactions/')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) {
      double totalAmount = 0.0;
      final currentUserId = APIs.me.id;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final amount = data['amount']?.toDouble() ?? 0.0;
        final type = data['type'] as String;
        final fromId = data['fromId'] as String;

        if (fromId == currentUserId) {
          // Transaction made by the current user
          if (type == 'credit') {
            totalAmount -= amount; // Giving money, so subtract
          } else if (type == 'debit') {
            totalAmount += amount; // Receiving money, so add
          }
        } else {
          // Transaction made by someone else
          if (type == 'credit') {
            totalAmount += amount; // Receiving money from someone else, so add
          } else if (type == 'debit') {
            totalAmount -= amount; // Giving money to someone else, so subtract
          }
        }
      }

      return totalAmount;
    });
  }

  // Update the transaction in Firestore
  static Future<void> updateTransaction(
      ChatUser chatUser, TransactionFirebase updatedTransaction) async {
    try {
      // Get the reference to the transaction document
      final ref = firestore
          .collection('chats/${getConversationID(chatUser.id)}/transactions/')
          .doc(updatedTransaction.id);

      // Prepare updated data
      final updatedData = {
        'id': updatedTransaction.id,
        'toId': chatUser.id,
        'type': updatedTransaction.type,
        'amount': updatedTransaction.amount,
        'description': updatedTransaction.description,
        'status': updatedTransaction.status,
        'timestamp': updatedTransaction.timestamp,
        'fromId': updatedTransaction.fromId,
        'updateBy': updatedTransaction.updateBy,
        'updateTimestamp': updatedTransaction.updateTimestamp
      };

      // Update the transaction document
      await ref.update(updatedData);

      log('Transaction updated: ${updatedTransaction.amount}');
    } catch (e) {
      log('Failed to update transaction: $e');
    }
  }

  // Fetch a specific transaction
  static Future<Map<String, dynamic>?> fetchTransaction(
      ChatUser chatUser, TransactionFirebase transaction) async {
    try {
      final doc = await firestore
          .collection('chats/${getConversationID(chatUser.id)}/transactions/')
          .doc(transaction.id)
          .get();

      if (doc.exists) {
        return doc.data();
      } else {
        log('Transaction not found');
        return null;
      }
    } catch (e) {
      log('Failed to fetch transaction: $e');
      return null;
    }
  }

  static Future<bool> deleteTransaction(
      ChatUser chatUser, TransactionFirebase transaction) async {
    try {
      // Get the current authenticated user's ID
      final currentUser = FirebaseAuth.instance.currentUser;

      // Check if the current user is the author of the transaction
      if (currentUser != null && currentUser.uid == transaction.fromId) {
        await firestore
            .collection('chats/${getConversationID(chatUser.id)}/transactions/')
            .doc(transaction.id)
            .delete();

        log('Transaction deleted successfully');
        return true; // Return true if deletion is successful
      } else {
        log('You are not authorized to delete this transaction.');
        return false; // Return false if the user is not authorized
      }
    } catch (e) {
      log('Failed to delete transaction: $e');
      return false; // Return false if an error occurs
    }
  }

  static Future<bool> isAuthorizedToDelete(
      ChatUser chatUser, TransactionFirebase transaction) async {
    try {
      // Get the current authenticated user's ID
      final currentUser = FirebaseAuth.instance.currentUser;

      // Check if the current user is the author of the transaction
      if (currentUser != null && currentUser.uid == transaction.fromId) {
        log('User is authorized.');
        return true; // Return true if the user is authorized
      } else {
        log('You are not authorized.');
        return false; // Return false if the user is not authorized
      }
    } catch (e) {
      log('Failed to check authorization: $e');
      return false; // Return false if an error occurs
    }
  }

  static Stream<TransactionFirebase> getTransactionStream(
      ChatUser chatUser, TransactionFirebase transaction) {
    return FirebaseFirestore.instance
        .collection('chats/${getConversationID(chatUser.id)}/transactions/')
        .doc(transaction.id)
        .snapshots()
        .map(
          (snapshot) => TransactionFirebase.fromJson(
            snapshot.data()!,
          ),
        ); // Assuming you have a fromJson method in TransactionFirebase
  }

  static Future<void> addTransactionsComments(ChatUser chatUser,
      TransactionFirebase transaction, String commentText) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final CommentFirebase comment = CommentFirebase(
      commentText: commentText,
      read: '',
      timestamp: time,
      fromId: user.uid,
      toId: chatUser.id,
    );

    final ref = FirebaseFirestore.instance
        .collection('chats/${getConversationID(chatUser.id)}/transactions/')
        .doc(transaction.id)
        .collection('comments/');

    try {
      await ref.doc(time).set(comment.toJson());
      //await sendPushNotification(chatUser, commentText);
    } catch (e) {
      log('Failed to add comment: $e');
    }
  }

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllComments(
      ChatUser user, TransactionFirebase transaction) {
    return firestore
        .collection(
            'chats/${getConversationID(user.id)}/transactions/${transaction.id}/comments/')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
