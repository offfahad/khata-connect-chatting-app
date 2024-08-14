import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

import '../blocs/businessBloc.dart';
import '../blocs/customerBloc.dart';
import '../blocs/transactionBloc.dart';
import '../models/business.dart';
import '../models/customer.dart';

Future<Uint8List> generateCustomerPdf() async {
  PdfPageFormat pageFormat = PdfPageFormat.a4;

  final CustomerBloc customerBloc = CustomerBloc();
  final TransactionBloc transactionBloc = TransactionBloc();
  final BusinessBloc businessBloc = BusinessBloc();

  List<Customer> customersList = await customerBloc.getCustomers();

  List<Map<String, dynamic>> customers = [];

  // Use `Future.wait` to await all transaction calculations before adding customers
  await Future.wait(customersList.map((c) async {
    double amt = await transactionBloc.getCustomerTransactionsTotal(c.id!);
    customers.add({
      'amount': amt,
      'id': c.id,
      'name': c.name,
      'phone': c.phone,
      'address': c.address,
    });
  }));

  final prefs = await SharedPreferences.getInstance();
  String? currency =
      prefs.getString("currency") ?? "Rs"; // Provide a default value

  Business businessInfo = Business(
    id: 0,
    name: "",
    phone: "",
    email: "",
    address: "",
    logo: "",
    website: "",
    role: "",
    companyName: "",
  );

  Business? business = await businessBloc.getBusiness(0);
  if (business != null) {
    businessInfo = business;
  }

  final invoice = CustomersList(
    customers: customers,
    businessInfo: businessInfo,
    baseColor: PdfColors.teal,
    accentColor: PdfColors.purple800,
    currency: currency,
    redColor: PdfColors.red700,
  );

  return await invoice.buildPdf(pageFormat);
}

class CustomersList {
  CustomersList({
    required this.customers,
    required this.businessInfo,
    required this.baseColor,
    required this.accentColor,
    required this.currency,
    required this.redColor,
  });

  final List<Map<String, dynamic>> customers;
  final Business businessInfo;
  final PdfColor baseColor;
  final PdfColor accentColor;
  final PdfColor redColor;
  final String currency;

  static const _darkColor = PdfColors.blueGrey800;
  static const _lightColor = PdfColors.white;

  PdfColor get _baseTextColor =>
      baseColor.luminance < 0.5 ? _lightColor : _darkColor;

  PdfColor get _accentTextColor =>
      baseColor.luminance < 0.5 ? _lightColor : _darkColor;

  double get _total => customers.isNotEmpty
      ? customers.map((p) => p['amount'] as double).reduce((a, b) => a + b)
      : 0;

  double get _grandTotal => _total;

  pw.Image? _logo;

