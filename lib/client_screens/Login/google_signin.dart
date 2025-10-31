import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final Logger _logger = Logger();

  // Sign in with Google
  static Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount == null) return null;

      final googleAuth = await googleSignInAccount.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      return user;
    } catch (error) {
      _logger.e("Google Sign-In Error: $error");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error during Google Sign-In: $error"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  // Sign out
  static Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _logger.i("User signed out successfully");
    } catch (error) {
      _logger.e("Sign out error: $error");
    }
  }

  static Future<bool> isSignedIn() async => await _googleSignIn.isSignedIn();

  static User? getCurrentUser() => _auth.currentUser;
}

// Function to handle Google Sign-In button press
Future<void> handleGoogleSignIn(BuildContext context) async {
  final logger = Logger();

  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final user = await GoogleSignInService.signInWithGoogle(context);

    if (!context.mounted) return;
    Navigator.of(context).pop();

    if (user != null) {
      logger.i("Google Sign-In Successful: ${user.displayName}");
      logger.i("Email: ${user.email}");
      logger.i("UID: ${user.uid}");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Google Sign-In was cancelled"),
          backgroundColor: Colors.orange,
        ),
      );
    }
  } catch (error) {
    if (!context.mounted) return;
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $error"),
        backgroundColor: Colors.red,
      ),
    );

    logger.e("HandleGoogleSignIn Error: $error");
  }
}
