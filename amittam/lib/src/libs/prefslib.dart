import 'package:Amittam/src/libs/encryption_library.dart';
import 'package:Amittam/src/libs/firebaselib.dart';
import 'package:Amittam/src/libs/lib.dart';
import 'package:Amittam/src/objects/language.dart';
import 'package:Amittam/src/objects/password.dart';
import 'package:Amittam/src/values.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as crypt;

class Prefs {
  static SharedPreferences preferences;

  static Future<void> initialize() async {
    preferences = await SharedPreferences.getInstance();
    currentLang = langToLanguage(lang);
  }

  static set autofillPasswords(List<Password> l) {
    String tempString = '';
    for (var pw in l)
      tempString =
          '$tempString${pw.asDecryptedPassword.asAutofillPassword}${l.indexOf(pw) != l.length - 1 ? '}' : ''}';
    preferences.setString('autofill_passwords', tempString);
    print(tempString);
  }

  static set firstLogin(bool b) => preferences.setBool('first_login', b);

  static bool get firstLogin => getBool('first_login', true);

  static set useSystemTheme(bool b) {
    preferences.setBool('use_system_theme', b);
    if (b)
      useDarkTheme = MediaQueryData.fromWindow(WidgetsBinding.instance.window)
              .platformBrightness ==
          Brightness.dark;
    if (FirebaseService.isSignedIn) FirebaseService.saveSettings();
  }

  static bool get useSystemTheme => getBool('use_system_theme', true);

  static set useDarkTheme(bool b) {
    preferences.setBool('use_dark_theme', b);
    if (FirebaseService.isSignedIn) FirebaseService.saveSettings();
  }

  static bool get useDarkTheme {
    if (useSystemTheme)
      return MediaQueryData.fromWindow(WidgetsBinding.instance.window)
              .platformBrightness ==
          Brightness.dark;
    else
      return getBool(
          'use_dark_theme',
          MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                  .platformBrightness ==
              Brightness.dark);
  }

  static set fastLogin(bool b) {
    preferences.setBool('fast_login', b);
    FirebaseService.saveSettings();
  }

  static bool get fastLogin => getBool('fast_login', true);

  static bool get allowRetrievingCloudData =>
      getBool('allow_retrieving_cloud_data', false);

  static set allowRetrievingCloudData(bool b) =>
      preferences.setBool('allow_retrieving_cloud_data', b);

  static Lang get lang {
    String s = preferences.getString('saved_lang');
    if (s == null) lang = languageToLang(getLangByLocaleName());
    return EnumToString.fromString(
        Lang.values, getString('saved_lang', 'english'));
  }

  static set lang(Lang l) {
    preferences.setString('saved_lang', EnumToString.parse(l));
    if (FirebaseService.isSignedIn) FirebaseService.saveSettings();
  }

  static List<Password> get passwords {
    List<Password> tempPasswords = [];
    List<String> tempStringList = getStringList('passwords', []);
    for (String tempString in tempStringList)
      tempPasswords.add(Password.fromEncryptedJson(tempString));
    return tempPasswords;
  }

  static set passwords(List<Password> passwords) {
    autofillPasswords = passwords;
    if (FirebaseService.isSignedIn) FirebaseService.savePasswords(passwords);
    List<String> tempStringList = [];
    for (Password password in passwords)
      tempStringList.add(password.toEncryptedJson());
    preferences.setStringList('passwords', tempStringList);
    Values.passwords = passwords;
  }

  static bool getBool(String key, bool standardValue) {
    bool returnValue = preferences.getBool(key);
    if (returnValue == null) return standardValue;
    return returnValue;
  }

  static String getString(String key, String standardValue) {
    String returnValue = preferences.getString(key);
    if (returnValue == null) return standardValue;
    return returnValue;
  }

  static List<String> getStringList(String key, List<String> standardValue) {
    List<String> tempStringList = preferences.getStringList(key);
    if (tempStringList == null) return standardValue;
    return tempStringList;
  }
}
