import 'package:Amittam/libs/lib.dart';
import 'package:Amittam/libs/prefslib.dart';
import 'package:Amittam/libs/uilib.dart';
import 'package:Amittam/main.dart';
import 'package:Amittam/values.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:password_strength/password_strength.dart';

import 'package:encrypt/encrypt.dart' as crypt;

class FirstLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    updateBrightness();
    return MaterialApp(home: FirstLoginPage());
  }
}

class FirstLoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FirstLoginPageState();
}

class FirstLoginPageState extends State<FirstLoginPage> {
  Color passwordStrengthColor = Colors.grey;
  GlobalKey<FormFieldState> masterPWTextFieldKey = GlobalKey();
  TextEditingController masterPWTextFieldController = TextEditingController();
  String masterPWTextFieldErrorString;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.colorBackground,
      appBar: customAppBar(title: Strings.appTitle),
      body: InkWell(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.transparent,
          margin: EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                customTextFormField(
                  textinputType: TextInputType.visiblePassword,
                  errorText: masterPWTextFieldErrorString,
                  controller: masterPWTextFieldController,
                  key: masterPWTextFieldKey,
                  hint: 'Set Masterpassword',
                  onChanged: (textFieldText) {
                    setState(() => masterPWTextFieldErrorString = null);
                    String value = textFieldText.trim();

                    double strength = estimatePasswordStrength(value);

                    if (strength < 0.3)
                      setState(() => passwordStrengthColor = Colors.grey);
                    else if (strength < 0.7)
                      setState(() => passwordStrengthColor = Colors.orange);
                    else
                      setState(() => passwordStrengthColor = Colors.green);
                  },
                ),
                Padding(padding: EdgeInsets.all(8)),
                AnimatedContainer(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: passwordStrengthColor,
                    border: Border(),
                  ),
                  height: 10,
                  duration: Duration(milliseconds: 250),
                )
              ],
            ),
          ),
        ),
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
        },
      ),
      floatingActionButton: extendedFab(
        label: Text('Set Password'),
        onPressed: () {
          double strength =
              estimatePasswordStrength(masterPWTextFieldController.text.trim());
          if (strength < 0.3) {
            setState(() =>
                masterPWTextFieldErrorString = 'Password not strong enough!');
            return;
          }
          try {
            Prefs.setMasterPassword(masterPWTextFieldController.text.trim());
          } catch (e) {
            print(errorString(e));
            print('something failed');
            return;
          }
        },
        icon: Icon(MdiIcons.formTextboxPassword),
      ),
    );
  }
}