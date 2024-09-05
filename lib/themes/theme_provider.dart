import 'package:flutter/material.dart';
import 'package:twitter_clone/themes/dark_mode.dart';
import 'package:twitter_clone/themes/light_mode.dart';

/*
  Theme provider  , this helps us to change app from light mode to dark mode

 */

class ThemeProvider with ChangeNotifier{
  //initialize set it as light mode
  ThemeData _themeData = lightMode;

  //get the current theme
  ThemeData get themeData =>_themeData;

  //is it dark mode currently?
  bool get isDarkMode=>_themeData == darkMode;

  //set the theme
  set themeData(ThemeData themeData){
    _themeData = themeData;

    //update UI
    notifyListeners();
  }
  //toggle between dark & light mode
  void toggleTheme(){
    if(_themeData == lightMode){
      themeData = darkMode;
    }
    else{
      themeData = lightMode;
    }
  }


}