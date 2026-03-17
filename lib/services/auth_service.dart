import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (_) {
      // In widget tests Firebase may not be initialized.
      return null;
    }
  }

  static Future<void> ensureAnonymousSignIn() async {
    if (_auth.currentUser != null) return;
    await _auth.signInAnonymously();
  }

  static Future<User?> signInWithGoogleAndLinkAnonymous() async {
    await ensureAnonymousSignIn();
    final existingUser = _auth.currentUser;

    await _googleSignIn.initialize();
    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    if (existingUser != null && existingUser.isAnonymous) {
      try {
        final linked = await existingUser.linkWithCredential(credential);
        return linked.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use' || e.code == 'provider-already-linked') {
          final signedIn = await _auth.signInWithCredential(credential);
          return signedIn.user;
        }
        rethrow;
      }
    }

    final signedIn = await _auth.signInWithCredential(credential);
    return signedIn.user;
  }

  static Future<void> signOutToGuest() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    await _auth.signInAnonymously();
  }
}
