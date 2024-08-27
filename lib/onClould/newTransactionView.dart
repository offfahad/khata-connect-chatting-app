import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notifications/helpers/dialogs.dart';
import 'package:flutter_notifications/main.dart';
import 'package:flutter_notifications/models/chat_user.dart';
import 'package:flutter_notifications/models/comments.dart';
import 'package:flutter_notifications/onClould/commentCard.dart';
import 'package:flutter_notifications/onClould/newEditTransaction.dart';
import 'package:flutter_notifications/models/newTransactionsModel.dart';
import 'package:flutter_notifications/screens/messages/chat_screen.dart';
import 'package:flutter_notifications/widgets/message_card.dart';
import 'package:intl/intl.dart';
import 'package:flutter_notifications/api/apis.dart';
import 'package:flutter_notifications/models/message.dart';
import 'package:share/share.dart';

class NewTransactionView extends StatefulWidget {
  final ChatUser chatUser;
  final TransactionFirebase transaction;
  const NewTransactionView(
      {super.key, required this.chatUser, required this.transaction});

  @override
  State<NewTransactionView> createState() => _NewTransactionViewState();
}

class _NewTransactionViewState extends State<NewTransactionView> {
  final _textController = TextEditingController();
  List<CommentFirebase> _list = [];

  //showEmoji -- for storing value of showing or hiding emoji
  //isUploading -- for checking if image is uploading or not?
  bool _showEmoji = false, _isUploading = false;
  @override
  Widget build(BuildContext context) {
    final bool isCurrentUserTransaction =
        APIs.auth.currentUser?.uid == widget.transaction.fromId;

    //for handling message text changes

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "View Transaction",
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
        child: Column(
          children: [
            StreamBuilder<TransactionFirebase>(
              stream: APIs.getTransactionStream(
                  widget.chatUser, widget.transaction),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('An error occurred!'));
                }
                if (!snapshot.hasData) {
                  return const Center(
                      child: Text('No transaction data available.'));
                }
                final transaction_data = snapshot.data!;
                String transactionStatus;

                final isMadeByMe = transaction_data.fromId == APIs.user.uid;
                transactionStatus = isMadeByMe
                    ? (transaction_data.type.toLowerCase() == 'debit'
                        ? 'Received'
                        : 'Given')
                    : (transaction_data.type.toLowerCase() == 'debit'
                        ? 'Given'
                        : 'Received');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        height: mq.height * 0.28,
                        width: mq.width * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 2),
                                blurRadius: 6.0),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: Stack(
                                children: [
                                  // User image
                                  CircleAvatar(
                                    radius: 36.0,
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: NetworkImage(
                                      APIs.auth.currentUser?.uid ==
                                              widget.transaction.fromId
                                          ? APIs.me.image
                                          : widget.chatUser.image,
                                    ),
                                  ),
                                  // Status indicator
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      height: 15.0,
                                      width: 15.0,
                                      decoration: BoxDecoration(
                                        color: APIs.auth.currentUser?.uid ==
                                                widget.transaction.fromId
                                            ? Colors.green
                                            : widget.chatUser.isOnline
                                                ? Colors.green
                                                : Colors.red,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors
                                              .white, // Optional: border around the status dot
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              // Use Expanded to allow the column to take up remaining space
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 0, 0, 4),
                                      child: Text(
                                        APIs.auth.currentUser?.uid ==
                                                widget.transaction.fromId
                                            ? APIs.me.name
                                            : widget.chatUser.name,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        const Icon(
                                          Icons.money,
                                          size: 12.0,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 4, 4, 4),
                                          child: Text(
                                            _formatAmount(
                                                transaction_data.amount),
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        const Icon(
                                          Icons.lock_clock,
                                          size: 12.0,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 4, 4, 4),
                                          child: Text(
                                            _formatDateStringWithTime(
                                                transaction_data.timestamp),
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        const Icon(
                                          Icons.category,
                                          size: 12.0,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 4, 4, 4),
                                          child: Text(
                                            transactionStatus,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        const Icon(
                                          Icons.description,
                                          size: 12.0,
                                        ),
                                        if (widget
                                            .transaction.description.isNotEmpty)
                                          Expanded(
                                            // Use Expanded to handle text overflow
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      8, 4, 6, 4),
                                              child: Text(
                                                transaction_data.description,
                                                textAlign: TextAlign.justify,
                                                style: const TextStyle(
                                                    fontSize: 12),
                                                overflow: TextOverflow
                                                    .clip, // Handle overflow
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.pending,
                                          size: 12.0,
                                          color: widget.transaction.status ==
                                                  'Approved'
                                              ? Colors.green
                                              : widget.transaction.status ==
                                                      'Declined'
                                                  ? Colors.red
                                                  : Colors.black,
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                8, 4, 4, 4),
                                            child: Text(
                                              widget.transaction.status ==
                                                      'Approved'
                                                  ? 'Approved by ${widget.transaction.updateBy == APIs.auth.currentUser?.uid ? APIs.me.name : widget.chatUser.name}'
                                                  : widget.transaction.status ==
                                                          'Declined'
                                                      ? 'Declined by ${widget.transaction.updateBy == APIs.auth.currentUser?.uid ? APIs.me.name : widget.chatUser.name}'
                                                      : 'Status ${widget.transaction.status}',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: widget.transaction
                                                              .status ==
                                                          'Approved'
                                                      ? Colors.green
                                                      : widget.transaction
                                                                  .status ==
                                                              'Declined'
                                                          ? Colors.red
                                                          : Colors.black,
                                                  fontWeight: FontWeight
                                                      .bold // Default color if status is neither Approved nor Disapproved
                                                  ),
                                              overflow: TextOverflow
                                                  .clip, // Handle overflow
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: mq.height * 0.015,
                    ),
                    Container(
                      height: mq.height * 0.05,
                      width: mq.width * 0.9,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: mq.width * 0.29,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Show loading dialog
                                Dialogs.showLoading(context);

                                try {
                                  // Update transaction status
                                  await APIs.updateTransactionStatus(
                                      widget.chatUser,
                                      widget.transaction,
                                      'Approved');

                                  // Show success message
                                  Dialogs.showSnackbar(
                                      context, "Status Approved");
                                  Navigator.of(context).pop(); //
                                } catch (e) {
                                  // Handle errors here
                                  print("Error updating transaction: $e");
                                  Dialogs.showSnackbar(
                                      context, "Failed to approve status");
                                } finally {
                                  // Dismiss the loading dialog
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                //backgroundColor: _getButtonColor(
                                //  widget.transaction.status, 'Approved'),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Approve",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 10),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          SizedBox(
                            width: mq.width * 0.29,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Show loading dialog
                                Dialogs.showLoading(context);

                                try {
                                  // Update transaction status
                                  await APIs.updateTransactionStatus(
                                      widget.chatUser,
                                      widget.transaction,
                                      'Declined');

                                  // Show success message
                                  Dialogs.showSnackbar(
                                      context, "Status Declined");
                                  Navigator.of(context).pop(); //
                                } catch (e) {
                                  // Handle errors here
                                  print("Error updating transaction: $e");
                                  Dialogs.showSnackbar(
                                      context, "Failed to disapprove status");
                                } finally {
                                  // Dismiss the loading dialog
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Decline",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 10),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          SizedBox(
                            width: mq.width * 0.29,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                // Show loading dialog
                                Dialogs.showLoading(context);

                                // Construct the share message with transaction details
                                String message = '''
Transaction Details:
Name: ${APIs.auth.currentUser?.uid == widget.transaction.fromId ? APIs.me.name : widget.chatUser.name}
Amount: ${_formatAmount(transaction_data.amount)}
Date: ${_formatDateStringWithTime(transaction_data.timestamp)}
Status: ${widget.transaction.status}
Description: ${widget.transaction.description.isNotEmpty ? transaction_data.description : "N/A"}
''';

                                // Share the message
                                Share.share(message,
                                    subject: 'Transaction Details');

                                // Dismiss the loading dialog
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              label: const Text(
                                "Share",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: isCurrentUserTransaction,
                      child: Container(
                        margin: EdgeInsets.only(top: mq.height * 0.01),
                        height: mq.height * 0.05,
                        width: mq.width * 0.9,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: mq.width * 0.44,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  // Show a loading dialog while checking authorization
                                  Dialogs.showLoading(context);

                                  // Check if the current user is authorized to delete the transaction
                                  final isAuthorized =
                                      await APIs.isAuthorizedToDelete(
                                          widget.chatUser, widget.transaction);

                                  // Close the loading dialog
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();

                                  // If the user is authorized, show the confirmation dialog
                                  if (isAuthorized) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirm Deletion'),
                                        content: const Text(
                                            'Are you sure you want to delete this transaction?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              // Show the loading dialog while deleting
                                              Dialogs.showLoading(context);

                                              // Proceed with the deletion
                                              final result =
                                                  await APIs.deleteTransaction(
                                                      widget.chatUser,
                                                      widget.transaction);

                                              // Close the loading dialog
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .pop();

                                              if (result) {
                                                // Show success Snackbar
                                                Dialogs.showSnackbar(context,
                                                    "Transaction deleted successfully");

                                                // Pop back to the previous screen
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                                Navigator.of(context)
                                                    .pop(); // Go back to the previous screen
                                              } else {
                                                // Show error Snackbar
                                                Dialogs.showSnackbar(context,
                                                    "Failed to delete transaction.");
                                              }
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    // If the user is not authorized, show an error Snackbar
                                    Dialogs.showSnackbar(
                                      context,
                                      "Unauthorized, only ${widget.chatUser.name} can delete this transaction.",
                                    );
                                  }
                                },
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.black),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: mq.width * 0.01,
                            ),
                            SizedBox(
                              width: mq.width * 0.44,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  // Show a loading dialog while checking authorization
                                  Dialogs.showLoading(context);

                                  try {
                                    // Check if the current user is authorized to delete the transaction
                                    final isAuthorized =
                                        await APIs.isAuthorizedToDelete(
                                            widget.chatUser,
                                            widget.transaction);

                                    // Close the loading dialog
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();

                                    if (isAuthorized) {
                                      // If authorized, navigate to the EditTransactionPage
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditTransactionPage(
                                                  transaction:
                                                      widget.transaction,
                                                  chatUser: widget.chatUser),
                                        ),
                                      );
                                    } else {
                                      // If not authorized, show an error Snackbar
                                      Dialogs.showSnackbar(
                                        context,
                                        "Unauthorized, only ${widget.chatUser.name} can edit this transaction.",
                                      );
                                    }
                                  } catch (e) {
                                    // Handle any errors that might occur during authorization check
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                    Dialogs.showSnackbar(
                                      context,
                                      "An error occurred. Please try again.",
                                    );
                                  }
                                },
                                child: const Text(
                                  "Edit",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
            SizedBox(
              height: mq.height * 0.015,
            ),
            Expanded(
              child: Container(
                //height: mq.height * 0.3,
                width: mq.width * 0.89,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, 2),
                        blurRadius: 3.0),
                  ],
                ),
                child: StreamBuilder(
                  stream:
                      APIs.getAllComments(widget.chatUser, widget.transaction),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      //if data is loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const SizedBox();

                      //if some or all data is loaded then show it
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        _list = data
                                ?.map((e) => CommentFirebase.fromJson(e.data()))
                                .toList() ??
                            [];

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                              reverse: true,
                              itemCount: _list.length,
                              padding: EdgeInsets.only(top: mq.height * .01),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return CommentCard(
                                  chatUser: widget.chatUser,
                                  comment: _list[index],
                                  currentUserImageUrl: APIs.me.image,
                                  chatUserImageUrl: widget.chatUser.image,
                                  transaction: widget.transaction,
                                  isChatUserOnline: widget.chatUser.isOnline,
                                );
                              });
                        } else {
                          return const Center(
                            child: Text('No Comments Added Yet! 👋',
                                style: TextStyle(fontSize: 12)),
                          );
                        }
                    }
                  },
                ),
              ),
            ),
            _chatInput(),
            if (_showEmoji)
              SizedBox(
                height: mq.height * .35,
                child: EmojiPicker(
                  textEditingController: _textController,
                  config: const Config(),
                ),
              )
          ],
        ),
      ),
    );
  }

  String _formatDateStringWithTime(String dateString) {
    try {
      // Parse the date string to DateTime
      DateTime dateTime =
          DateFormat('yyyy-MM-dd HH:mm:ss.SSS').parse(dateString);

      // Format DateTime to a readable format (e.g., "yyyy-MM-dd hh:mm a")
      return DateFormat('yyyy-MM-dd | hh:mm a').format(dateTime);
    } catch (e) {
      // Handle any errors that might occur during parsing
      print("Error formatting date string: $e");
      return "Invalid Date";
    }
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN', // Indian locale for formatting
      symbol: 'Rs ', // Currency symbol
      decimalDigits: 0, // No decimal places
    );
    return formatter.format(amount.abs());
  }

  void shareTransactionsToChat(
      BuildContext context, TransactionFirebase transaction) async {
    await APIs.sendMessage(
        widget.chatUser,
        '${_formatAmount(transaction.amount)} On ${_formatDateStringWithTime(transaction.timestamp)} With Status ${transaction.status}.',
        Type.text);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(user: widget.chatUser),
      ),
    );
  }

  // bottom chat input field
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .020),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: Colors.white,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    // IconButton(
                    //   onPressed: () {
                    //     //FocusScope.of(context).unfocus();
                    //     setState(() => _showEmoji = !_showEmoji);
                    //   },
                    //   icon: const Icon(
                    //     Icons.emoji_emotions,
                    //     size: 25,
                    //     color: Colors.blue,
                    //   ),
                    // ),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onTap: () {
                          // if (_showEmoji) {
                          //   setState(() => _showEmoji = !_showEmoji);
                          // }
                          //FocusScope.of(context).unfocus();
                        },
                        decoration: const InputDecoration(
                          hintText: 'Type Comments...',
                          hintStyle: TextStyle(fontSize: 12),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    // IconButton(
                    //   onPressed: () async {
                    //     final ImagePicker picker = ImagePicker();
                    //     final List<XFile> images =
                    //         await picker.pickMultiImage(imageQuality: 70);

                    //     for (var i in images) {
                    //       log('Image Path: ${i.path}');
                    //       setState(() => _isUploading = true);
                    //       await APIs.sendChatImage(widget.user, File(i.path));
                    //       setState(() => _isUploading = false);
                    //     }
                    //   },
                    //   icon: const Icon(
                    //     Icons.image,
                    //     size: 26,
                    //   ),
                    // ),
                    // IconButton(
                    //   onPressed: () async {
                    //     final ImagePicker picker = ImagePicker();
                    //     final XFile? image = await picker.pickImage(
                    //         source: ImageSource.camera, imageQuality: 70);
                    //     if (image != null) {
                    //       log('Image Path: ${image.path}');
                    //       setState(() => _isUploading = true);
                    //       await APIs.sendChatImage(widget.user, File(image.path));
                    //       setState(() => _isUploading = false);
                    //     }
                    //   },
                    //   icon: const Icon(
                    //     Icons.camera_alt_rounded,
                    //     size: 26,
                    //   ),
                    // ),
                    SizedBox(width: mq.width * .02),
                  ],
                ),
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                // setState(() {
                //   // Close the emoji picker
                //   _showEmoji = false;
                // });

                // Send the message
                if (_list.isEmpty) {
                  APIs.addTransactionsComments(widget.chatUser,
                      widget.transaction, _textController.text.trim());
                } else {
                  APIs.addTransactionsComments(widget.chatUser,
                      widget.transaction, _textController.text.trim());
                }

                // Clear the text field
                _textController.clear();

                // Optionally, unfocus the text field to close the keyboard
                //FocusScope.of(context).unfocus();
              }
            },
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            color: Colors.green,
            child: const Icon(Icons.send, color: Colors.white, size: 28),
          )
        ],
      ),
    );
  }
}
