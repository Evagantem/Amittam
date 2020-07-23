import 'dart:async';

import 'package:Amittam/objects/password.dart';
import 'package:flutter/material.dart';

class CustomColors {
  static bool isDarkMode = false;

  static Color get colorForeground => isDarkMode ? Colors.white : Colors.black;
  static Color get colorBackground => isDarkMode ? Colors.black : Colors.white;
  static Color get lightBackground => isDarkMode
      ? Color.fromRGBO(45, 45, 45, 1)
      : Color.fromRGBO(220, 220, 220, 1);
  static Color get lightForeground => isDarkMode
      ? Color.fromRGBO(220, 220, 220, 1)
      : Color.fromRGBO(45, 45, 45, 1);

  static void setMode({@required bool darkMode}) {
    isDarkMode = darkMode;
  }
}

class Strings {
  static String get appTitle => 'Amittam';
}

class Values {
  static List<Password> passwords = [];
  static void Function() afterBrightnessUpdate;
}
