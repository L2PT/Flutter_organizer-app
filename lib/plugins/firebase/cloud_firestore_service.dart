import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/auth/authuser.dart';

class CloudFirestoreService {

  final  _cloudFirestore;

  CloudFirestoreService({cf.FirebaseFirestore cloudFirestore})
      : _cloudFirestore = cloudFirestore ??  cf.FirebaseFirestore.instance;

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
    return _firebaseAuth.onAuthStateChanged.map(_userFromFirebase);
  }

  Future<AuthUser> signInWithEmailAndPassword(String email, String password) async {
    final authResult = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return _userFromFirebase(authResult.user);
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<AuthUser> currentUser() async {
    final user = await _firebaseAuth.currentUser;
    return _userFromFirebase(user);
  }

  bool isSupervisor() {
    //TODO
  }
}
