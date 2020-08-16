import 'dart:convert';

import 'package:Amittam/src/libs/lib.dart';
import 'package:Amittam/src/libs/prefslib.dart';
import 'package:Amittam/src/objects/password.dart';
import 'package:Amittam/src/objects/settings_object.dart';
import 'package:Amittam/src/values.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  static FirebaseUser firebaseUser;
  static final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static final FirebaseApp app = FirebaseApp(name: '[DEFAULT]');
  static final FirebaseDatabase firebaseDatabase = FirebaseDatabase(app: app);

  static final GoogleSignIn googleSignIn = GoogleSignIn();

  static DatabaseReference generalUserRef;
  static DatabaseReference passwordsRef;
  static DatabaseReference masterPasswordRef;
  static DatabaseReference settingsRef;

  static bool get isSignedIn => firebaseUser != null;

  static Future<void> initialize() async {
    firebaseUser = await firebaseAuth.currentUser();
    if (isSignedIn) _initializeReferences();
    if (await internetConnectionAvailable() &&
        Prefs.allowRetrievingCloudData &&
        isSignedIn) {
      await loadSettings();
      await retrievePasswords();
    } else if (isSignedIn)
      await signOut();
    else
      Prefs.allowRetrievingCloudData = false;
    print(await internetConnectionAvailable() ? 'Internet!' : 'No Internet!');
  }

  static void _initializeReferences() {
    if (!isSignedIn)
      throw 'User must be signed in for initializing the references';
    generalUserRef =
        firebaseDatabase.reference().child('users').child(firebaseUser.uid);
    passwordsRef = generalUserRef.child('passwords');
    passwordsRef.onValue.listen(
        (event) => getPasswordsFromFirebaseEventSnapshot(event.snapshot));
    masterPasswordRef = generalUserRef.child('encryptedMasterPassword');
    settingsRef = generalUserRef.child('settings');
  }

  static Future<void> signInWithGoogle() async {
    final googleAccount = await googleSignIn.signIn();
    final googleAuthentication = await googleAccount.authentication;
    final authResult = await firebaseAuth.signInWithCredential(
      GoogleAuthProvider.getCredential(
        accessToken: googleAuthentication.accessToken,
        idToken: googleAuthentication.idToken,
      ),
    );
    final user = authResult.user;
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);
    firebaseUser = await firebaseAuth.currentUser();
    _initializeReferences();
  }

  static Future<void> signOut() async {
    await firebaseAuth.signOut();
    firebaseUser = null;
    generalUserRef = null;
    passwordsRef = null;
    settingsRef = null;
    masterPasswordRef = null;
    Prefs.allowRetrievingCloudData = false;
  }

  static Future<void> savePasswords(List<Password> passwords) async {
    if (passwordsRef == null) _initializeReferences();
    List<String> tempStringList = [];
    for (Password password in passwords) tempStringList.add(password.toJson());
    await passwordsRef.set(tempStringList);
    await masterPasswordRef
        .set(Prefs.preferences.getString('encrypted_master_password'));
  }

  static Future<bool> hasExistingData() async {
    bool b = false;
    await masterPasswordRef
        .once()
        .then((snapshot) => b = snapshot.value != null);
    return b;
  }

  static Future<void> retrievePasswords() async {
    if (!Prefs.allowRetrievingCloudData) return;
    await passwordsRef
        .once()
        .then((snapshot) => getPasswordsFromFirebaseEventSnapshot(snapshot));
  }

  static Future<String> storedMasterPassword() async {
    String s;
    await masterPasswordRef
        .once()
        .then((snapshot) => s = snapshot.value.toString().trim());
    return s;
  }

  static Future<void> saveSettings() async =>
      await settingsRef.set(Settings.toJson());

  static Future<void> loadSettings() async {
    if (!Prefs.allowRetrievingCloudData) return;
    await settingsRef.once().then(
        (snapshot) => Settings.fromJson(snapshot.value.toString()).apply());
  }

  static Future<void> deleteOnlineData() async {
    if (generalUserRef == null) _initializeReferences();
    await generalUserRef.set(null);
  }
}
