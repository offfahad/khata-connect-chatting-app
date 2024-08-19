import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notifications/api/apis.dart';
import 'package:flutter_notifications/helpers/dialogs.dart';
import 'package:flutter_notifications/main.dart';
import 'package:flutter_notifications/onClould/newAddTransactions.dart';
import 'package:flutter_notifications/onClould/newTransactionsModel.dart';
import 'package:flutter_notifications/onClould/newTransactionView.dart';
import 'package:flutter_notifications/screens/messages/chat_screen.dart';
import 'package:flutter_notifications/screens/messages/messages_screen.dart';
import 'package:flutter_notifications/screens/userProfile/view_profile_screen.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_notifications/models/message.dart';
import '../../helpers/constants.dart';
import '../../models/chat_user.dart';

class NewSingleCustomer extends StatefulWidget {
  final ChatUser chatUser;

  NewSingleCustomer(this.chatUser, {Key? key}) : super(key: key);

  @override
  _NewSingleCustomerState createState() => _NewSingleCustomerState();
}

class _NewSingleCustomerState extends State<NewSingleCustomer> {
  bool _absorbing = false;
  late Future<double> totalAmountFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeData();
  }

  // void _loadTotalAmount() {
  //   totalAmountFuture = APIs.calculateTotalAmount(widget.chatUser);
  // }

  void _initializeData() {
    //_calculateTotalAmount();
    _getSelfInfo();
  }

  void _getSelfInfo() {
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              //elevation: 0.0,
              //backgroundColor: Colors.transparent,
              title: const Text(
                "User Transactions",
                style: TextStyle(fontSize: 16),
              ),
              iconTheme: const IconThemeData(),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      size: 20.0,
                      color: Colors.red,
                    ),
                    onPressed: () => _showDeleteWarningDialog(context),
                  ),
                ),
              ],
            ),
            body: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: mq.height * 0.02,
                  ),
                  Column(
                    children: [
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ViewProfileScreen(user: widget.chatUser),
                          ),
                        ),
                        child: Container(
                          height: mq.height * 0.2,
                          width: mq.width * .9,
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
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                child: CircleAvatar(
                                  radius: 36.0,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage:
                                      NetworkImage(widget.chatUser.image),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        padding:
                                            const EdgeInsets.fromLTRB(0, 0, 0, 4),
                                        child: Text(
                                          widget.chatUser.name,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          const Icon(
                                            Icons.phone,
                                            size: 12.0,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                8, 4, 4, 4),
                                            child: Text(
                                              widget.chatUser.phoneNo,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (widget.chatUser.address.isNotEmpty)
                                        Row(
                                          children: <Widget>[
                                            const Icon(
                                              Icons.location_on,
                                              size: 12.0,
                                            ),
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.fromLTRB(
                                                    8, 4, 4, 4),
                                                child: Text(
                                                  widget.chatUser.address,
                                                  style:
                                                      const TextStyle(fontSize: 12),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (widget.chatUser.email.isNotEmpty)
                                        Row(
                                          children: <Widget>[
                                            const Icon(
                                              Icons.email,
                                              size: 12.0,
                                            ),
                                            Container(
                                              padding: const EdgeInsets.fromLTRB(
                                                  8, 4, 4, 4),
                                              child: Text(
                                                widget.chatUser.email,
                                                style:
                                                    const TextStyle(fontSize: 12),
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
                    ],
                  ),
                  SizedBox(
                    height: mq.height * 0.02,
                  ),
                  Container(
                    width: mq.width * 0.9,
                    height: mq.height * 0.09,
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
                    padding: const EdgeInsets.only(
                        top: 8, left: 16, bottom: 8, right: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          //color: Colors.brown,
                          child: StreamBuilder<double>(
                            stream: APIs.calculateTotalAmountStream(
                                widget.chatUser),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (snapshot.hasData) {
                                final totalAmount = snapshot.data ?? 0;
                                if (totalAmount == 0) {
                                  // Display only "Rs 0" without the additional text
                                  return Center(
                                    child: Text(
                                      _formatAmount(totalAmount),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: xPlainTextGreen, // Default color
                                      ),
                                    ),
                                  );
                                } else {
                                  final isPositive = totalAmount > 0;
                                  final amountText = isPositive
                                      ? "I Have To Return"
                                      : "I Have To Take";
                                  final displayAmount = totalAmount != 0
                                      ? totalAmount
                                      : 0; // Ensure "Rs 0" is displayed

                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _formatAmount(
                                              displayAmount.toDouble()),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: isPositive
                                                ? xPlainTextRed
                                                : xPlainTextGreen,
                                          ),
                                        ),
                                        Text(
                                          amountText,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: isPositive
                                                ? xPlainTextRed
                                                : xPlainTextGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              } else {
                                // If snapshot has no data, we also display "Rs 0"
                                return Center(
                                  child: Text(
                                    _formatAmount(0),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          xPlainTextGreen, // Use the default color
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Stack(
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  // Navigate to ChatScreen
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        user: widget.chatUser,
                                      ),
                                    ),
                                  );
                                },
                                label: const Text(
                                  "Inbox",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 11),
                                ),
                                icon: const Icon(Icons.chat,
                                    size: 12.0, color: Colors.white),
                              ),
                              // Position the unread message indicator
                              Positioned(
                                top: -3,
                                right: 10,
                                child: StreamBuilder(
                                  stream: APIs.getUnreadMessageCount(
                                      widget.chatUser),
                                  builder: (context, snapshot) {
                                    int unreadCount = snapshot.data ?? 0;
                                    return unreadCount > 0
                                        ? Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '$unreadCount',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Text(
                                              '0',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: mq.height * 0.02,
                  ),
                  Container(
                    height: mq.height * 0.45,
                    width: mq.width * 0.9,
                    decoration: const BoxDecoration(),
                    child: Transform.translate(
                      offset: const Offset(2.0, 2.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),

                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 2),
                                blurRadius: 6.0),
                          ],
                          //color: Colors.white70,
                        ),
                        child:
                            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: APIs.getAllTransactions(widget.chatUser),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child:
                                    Text('An error occured: ${snapshot.error}'),
                              );
                            } else if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Text('No transaction made yet!'),
                              );
                            } else {
                              List<TransactionFirebase> transactions =
                                  snapshot.data!.docs.map((doc) {
                                return TransactionFirebase.fromJson(doc.data());
                              }).toList();
                              return Container(
                                //padding: const EdgeInsets.all(5),
                                width: mq.width * .9,
                                height: mq.height * .1,
                                child: ListView.builder(
                                  itemCount: transactions.length,
                                  itemBuilder: (context, index) {
                                    final transaction = transactions[index];
                                    final isDebit =
                                        transaction.type.toLowerCase() ==
                                            'debit';
                                    final isMadeByMe =
                                        transaction.fromId == APIs.user.uid;

                                    Widget? statusIcon;
                                    if (transaction.status == 'Approved') {
                                      statusIcon = const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 14,
                                      );
                                    } else if (transaction.status ==
                                        'Declined') {
                                      statusIcon = const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                        size: 14,
                                      );
                                    }
                                    return Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.white,
                                            boxShadow: const [
                                              BoxShadow(
                                                  color: Colors.black12,
                                                  offset: Offset(0, 2),
                                                  blurRadius: 2.0),
                                            ],
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 1, horizontal: 2),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundImage: isMadeByMe
                                                  ? NetworkImage(APIs.me.image)
                                                  : NetworkImage(
                                                      widget.chatUser.image),
                                              radius: 24,
                                            ),
                                            title: Text(
                                              isMadeByMe
                                                  ? APIs.auth.currentUser!
                                                      .displayName
                                                      .toString()
                                                  : widget.chatUser.name,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                            subtitle: Text(
                                              _formatDateString(
                                                  transaction.timestamp),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            trailing: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  _formatAmount(
                                                      transaction.amount),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: transaction.status == 'Approved' 
                                                        ? Colors.green
                                                        : Colors.red,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height:
                                                        4), // Spacing between amount and type
                                                Text(
                                                  isDebit
                                                      ? 'Recevied'
                                                      : 'Given',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            onTap: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      NewTransactionView(
                                                    transaction: transaction,
                                                    chatUser: widget.chatUser,
                                                  ),
                                                ),
                                              );
                                            },
                                            onLongPress: () {
                                              _showTransactionOptionsDialog(
                                                  context, transaction);
                                            },
                                          ),
                                        ),
                                        if (statusIcon != null)
                                          Positioned(
                                            top: 5,
                                            right: 2,
                                            child: CircleAvatar(
                                              backgroundColor: Colors.white,
                                              radius: 12,
                                              child: statusIcon,
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  // You can add additional sections here for displaying more information
                ],
              ),
            ),

            // floatingActionButtonLocation:
            //     FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: Colors.white,

              heroTag: "credit",
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddTransactionPage(chatUser: widget.chatUser),
                  ),
                );
              },
              label: const Text(
                "Add Payments",
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
              icon: const Icon(
                Icons.add,
                size: 18,
                color: Colors.black,
              ),
              //backgroundColor: Colors.red,
            ),
          ),
          if (_absorbing)
            AbsorbPointer(
              absorbing: _absorbing,
              child: Container(
                constraints: const BoxConstraints.expand(),
                color: Colors.white,
                child: Center(
                  child: LoadingAnimationWidget.fourRotatingDots(
                      color: Colors.black, size: 60),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDateString(String dateString) {
    try {
      // Parse the date string to DateTime
      DateTime dateTime =
          DateFormat('yyyy-MM-dd HH:mm:ss.SSS').parse(dateString);

      // Format DateTime to a readable format
      return DateFormat('yyyy-MM-dd').format(dateTime);
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

  void _showTransactionOptionsDialog(
      BuildContext contex, TransactionFirebase transaction) {
    showDialog(
      context: context,
      builder: (contex) {
        return AlertDialog(
          //title: const Text('Options'),
          content: const Text(
              'What would you like to share that transaction in chats?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                shareTransactionsToChat(context, transaction);
              },
              child: const Text(
                'Share To Chat',
                style: TextStyle(color: Colors.green),
              ),
            ),
            // TextButton(
            //   onPressed: () {
            //     Navigator.pop(context);
            //     // Call your delete transaction method here
            //     _deleteTransaction(transaction);
            //   },
            //   child: Text('Delete'),
            // ),
          ],
        );
      },
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

  // Show the warning dialog before deleting
  void _showDeleteWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: const Text(
              'This will remove this user profile from your side. You still can get the transactions and chats after re-adding this user. Are you sure you want to proceed?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Dialogs.showLoading(context);
                _deleteChatUserAndTransactions();
                Navigator.of(context, rootNavigator: true).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MessageScreen(),
                  ),
                );
                Dialogs.showSnackbar(context, "User deleted successfully");
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Delete the ChatUser and all related transactions on the current user's side
  void _deleteChatUserAndTransactions() async {
    try {
      // Delete the ChatUser document
      await APIs.deleteChatUser(widget.chatUser);

      // Delete all transactions related to this user on the current user's side
      //await APIs.deleteAllTransactionsForUser(widget.chatUser);

      // Show a success message or navigate back

      // Navigate back to the previous screen
    } catch (e) {
      // Handle any errors that might occur during deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e')),
      );
    } finally {
      // Hide the loading indicator
    }
  }
}
