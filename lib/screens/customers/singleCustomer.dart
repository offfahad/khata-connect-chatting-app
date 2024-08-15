import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_notifications/api/apis.dart';
import 'package:flutter_notifications/helpers/dialogs.dart';
import 'package:flutter_notifications/helpers/generateCustomerTransaction.dart';
import 'package:flutter_notifications/models/chat_user.dart';
import 'package:flutter_notifications/models/message.dart';
import 'package:flutter_notifications/screens/messages/chat_screen.dart';
import 'package:flutter_notifications/screens/messages/messages_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

import '../../blocs/customerBloc.dart';
import '../../blocs/transactionBloc.dart';
import '../../helpers/appLocalizations.dart';
import '../../helpers/constants.dart';
import '../../helpers/conversion.dart';
import '../../models/customer.dart';
import '../../models/transaction.dart';
import '../../my_home_page.dart';
import '../transactions/addTransaction.dart';
import 'editCustomer.dart';
import '../transactions/singleTransaction.dart';

class SingleCustomer extends StatefulWidget {
  final int customerId;

  SingleCustomer(this.customerId, {Key? key}) : super(key: key);

  @override
  _SingleCustomerState createState() => _SingleCustomerState();
}

class _SingleCustomerState extends State<SingleCustomer> {
  final CustomerBloc customerBloc = CustomerBloc();
  final TransactionBloc transactionBloc = TransactionBloc();
  bool _absorbing = false;

