import 'package:flutter/material.dart';
import 'package:flutter_notifications/helpers/dialogs.dart';
import 'package:flutter_notifications/main.dart';
import 'package:flutter_notifications/models/chat_user.dart';
import 'package:flutter_notifications/onClould/newEditTransaction.dart';
import 'package:flutter_notifications/onClould/newTransactionsModel.dart';
import 'package:flutter_notifications/screens/messages/chat_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_notifications/api/apis.dart';
import 'package:flutter_notifications/models/message.dart';

class NewTransactionView extends StatefulWidget {
  final ChatUser chatUser;
  final TransactionFirebase transaction;
  const NewTransactionView(
      {super.key, required this.chatUser, required this.transaction});

  @override
  State<NewTransactionView> createState() => _NewTransactionViewState();
}

class _NewTransactionViewState extends State<NewTransactionView> {
  @override
  Widget build(BuildContext context) {
    final bool isCurrentUserTransaction =
        APIs.auth.currentUser?.uid == widget.transaction.fromId;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "View Transaction",
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
        child: StreamBuilder<TransactionFirebase>(
          stream:
              APIs.getTransactionStream(widget.chatUser, widget.transaction),
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    height: mq.height * 0.3,
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
                          child: CircleAvatar(
                            radius: 36.0,
                            backgroundColor: Colors.transparent,
                            backgroundImage: NetworkImage(
                                APIs.auth.currentUser?.uid ==
                                        widget.transaction.fromId
                                    ? APIs.me.image
                                    : widget.chatUser.image),
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
                                      padding:
                                          const EdgeInsets.fromLTRB(8, 4, 4, 4),
                                      child: Text(
                                        _formatAmount(transaction_data.amount),
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
                                      padding:
                                          const EdgeInsets.fromLTRB(8, 4, 4, 4),
                                      child: Text(
                                        _formatDateStringWithTime(
                                            transaction_data.timestamp),
                                        style: const TextStyle(fontSize: 12),
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
                                      padding:
                                          const EdgeInsets.fromLTRB(8, 4, 4, 4),
                                      child: Text(
                                        transaction_data.type == 'credit'
                                            ? 'Given'
                                            : 'Received',
                                        style: const TextStyle(fontSize: 12),
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
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 4, 6, 4),
                                          child: Text(
                                            transaction_data.description,
                                            textAlign: TextAlign.justify,
                                            style:
                                                const TextStyle(fontSize: 12),
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
                                              color: widget
                                                          .transaction.status ==
                                                      'Approved'
                                                  ? Colors.green
                                                  : widget.transaction.status ==
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
                  height: mq.height * 0.03,
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
                              Dialogs.showSnackbar(context, "Status Approved");
                              Navigator.of(context).pop(); //
                            } catch (e) {
                              // Handle errors here
                              print("Error updating transaction: $e");
                              Dialogs.showSnackbar(
                                  context, "Failed to approve status");
                            } finally {
                              // Dismiss the loading dialog
                              Navigator.of(context, rootNavigator: true).pop();
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
                            style: TextStyle(color: Colors.black, fontSize: 10),
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
                                  context, "Status Disapproved");
                              Navigator.of(context).pop(); //
                            } catch (e) {
                              // Handle errors here
                              print("Error updating transaction: $e");
                              Dialogs.showSnackbar(
                                  context, "Failed to disapprove status");
                            } finally {
                              // Dismiss the loading dialog
                              Navigator.of(context, rootNavigator: true).pop();
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
                            style: TextStyle(color: Colors.black, fontSize: 10),
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

                            try {
                              await Future.delayed(const Duration(
                                  seconds: 1)); // Simulate a share action
                              shareTransactionsToChat(
                                  context, widget.transaction);
                              // Show success message
                              Dialogs.showSnackbar(
                                  context, "Shared successfully");
                            } catch (e) {
                              // Handle errors here
                              print("Error sharing: $e");
                              Dialogs.showSnackbar(context, "Failed to share");
                            } finally {
                              // Dismiss the loading dialog
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          label: const Text(
                            "Send",
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: mq.height * 0.02,
                ),
                Visibility(
                  visible: isCurrentUserTransaction,
                  child: Container(
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
                              Navigator.of(context, rootNavigator: true).pop();

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
                              style:
                                  TextStyle(fontSize: 10, color: Colors.black),
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
                                        widget.chatUser, widget.transaction);

                                // Close the loading dialog
                                Navigator.of(context, rootNavigator: true)
                                    .pop();

                                if (isAuthorized) {
                                  // If authorized, navigate to the EditTransactionPage
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditTransactionPage(
                                          transaction: widget.transaction,
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
                              style:
                                  TextStyle(color: Colors.black, fontSize: 10),
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
}
