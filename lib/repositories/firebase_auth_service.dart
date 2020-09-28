import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:venturiautospurghi/web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/auth/authuser.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthService({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn();

  AuthUser _userFromFirebase(User user) {
    if (user == null) {
      return null;
    }
    return AuthUser (
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  Stream<AuthUser> get onAuthStateChanged {
    return _firebaseAuth.idTokenChanges().map(_userFromFirebase);
  }

  Future<AuthUser> signInWithEmailAndPassword(String email, String password) async {
    final authResult = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    if(kIsWeb)WriteCookieJarJs(COOKIE_PATH, authResult.user.refreshToken);
    return _userFromFirebase(authResult.user);
  }

  Future<AuthUser> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final authResult = await _firebaseAuth.signInWithCredential(credential);
    return _userFromFirebase(authResult.user);
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<AuthUser> currentUser() async {
    final user = await _firebaseAuth.currentUser;
    return _userFromFirebase(user);
  }

  void sendPasswordReset(String email) {
    _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  void sendPhoneVerificationCode(String email) {
    _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<UserCredential> createAccount(String email, String passwordNewUsers, {String displayName}) async {
    FirebaseApp app = Firebase.apps.firstWhere((element) => element.name == 'Registration', orElse: () => null)??await Firebase.initializeApp(name: 'Registration',options: Firebase.app().options);
    return FirebaseAuth.instanceFor(app: app).createUserWithEmailAndPassword(email: email, password: passwordNewUsers);
  }

  void signInWithToken( token) {
    _firebaseAuth.signInWithCustomToken(token);
  }
}