  Future<Uint8List> buildPdf(PdfPageFormat pageFormat) async {
    final doc = pw.Document();

    if (businessInfo.logo!.isNotEmpty) {
      Uint8List logoBytes = const Base64Decoder().convert(businessInfo.logo!);
      _logo = pw.Image(
        pw.MemoryImage(logoBytes),
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageTheme: _buildTheme(pageFormat),
        header: _buildHeader,
        footer: _buildFooter,
        build: (context) => [
          _contentHeader(context),
          _contentTable(context),
          pw.SizedBox(height: 20),
          _contentFooter(context),
          pw.SizedBox(height: 20),
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _buildHeader(pw.Context context) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 40,
                    padding: const pw.EdgeInsets.only(left: 20),
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text(
                      'CUSTOMERS',
                      style: pw.TextStyle(
                        color: baseColor,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(2),
                      color: accentColor,
                    ),
                    padding:
                        const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    alignment: pw.Alignment.centerLeft,
                    height: 40,
                    child: pw.DefaultTextStyle(
                      style: pw.TextStyle(
                        color: _accentTextColor,
                        fontSize: 12,
                      ),
                      child: pw.GridView(
                        crossAxisCount: 2,
                        children: [
                          pw.Text('Date:'),
                          pw.Text(_formatDate(DateTime.now()).split(",")[0]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Container(
                    alignment: pw.Alignment.topRight,
                    padding: const pw.EdgeInsets.only(bottom: 8, left: 0),
                    height: 72,
                    child: _logo != null ? _logo : pw.Container(),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (context.pageNumber > 1) pw.SizedBox(height: 20),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
          'PDF Generated By Khata Connect',
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey,
          ),
        ),
        pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey,
          ),
        ),
      ],
    );
  }

  pw.PageTheme _buildTheme(PdfPageFormat pageFormat) {
    return pw.PageTheme(
      pageFormat: pageFormat,
      buildBackground: (context) => pw.FullPage(
        ignoreMargins: true,
        child: pw.Stack(
          children: [
            pw.Positioned(
              bottom: 0,
              left: 0,
              child: pw.Container(
                height: 20,
                width: pageFormat.width / 2,
                decoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [baseColor, PdfColors.white],
                  ),
                ),
              ),
            ),
            pw.Positioned(
              bottom: 20,
              left: 0,
              child: pw.Container(
                height: 20,
                width: pageFormat.width / 4,
                decoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [accentColor, PdfColors.white],
                  ),
                ),
              ),
            ),
            pw.Positioned(
              top: pageFormat.marginTop + 72,
              left: 0,
              right: 0,
              child: pw.Container(
                height: 3,
                color: baseColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _contentHeader(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Container(
            height: 70,
            child: pw.FittedBox(
              child: pw.Text(
                '${_formatCurrency(_grandTotal)}',
                style: pw.TextStyle(
                  color: _grandTotal.isNegative ? redColor : baseColor,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Row(
            children: [
              pw.SizedBox(width: 120),
              pw.Container(
                height: 80,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: '${businessInfo.companyName}\n',
                    style: pw.TextStyle(
                      color: _darkColor,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                    children: [
                      const pw.TextSpan(
                        text: '\n',
                        style: pw.TextStyle(fontSize: 5),
                      ),
                      pw.TextSpan(
                        text: businessInfo.address ?? "",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.normal,
                          fontSize: 10,
                        ),
                      ),
                      const pw.TextSpan(
                        text: '\n',
                        style: pw.TextStyle(fontSize: 5),
                      ),
                      pw.TextSpan(
                        text: businessInfo.phone ?? "",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.normal,
                          fontSize: 10,
                        ),
                      ),
                      const pw.TextSpan(
                        text: '\n',
                        style: pw.TextStyle(fontSize: 5),
                      ),
                      pw.TextSpan(
                        text: businessInfo.email ?? "",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.normal,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _contentFooter(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [],
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.DefaultTextStyle(
            style: const pw.TextStyle(
              fontSize: 10,
              color: _darkColor,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.DefaultTextStyle(
                  style: pw.TextStyle(
                    color: baseColor,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total:'),
                      pw.Text(
                        _formatCurrency(_grandTotal),
                        style: pw.TextStyle(
                          color: _grandTotal.isNegative ? redColor : baseColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _contentTable(pw.Context context) {
    const tableHeaders = ['ID', 'Name', 'Phone', 'Address', 'Total'];

    return pw.Table.fromTextArray(
      border: null,
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(1),
        color: baseColor,
      ),
      headerHeight: 30,
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerLeft,
      },
      headerStyle: pw.TextStyle(
        color: _baseTextColor,
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: const pw.TextStyle(
        color: _darkColor,
        fontSize: 10,
      ),
      // rowDecoration: pw.BoxDecoration(
      //   border: pw.BoxBorder(
      //     bottom: true,
      //     color: baseColor,
      //     width: .5,
      //   ),
      // ),
      headers: tableHeaders,
      data: List<List<String>>.generate(
        customers.length,
        (row) {
          return [
            customers[row]['id'].toString(),
            customers[row]['name'],
            customers[row]['phone'],
            customers[row]['address'] ?? "",
            _formatCurrency(customers[row]['amount'] as double),
          ];
        },
      ),
    );
  }

  String _formatCurrency(double amount) {
    return "${amount.isNegative ? '-' : ''} $currency ${amount.abs().toStringAsFixed(2)}";
  }

  String _formatDate(DateTime date) {
    final format = DateFormat.yMd('en_US');
    return format.format(date);
  }
}
