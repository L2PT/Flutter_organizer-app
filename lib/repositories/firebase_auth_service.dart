import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import '../models/auth/authuser.dart';

class FirebaseAuthService {
  final fb.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthService({fb.FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn();

  AuthUser _userFromFirebase(fb.User user) {
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
    return _userFromFirebase(authResult.user);
  }

  Future<AuthUser> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser.authentication;
    final credential = fb.GoogleAuthProvider.getCredential(
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

  Future<AuthUser> createAccount(String text, String passwordNewUsers, {String displayName}) {
    //TODO
  }

  void signInWithToken( token) {
    _firebaseAuth.signInWithCustomToken(token);
  }
}
