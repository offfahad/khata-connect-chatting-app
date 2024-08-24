import 'package:flutter/material.dart';
import 'package:flutter_notifications/api/apis.dart';
import 'package:flutter_notifications/helpers/dialogs.dart';
import 'package:flutter_notifications/main.dart';
import 'package:flutter_notifications/models/newTransactionsModel.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_user.dart';

class AddTransactionPage extends StatefulWidget {
  final ChatUser chatUser;

  const AddTransactionPage({Key? key, required this.chatUser})
      : super(key: key);

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'credit'; // Default selection
  List<TransactionFirebase> _list = [];
  DateTime _date = DateTime.now();
  // Define button colors
  Color _givenButtonColor = Colors.blue.shade500; // Default color
  Color _receivedButtonColor = Colors.grey.shade500; // Default color

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.black38,
              onPrimary: Colors.black,
              surface: Color.fromARGB(255, 247, 237, 226),
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Theme.of(context).primaryColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _submitTransaction() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Show loading dialog
      Dialogs.showLoading(context);

      final type = _selectedType;
      final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
      final description = _descriptionController.text.isEmpty
          ? "No Description Added"
          : _descriptionController.text.trim();
      const status = "Approved"; // Status set to "Approved" by default

      // Use the selected date (_date) for the timestamp
      final transaction = TransactionFirebase(
        id: const Uuid().v4(),
        toId: widget.chatUser.id,
        type: type,
        amount: amount,
        description: description,
        status: status,
        timestamp: _date.toString(),
        fromId: APIs.user.uid,
        updateBy: '',
        updateTimestamp: '',
      );

      try {
        if (_list.isEmpty) {
          await APIs.sendFirstTransaction(widget.chatUser, transaction);
        } else {
          await APIs.sendTransaction(widget.chatUser, transaction);
        }

        // Show success message
        Dialogs.showSnackbar(context, "Transaction added");

        // Dismiss the loading dialog
        Navigator.of(context, rootNavigator: true).pop();

        // Navigate back
        Navigator.pop(context); // Go back to previous screen
      } catch (e) {
        // Dismiss the loading dialog in case of an error
        Navigator.of(context, rootNavigator: true).pop();

        Dialogs.showSnackbar(context, "Fail to add transaction");
      }
    }
  }

  void _selectType(String type) {
    setState(() {
      _selectedType = type;
      if (type == 'credit') {
        _givenButtonColor = Colors.blue.shade500;
        _receivedButtonColor = Colors.grey.shade500; // Reset color
      } else {
        _givenButtonColor = Colors.grey.shade500; // Reset color
        _receivedButtonColor = Colors.blue.shade500;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: mq.height * 0.03,
            ),
            Center(
              child: Container(
                height: mq.height * 0.55,
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
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: mq.height * 0.02,
                        ),

                        // Amount TextField with border
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: TextFormField(
                            controller: _amountController,
                            decoration: InputDecoration(
                              labelText: 'Amount',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an amount';
                              }

                              // Check if the input starts with zero or period
                              if (value.startsWith('0') &&
                                  value.length > 1 &&
                                  value[1] != '.') {
                                return 'Amount should not start with zero';
                              }
                              if (value.startsWith('.')) {
                                return 'Amount should not start with a period';
                              }

                              final amount = double.tryParse(value);
                              if (amount == null || amount <= 0) {
                                return 'Please enter a valid amount greater than 0';
                              }
                              return null;
                            },
                          ),
                        ),

                        SizedBox(
                          height: mq.height * 0.02,
                        ),

                        // Description TextField with border
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            maxLines: 2,
                          ),
                        ),
                        SizedBox(
                          height: mq.height * 0.02,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              Flexible(
                                child: ElevatedButton(
                                  onPressed: () => _selectType('credit'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _givenButtonColor,
                                    minimumSize: const Size.fromHeight(30),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  child: const Text(
                                    'Given',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: ElevatedButton(
                                  onPressed: () => _selectType('debit'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _receivedButtonColor,
                                    minimumSize: const Size.fromHeight(30),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  child: const Text(
                                    'Received',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: mq.height * 0.01,
                        ),
                        // Date picker button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: Colors.grey.shade500,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            icon: const Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                            ),
                            label: Text(
                              formatDateNew(context, _date)['full']!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                        SizedBox(
                          height: mq.height * 0.02,
                        ),

                        // Submit Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ElevatedButton(
                            onPressed: _submitTransaction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: const Text(
                              'Add Transaction',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ), // Optional: Adjust font size
                            ),
                          ),
                        ),
                      ],
                    ),
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

Map<String, String> formatDateNew(BuildContext context, DateTime date) {
  String formatted = DateFormat("dd, MMMM yyyy").format(date);
  String day = DateFormat("dd").format(date);
  String month = DateFormat("MMM").format(date);
  String year = DateFormat("yyyy").format(date);
  return {"full": formatted, "day": day, "month": month, "year": year};
}
