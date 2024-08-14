import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/constants.dart';

class MyThemeProvider extends ChangeNotifier {

  bool _darkTheme = false;

  bool get themeType => _darkTheme;

  set setTheme(bool value){
    _darkTheme = value;
    saveThemeToSharedPreferences(value: value);
    notifyListeners();

  }

  void saveThemeToSharedPreferences({required bool value}) async{
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(themeStatus, value);
  }

  getThemeStatus() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _darkTheme = sharedPreferences.getBool(themeStatus) ?? false;
    notifyListeners();
  }
}