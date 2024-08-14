import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notifications/api/apis.dart';
import 'package:flutter_notifications/blocs/businessBloc.dart';
import 'package:flutter_notifications/helpers/appLocalizations.dart';
import 'package:flutter_notifications/models/business.dart';
import 'package:flutter_notifications/providers/stateNotifier.dart';
import 'package:flutter_notifications/screens/businesses/addBusiness.dart';
import 'package:flutter_notifications/screens/customers/customers.dart';
import 'package:flutter_notifications/screens/messages/messages_screen.dart';
import 'package:flutter_notifications/screens/setting/settings.dart';
import 'package:flutter_notifications/services/loadBusinessInfo.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final BusinessBloc businessBloc = BusinessBloc();
  int _selectedIndex = 0;
  List<Business?> _businesses = [];
  Business? _selectedBusiness;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
    APIs.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  Future<void> _initialize() async {
    await getTheLocale();

    if (mounted) {
      await getAllBusinesses();
    }
  }

  Future<void> getAllBusinesses() async {
    List<Business?> businesses = await businessBloc.getBusinesss();

    if (businesses.isEmpty) {
      // Check if the widget is still mounted before using context
      if (mounted) {
        await loadBusinessInfo(context);
        businesses =
            await businessBloc.getBusinesss(); // Refresh list after loading
      } else {
        return; // Exit early if the widget is no longer mounted
      }
    }

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    int selectedBusinessId = prefs.getInt('selected_business') ?? 0;

    Business? selectedBusiness;
    try {
      selectedBusiness = businesses.firstWhere(
        (business) => business?.id == selectedBusinessId,
      );
    } catch (e) {
      selectedBusiness = null;
    }

    if (mounted) {
      setState(() {
        _businesses = businesses;
        _selectedBusiness = selectedBusiness;
        _isLoading = false;
      });
    }
  }

  Future<void> getTheLocale() async {
    await fetchLocale(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: SafeArea(
        child: Stack(
          children: <Widget>[
            Scaffold(
              appBar: AppBar(
                //iconTheme: IconThemeData(color: Colors.white),
                backgroundColor: Colors.transparent,
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/logo2.png',
                      width: 35,
                      height: 35,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      "Khata Connect",
                      style: TextStyle(
                          //color: Colors.grey,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                elevation: 0,
                //backgroundColor: Theme.of(context).colorScheme.primary,
                actions: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButton<Business>(
                      value: _selectedBusiness,
                      underline: const SizedBox(),
                      onChanged: (Business? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedBusiness = newValue;
                          });
                          changeSelectedBusiness(context, newValue.id!);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddBusiness(),
                            ),
                          );
                        }
                      },
                      items: _businesses.map<DropdownMenuItem<Business>>(
                        (Business? business) {
                          if (business != null) {
                            return DropdownMenuItem<Business>(
                              value: business,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    business.logo!.isNotEmpty
                                        ? CircleAvatar(
                                            //backgroundColor: Colors.white,
                                            radius: 15,
                                            child: ClipOval(
                                              child: Image.memory(
                                                const Base64Decoder()
                                                    .convert(business.logo!),
                                                width: 30,
                                                height: 30,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        : const SizedBox(width: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      business.companyName!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        //color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return DropdownMenuItem<Business>(
                            value: business,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add,
                                  size: 18,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!
                                      .translate('addRemoveBusiness'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList()
                        ..add(
                          DropdownMenuItem<Business>(
                            value: null,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add,
                                  size: 18,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!
                                      .translate('addRemoveBusiness'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
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
              body: Center(
                child: _isLoading
                    ? LoadingAnimationWidget.fourRotatingDots(
                        color: Colors.black, size: 60)
                    : IndexedStack(
                        index: _selectedIndex,
                        children: const [
                          Customers(),
                          MessageScreen(),
                          Settings()
                        ],
                      ),
              ),
              bottomNavigationBar: BottomNavigationBar(
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.people),
                    label: AppLocalizations.of(context)!.translate('customers'),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.chat),
                    label: AppLocalizations.of(context)!.translate("inbox"),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.menu),
                    label: AppLocalizations.of(context)!.translate('more'),
                  ),
                ],
                currentIndex: _selectedIndex,
                //selectedItemColor: Colors.redAccent,
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
              ),
            ),
            // if (_isLoading)
            //   Center(
            //     child: LoadingAnimationWidget.fourRotatingDots(
            //           color: Colors.black, size: 60),
            //   ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
