import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_notifications/screens/contacts/importContacts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../blocs/customerBloc.dart';
import '../../helpers/appLocalizations.dart';
import '../../models/customer.dart';
import '../../my_home_page.dart';

class AddCustomer extends StatefulWidget {
  @override
  _AddCustomerState createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  final CustomerBloc customerBloc = CustomerBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? _name, _phone, _address, _email;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  Customer _customer = Customer();

  Future<void> getImageFrom(String from) async {
    final XFile? image = from == 'camera'
        ? await _picker.pickImage(source: ImageSource.camera)
        : await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final ImageProperties properties =
        await FlutterNativeImage.getImageProperties(image.path);
    final File rawImage = await FlutterNativeImage.compressImage(
      image.path,
      quality: 80,
      targetWidth: 512,
      targetHeight: (properties.height! * 512 / properties.width!).round(),
    );

    if (rawImage.lengthSync() > 200000) {
      final snackBar = SnackBar(
        content: Row(
          children: <Widget>[
            const Icon(Icons.warning, color: Colors.redAccent),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
              child: Text(
                  AppLocalizations.of(context)!.translate('imageSizeError')),
            ),
          ],
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    setState(() {
      _image = rawImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        //backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          title: Text(
            AppLocalizations.of(context)!.translate('addCustomer'),
            style: const TextStyle(
              //color: Colors.black,
              fontSize: 18,
            ),
          ),
          //iconTheme: IconThemeData(color: Colors.black),
          actions: <Widget>[
            TextButton.icon(
              label: Text(
                AppLocalizations.of(context)!.translate('importContacts'),
                style: const TextStyle(fontSize: 12),
              ),
              icon: const Icon(
                Icons.control_point,
                size: 20.0,
                //color: Colors.blue,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ImportContacts()),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: null,
          onPressed: addCustomer,
          icon: const Icon(Icons.check),
          label: Text(AppLocalizations.of(context)!.translate('addCustomer')),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 48),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  customerImageWidget(),
                  const SizedBox(
                    height: 25,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      icon: const Icon(Icons.person),
                      hintText: AppLocalizations.of(context)!
                          .translate('customerNameLabelMeta'),
                      labelText: AppLocalizations.of(context)!
                          .translate('customerNameLabel'),
                    ),
                    validator: (input) {
                      if (input == null || input.isEmpty) {
                        return AppLocalizations.of(context)!
                            .translate('customerNameError');
                      }
                      return null;
                    },
                    onSaved: (input) => _name = input,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      icon: const Icon(Icons.call_missed_outgoing),
                      hintText: AppLocalizations.of(context)!
                          .translate('customerPhoneLabelMeta'),
                      labelText: AppLocalizations.of(context)!
                          .translate('customerPhoneLabel'),
                    ),
                    validator: (input) {
                      if (input == null || input.isEmpty) {
                        return AppLocalizations.of(context)!
                            .translate('customerPhoneError');
                      }
                      return null;
                    },
                    onSaved: (input) => _phone = input,
                  ),
                  SizedBox(height: 16,),
                  TextFormField(
                    decoration: InputDecoration(
                      icon: const Icon(Icons.location_city),
                      hintText: AppLocalizations.of(context)!
                          .translate('customerAddressLabelMeta'),
                      labelText: AppLocalizations.of(context)!
                          .translate('customerAddressLabel'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    validator: null,
                    onSaved: (input) => _address = input,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      icon: const Icon(Icons.email),
                      hintText: AppLocalizations.of(context)!
                          .translate('customerEmailLabelMeta'),
                      labelText: AppLocalizations.of(context)!
                          .translate('customerEmailLabel'),
                    ),
                    validator: null,
                    onSaved: (input) => _email = input,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(36),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget customerImageWidget() {
    return Row(
      children: <Widget>[
        Center(
          child: _image == null
              ? Image.asset('assets/images/noimage_person.png', width: 60)
              : Image.file(_image!, width: 60),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextButton(
            onPressed: showUploadDialog,
            child: Text(
                AppLocalizations.of(context)!.translate('customerImageLabel')),
          ),
        ),
      ],
    );
  }

  void showUploadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
              AppLocalizations.of(context)!.translate('customerImageLabel')),
          children: <Widget>[
            SimpleDialogOption(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(AppLocalizations.of(context)!
                    .translate('uploadFromCamera')),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                getImageFrom('camera');
              },
            ),
            SimpleDialogOption(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(AppLocalizations.of(context)!
                    .translate('uploadFromGallery')),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                getImageFrom('gallery');
              },
            ),
          ],
        );
      },
    );
  }

  void addCustomer() async {
    final formState = _formKey.currentState;

    if (formState?.validate() ?? false) {
      formState?.save();

      _customer
        ..name = _name
        ..phone = _phone
        ..address = _address
        ..image =
            _image != null ? base64Encode(_image!.readAsBytesSync()) : null
        ..email = _email;
        

      final prefs = await SharedPreferences.getInstance();
      _customer.businessId = prefs.getInt('selected_business') ?? 0;

      await customerBloc.addCustomer(_customer);

      Navigator.of(context).pop();
      setState(() {});
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }
  }
}
