import 'package:flutter/material.dart';
import 'package:flutter_notifications/api/apis.dart';
import 'package:flutter_notifications/helpers/dialogs.dart';
import 'package:flutter_notifications/main.dart';
import 'package:flutter_notifications/onClould/newAddTransactions.dart';
import 'package:flutter_notifications/models/newTransactionsModel.dart';
import 'package:intl/intl.dart';
import '../models/chat_user.dart';

class EditTransactionPage extends StatefulWidget {
  final TransactionFirebase transaction;
  final ChatUser chatUser;

  const EditTransactionPage({
    Key? key,
    required this.transaction,
    required this.chatUser,
  }) : super(key: key);

  @override
  _EditTransactionPageState createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TextEditingController _statusController;
  late String _type;
  late DateTime _date;

  Color _givenButtonColor = Colors.grey.shade500; // Default color for 'Given'
  Color _receivedButtonColor =
      Colors.grey.shade500; // Default color for 'Received'
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
        text: widget.transaction.amount.toStringAsFixed(0));
    _descriptionController =
        TextEditingController(text: widget.transaction.description);
    _statusController = TextEditingController(text: widget.transaction.status);
    _date = DateTime.parse(widget.transaction.timestamp); // Initialize date
    _selectedType = widget.transaction.type;

    // Set initial button colors based on transaction type
    if (_selectedType == 'credit') {
      _givenButtonColor = Colors.blue.shade500;
      _receivedButtonColor = Colors.grey.shade500;
    } else if (_selectedType == 'debit') {
      _givenButtonColor = Colors.grey.shade500;
      _receivedButtonColor = Colors.blue.shade500;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _statusController.dispose();
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

  Future<void> _updateTransaction() async {
    if (_formKey.currentState?.validate() ?? false) {
      Dialogs.showLoading(context);

      final updatedTransaction = TransactionFirebase(
        id: widget.transaction.id,
        toId: widget.chatUser.id,
        type: _selectedType,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        description: _descriptionController.text,
        status: _statusController.text,
        timestamp:
            _date.toString(), // Update the timestamp with the selected date
        fromId: widget.transaction.fromId,
        updateBy: widget.transaction.updateBy,
        updateTimestamp: widget.transaction.updateTimestamp,
      );

      try {
        await APIs.updateTransaction(widget.chatUser, updatedTransaction);
        Navigator.of(context).pop();
        Dialogs.showSnackbar(context, "Transaction updated successfully.");
        Navigator.pop(context); // Go back to the previous screen
      } catch (e) {
        Dialogs.showSnackbar(context, "Failed to update transaction");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Transaction'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Center(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.55,
                width: MediaQuery.of(context).size.width * .9,
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
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
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
                          height: MediaQuery.of(context).size.height * 0.02,
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
                          height: MediaQuery.of(context).size.height * 0.01,
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
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                        // Date picker
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
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),

                        // Submit Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ElevatedButton(
                            onPressed: _updateTransaction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: const Text(
                              'Update Transaction',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
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

  // Method to handle type selection
  void _selectType(String type) {
    setState(() {
      _selectedType = type;
      _givenButtonColor =
          type == 'credit' ? Colors.blue.shade500 : Colors.grey.shade500;
      _receivedButtonColor =
          type == 'debit' ? Colors.blue.shade500 : Colors.grey.shade500;
    });
  }

  // Method to format the date
  Map<String, String> formatDateNew(BuildContext context, DateTime date) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('hh:mm a');
    return {
      'full': '${dateFormat.format(date)} ${timeFormat.format(date)}',
    };
  }
}
