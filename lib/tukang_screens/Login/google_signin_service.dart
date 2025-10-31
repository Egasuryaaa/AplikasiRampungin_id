import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart'; // Tambahkan dependency ini ke pubspec.yaml
import 'package:rampungin_id_userside/tukang_screens/form/form_tukang.dart';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final Logger _logger = Logger(); // Logger untuk mengganti print

  // Sign in with Google
  static Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      // Trigger Google Sign In flow
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount == null) {
        // User cancelled the sign-in
        return null;
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      // Create credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      // Sign in to Firebase with Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Get user details
      final User? user = userCredential.user;

      return user;
    } catch (error) {
      _logger.e("Google Sign-In Error: $error"); // Ganti print dengan logger

      // Check if context is still mounted before using it
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

  // Sign out from Google
  static Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _logger.i("User signed out successfully");
    } catch (error) {
      _logger.e("Sign out error: $error");
    }
  }

  // Check if user is already signed in
  static Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}

// Function to handle Google Sign-In button press
Future<void> handleGoogleSignIn(BuildContext context) async {
  try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Sign in with Google
    final User? user = await GoogleSignInService.signInWithGoogle(context);

    // Check if context is still mounted before using Navigator
    if (!context.mounted) return;

    // Close loading indicator
    Navigator.of(context).pop();

    if (user != null) {
      // Successfully signed in - use logger instead of print
      Logger().i("Google Sign-In Successful: ${user.displayName}");
      Logger().i("Email: ${user.email}");
      Logger().i("UID: ${user.uid}");

      // Check mounted again before navigation
      if (!context.mounted) return;

      // Navigate to FormTukang screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FormTukang()),
      );
    } else {
      // Sign-in was cancelled
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Google Sign-In was cancelled"),
          backgroundColor: Colors.orange,
        ),
      );
    }
  } catch (error) {
    // Check if context is still mounted
    if (!context.mounted) return;

    // Close loading indicator if still showing
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $error"), backgroundColor: Colors.red),
    );

    // Use logger instead of print
    Logger().e("HandleGoogleSignIn Error: $error");
  }
}
