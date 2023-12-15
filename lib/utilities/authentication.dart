import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:isave/utilities/models/enums/email_sign_in_status.dart';
import 'package:isave/utilities/utilities.dart';

class Authentication {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<bool> signInWithApple() async {
    try {
      final appleProvider = AppleAuthProvider();
      UserCredential credential = await auth.signInWithProvider(appleProvider);
      Utilities.setString(key: "email", value: credential.user!.email!);
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      await auth.signInWithCredential(
        GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        ),
      );
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  Future<EmailSignInStatus> signInWithEmail(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return EmailSignInStatus.successLoggedIn;
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-email") {
        return EmailSignInStatus.invalidEmail;
      } else if (e.code == "user-disabled") {
        return EmailSignInStatus.userDisabled;
      } else if (e.code == "user-not-found") {
        try {
          await auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          return EmailSignInStatus.successSignedIn;
        } on FirebaseAuthException catch (e) {
          if (e.code == "email-already-in-use") {
            return EmailSignInStatus.emailAlreadyInUse;
          } else if (e.code == "invalid-email") {
            return EmailSignInStatus.invalidEmail;
          } else if (e.code == "weak-password") {
            return EmailSignInStatus.weakPassword;
          } else {
            debugPrint(e.code);
            return EmailSignInStatus.unknownError;
          }
        } catch (e) {
          debugPrint(e.toString());
          return EmailSignInStatus.unknownError;
        }
      } else if (e.code == "wrong-password" || e.code == "INVALID_LOGIN_CREDENTIALS"
                || e.code == "invalid-credential") {
        return EmailSignInStatus.wrongPassword;
      } else {
        debugPrint(e.code);
        return EmailSignInStatus.unknownError;
      }
    } catch (e) {
      debugPrint(e.toString());
      return EmailSignInStatus.unknownError;
    }
  }

  Future<bool> signInWithBiometrics(LocalAuthentication localAuth) async {
    try {
      final authenticated = await localAuth.authenticate(
        localizedReason: 'Authenticate to access your account',
        biometricOnly: true,
      );
      if (authenticated) {
        // Use the method you want for biometric sign-in (e.g., Apple sign-in)
        return await signInWithApple();
      } else {
        return false;
      }
    } catch (e) {
      print('Error during biometric authentication: $e');
      return false;
    }
  }
}