  void _showDeleteDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(AppLocalizations.of(context)!.translate('deleteCustomer')),
          content: Text(
              AppLocalizations.of(context)!.translate('deleteCustomerLabel')),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.translate('closeText')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                AppLocalizations.of(context)!.translate('deleteText'),
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: () {
                customerBloc.deleteCustomerById(customer.id!);
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void generatePdf() async {
    setState(() {
      _absorbing = true;
    });
    Uint8List pdf = await generateCustomerTransactionPdf(widget.customerId);
    final dir = await getExternalStorageDirectory();
    final file = File('${dir?.path}/report.pdf');
    await file.writeAsBytes(pdf);
    OpenFile.open(file.path);
    setState(() {
      _absorbing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Customer>(
      future: customerBloc.getCustomer(widget.customerId),
      builder: (BuildContext context, AsyncSnapshot<Customer> snapshot) {
        if (snapshot.hasData) {
          Customer customer = snapshot.data!;

          Uint8List? customerImage;
          if (customer.image != null && customer.image!.isNotEmpty) {
            customerImage = const Base64Decoder().convert(customer.image!);
          }

          return SafeArea(
            child: Stack(
              children: [
                Scaffold(
                  resizeToAvoidBottomInset: true,
                  appBar: AppBar(
                    elevation: 0.0,
                    backgroundColor: Colors.transparent,
                    title: null,
                    iconTheme: const IconThemeData(
                        //color: Colors.white,
                        ),
                    actions: <Widget>[
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 20.0,
                          color: Colors.purple,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditCustomer(customer),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          size: 20.0,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          _showDeleteDialog(customer);
                        },
                      ),
                    ],
                  ),
                  body: Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                        height: 180,
                        decoration: const BoxDecoration(
                            //color: Theme.of(context).primaryColor,
                            ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                  child: customerImage != null
                                      ? CircleAvatar(
                                          radius: 36.0,
                                          backgroundColor: Colors.transparent,
                                          child: ClipOval(
                                            child: Image.memory(customerImage,
                                                height: 80,
                                                width: 80,
                                                fit: BoxFit.cover),
                                          ),
                                        )
                                      : CircleAvatar(
                                          backgroundColor:
                                              Colors.purple.shade500,
                                          radius: 30,
                                          child: Icon(Icons.person,
                                              color: Colors.purple.shade100,
                                              size: 30.0),
                                        ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 0, 4),
                                        child: Text(
                                          customer.name!,
                                          style: const TextStyle(
                                              //color: Colors.white,
                                              fontSize: 16),
                                        ),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          const Icon(
                                            Icons.phone,
                                            //color: xLightWhite,
                                            size: 12.0,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                8, 4, 4, 4),
                                            child: Text(
                                              customer.phone!,
                                              style: const TextStyle(
                                                //color: xLightWhite,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (customer.address != null &&
                                          customer.address!.isNotEmpty)
                                        Row(
                                          children: <Widget>[
                                            const Icon(
                                              Icons.location_on,
                                              //color: xLightWhite,
                                              size: 12.0,
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      8, 4, 4, 4),
                                              child: Text(
                                                customer.address!,
                                                style: const TextStyle(
                                                    //color: xLightWhite,
                                                    fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (customer.email != null &&
                                          customer.email!.isNotEmpty)
                                        Row(
                                          children: <Widget>[
                                            const Icon(
                                              Icons.email,
                                              //color: xLightWhite,
                                              size: 12.0,
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      8, 4, 4, 4),
                                              child: Text(
                                                customer.email!,
                                                style: const TextStyle(
                                                    //color: xLightWhite,
                                                    fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: getCustomerTransactionsTotalWidget(
                                        widget.customerId),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          if (customer.email == null ||
                                              customer.email!.isEmpty) {
                                            Dialogs.showSnackbar(context,
                                                "Please add customer's email first.");
                                          } else {
                                            String customerEmail =
                                                customer.email!;
                                            ChatUser? chatUser =
                                                await APIs.getUserByEmail(
                                                    customerEmail);
                                            bool exists =
                                                await APIs.addChatUser(
                                                    customerEmail);
                                            if (exists) {
                                              // Dialogs.showSnackbar(context,
                                              //     "Customer added to your chat list.");
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          ChatScreen(
                                                            user: chatUser!,
                                                          )));
                                            } else {
                                              Dialogs.showSnackbar(context,
                                                  "Customer email does not register on this application. Please invite the customer to this application first.");
                                            }
                                          }
                                        },
                                        icon: const Icon(Icons.chat,
                                            size: 16.0, color: Colors.green),
                                        // label: Text(
                                        //   AppLocalizations.of(context)!
                                        //       .translate('Message'),
                                        //   style: const TextStyle(
                                        //     //color: xLightWhite,
                                        //     color: Colors.green,
                                        //     fontSize: 12,
                                        //   ),
                                        // ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          generatePdf();
                                        },
                                        icon: const Icon(Icons.picture_as_pdf,
                                            size: 16.0, color: Colors.blue),
                                        // label: Text(
                                        //   AppLocalizations.of(context)!
                                        //       .translate('exportText'),
                                        //   style: const TextStyle(
                                        //     color: Colors.blue,
                                        //     fontSize: 14,
                                        //   ),
                                        // ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          // Assuming the customer's phone number is not null
                                          String customerPhone =
                                              customer.phone!;

                                          // Compose your message
                                          String message =
                                              'Hi, I would like to invite you to use this amazing app. Download it here: [app_link]';

                                          // Share the SMS
                                          Share.share(
                                            message,
                                            subject: 'App Invitation',
                                          );
                                        },
                                        icon: const Icon(Icons.share,
                                            size: 16.0, color: Colors.orange),
                                        // label: Text(
                                        //   AppLocalizations.of(context)!
                                        //       .translate('exportText'),
                                        //   style: const TextStyle(
                                        //     color: Colors.blue,
                                        //     fontSize: 14,
                                        //   ),
                                        // ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                              //color: Theme.of(context).primaryColor,
                              ),
                          child: Transform.translate(
                            offset: const Offset(2.0, 2.0),
                            child: Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(25),
                                    topLeft: Radius.circular(25)),
                                color: Colors.white,
                              ),
                              child: getCustomerTransactions(widget.customerId),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerDocked,
                  floatingActionButton: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FloatingActionButton.extended(
                          icon: const Icon(
                            Icons.arrow_upward,
                            size: 18,
                            color: Colors.white,
                          ),
                          backgroundColor: xPlainTextRed,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddTransaction(customer, "credit"),
                              ),
                            );
                          },
                          label: Text(
                            AppLocalizations.of(context)!
                                .translate('creditGiven'),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                          heroTag: "credit",
                        ),
                        FloatingActionButton.extended(
                          icon: const Icon(
                            Icons.arrow_downward,
                            size: 18,
                            color: Colors.white,
                          ),
                          backgroundColor: xPlainTextGreen,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddTransaction(customer, "payment"),
                              ),
                            );
                          },
                          label: Text(
                            AppLocalizations.of(context)!
                                .translate('paymentReceived'),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                          heroTag: "payment",
                        ),
                      ],
                    ),
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
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget getCustomerTransactionsTotalWidget(int cid) {
    return FutureBuilder<double>(
      future: transactionBloc.getCustomerTransactionsTotal(cid),
      builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
        if (snapshot.hasData) {
          double total = snapshot.data!;
          String ttype = "payment";
          if (total.isNegative) {
            ttype = "credit";
          }
          if (total == 0) return Container();
          return Text(
            amountFormat(context, total.abs()),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ttype == 'payment' ? xPlainTextGreen : xPlainTextRed,
            ),
          );
        }

        return Container();
      },
    );
  }

  Widget getCustomerTransactions(int cid) {
    return FutureBuilder<List<Transaction>>(
      future: transactionBloc.getTransactionsByCustomerId(cid),
      builder:
          (BuildContext context, AsyncSnapshot<List<Transaction>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No transactions made yet!",
                style: TextStyle(color: Colors.black),
              ),
            );
          }
          return Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 60),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, itemIndex) {
                    Transaction transaction = snapshot.data![itemIndex];
                    Map<String, String> dateFormatted =
                        formatDate(context, transaction.date!);
                    return Column(
                      children: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SingleTransaction(transaction.id!),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 16, 0),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.grey.shade200,
                                    radius: 25,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          dateFormatted["day"]!,
                                          style: TextStyle(
                                            color: Colors.deepPurple.shade900,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          dateFormatted['month']!,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 4, 8, 4),
                                        child: Text(
                                          transaction.comment!,
                                          softWrap: true,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(minWidth: 80),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                amountFormat(context,
                                                    transaction.amount!.abs()),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: transaction.ttype ==
                                                          'payment'
                                                      ? xPlainTextGreen
                                                      : xPlainTextRed,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 4, 0, 0),
                                            child: Text(
                                              transaction.ttype == "credit"
                                                  ? AppLocalizations.of(
                                                          context)!
                                                      .translate('given')
                                                  : AppLocalizations.of(
                                                          context)!
                                                      .translate('received'),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10,
                                                  letterSpacing: 0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (snapshot.data!.length - 1 != itemIndex)
                          Divider(
                            color: Colors.grey.shade300,
                            height: 2,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Unknown Error."));
        }

        return Center(
          child: LoadingAnimationWidget.fourRotatingDots(
              color: Theme.of(context).colorScheme.secondary, size: 60),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
