import 'package:flutter/material.dart';

import '../../blocs/businessBloc.dart';
import '../../helpers/appLocalizations.dart';
import '../../my_home_page.dart';
import '../../providers/stateNotifier.dart';
import '../../models/business.dart';

class DeleteBusiness extends StatefulWidget {
  DeleteBusiness({Key? key}) : super(key: key);
  @override
  _DeleteBusinessState createState() => _DeleteBusinessState();
}

class _DeleteBusinessState extends State<DeleteBusiness> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final BusinessBloc _businessBloc = BusinessBloc();

  List<Business> _businesses = [];

  int _radioValue = 0;

  @override
  void initState() {
    super.initState();
    loadBusinesses();
  }

  void loadBusinesses() async {
    if (!mounted) return;
    List<Business> bs = await _businessBloc.getBusinesss();

    setState(() {
      _businesses = bs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          title: Text(
            AppLocalizations.of(context)!.translate('deleteCompany'),
            style: const TextStyle(color: Colors.black),
          ),
          iconTheme: const IconThemeData(
            color: Colors.black, //change your color here
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            deleteCompany();
          },
          icon: const Icon(
            Icons.check,
          ),
          label: Text(AppLocalizations.of(context)!.translate('deleteCompany')),
        ),
        body: Container(
          decoration: const BoxDecoration(color: Colors.white),
          padding: const EdgeInsets.all(20),
          child: ListView.builder(
              itemCount: _businesses.length,
              itemBuilder: (context, index) {
                final business = _businesses[index];
                return RadioListTile(
                  title: Text(
                    business.companyName!,
                  ),
                  value: index,
                  groupValue: _radioValue,
                  activeColor: const Color(0xFF6200EE),
                  onChanged: (val) {
                    setState(() {
                      _radioValue = val!;
                    });
                  },
                );
              }),
        ),
      ),
    );
  }

  void deleteCompany() async {
    int id = _businesses[_radioValue].id!;
    if (id == 0) return;
    await _businessBloc.deleteBusinessById(id);
    changeSelectedBusiness(context, 0);
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
