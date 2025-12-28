import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign in with email and password
  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      // Store additional user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'phone': phone,
        'role': 'customer', // Default role
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        return false;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Check if this is a new user, if so, create user document
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName ?? '',
          'phone': '',
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } catch (e) {
      print('Google Sign-In Error: $e');
      throw 'Failed to sign in with Google. Please try again.';
    }
  }

  /// Sign in as Guest (Anonymous)
  Future<bool> signInAsGuest() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      
      // Create a guest user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': null,
        'name': 'Guest',
        'phone': '',
        'role': 'guest', // Special guest role
        'isAnonymous': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } on FirebaseAuthException catch (e) {
      print('Guest Sign-In Firebase Error: ${e.code} - ${e.message}');
      if (e.code == 'admin-restricted-operation') {
        throw 'Anonymous sign-in is disabled. Please enable it in Firebase Console:\n'
            'Authentication → Sign-in method → Anonymous → Enable';
      }
      throw 'Failed to continue as guest. Please try again.';
    } catch (e) {
      print('Guest Sign-In Error: $e');
      throw 'Failed to continue as guest. Please try again.';
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
