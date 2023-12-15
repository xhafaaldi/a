// StartPage.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/pages/welcome/add_account.dart';
import 'package:isave/pages/welcome/sign_in_with_email.dart';
import 'package:isave/utilities/authentication.dart';
import 'package:isave/utilities/utilities.dart';
import 'package:local_auth/local_auth.dart';

import 'package:get/get.dart';

class StartPage extends StatelessWidget {
  final Authentication auth = Authentication();
  final LocalAuthentication localAuth = LocalAuthentication();

  StartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/signup.png", height: 210),
            SizedBox(height: 20),
            Text(
              "Sign Up",
              style: TextStyle(
                  fontSize: 30,
                  color: Color(0xFF2F80ED)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "to save all of your incomes and expenses with ease.",
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (Platform.isIOS)
                      signInButton(
                        context,
                        "Sign in with Apple",
                        const Icon(Icons.apple, size: 25),
                        Colors.black, onTap: () async {
                          Utilities.showLoadingDialog(context);
                          bool result = await auth.signInWithApple().then((value) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            return value;
                          });

                          if (result) {
                            Get.to(() => const AddAccount());
                          } else {
                            Utilities.showSnackbar(
                              isSuccess: false,
                              title: "Error!",
                              description:
                              "We couldn't sign you in! Please check that all of the information you provided is correct and valid");
                          }
                        }),
                    if (Platform.isAndroid)
                      signInButton(
                          context,
                          "Sign in with Google",
                          const Icon(Icons.google, size: 25),
                          Colors.red, onTap: () async {
                        Utilities.showLoadingDialog(context);
                        bool result = await auth.signInWithGoogle().then((value) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          return value;
                        });

                        if (result) {
                          Get.to(() => const AddAccount());
                        } else {
                          Utilities.showSnackbar(
                              isSuccess: false,
                              title: "Error!",
                              description:
                              "We couldn't sign you in! Please check that all of the information you provided is correct and valid");
                        }
                      }),
                    const SizedBox(height: 10),
                    signInButton(
                        context,
                        "Sign in with E-mail",
                        const Icon(Icons.mail, size: 25),
                        Colors.blueAccent, onTap: () async {
                      Get.to(() => const SignInWithEmail());
                    }),
                    const SizedBox(height: 10),
                    // Add the following code to show biometric authentication option
                    if (await localAuth.canCheckBiometrics)
                      signInButton(
                        context,
                        "Sign in with Biometrics",
                        const Icon(Icons.fingerprint, size: 25),
                        Colors.green,
                        onTap: () async {
                          Utilities.showLoadingDialog(context);
                          bool result = await auth.signInWithBiometrics(localAuth);
                          Navigator.pop(context); // Close loading dialog
                          if (result) {
                            Get.to(() => const AddAccount());
                          } else {
                            Utilities.showSnackbar(
                              isSuccess: false,
                              title: "Error!",
                              description: "Biometric authentication failed.",
                            );
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget signInButton(
      BuildContext context, String label, Icon icon, Color color,
      {required Function() onTap}) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.3,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: 0.1,
            blurRadius: 15,
            offset: Offset(0.0, 3),
          )
        ],
      ),
      child: TextButton.icon(
        onPressed: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(color),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          textStyle: MaterialStateProperty.all(
              const TextStyle(fontWeight: FontWeight.w700)),
          padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 15)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          elevation: MaterialStateProperty.all(0),
        ),
        icon: icon,
        label: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}