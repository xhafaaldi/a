import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/pages/welcome/add_account.dart';
import 'package:isave/utilities/models/enums/email_sign_in_status.dart';
import 'package:isave/utilities/utilities.dart';
import 'package:isave/widgets/isave_textfield.dart';
import 'package:isave/globals.dart' as globals;
import 'package:isave/utilities/authentication.dart';
import 'package:isave/pages/main/main_page.dart';

import 'package:get/get.dart';

class SignInWithEmail extends StatefulWidget {
  const SignInWithEmail({super.key});

  @override
  State<SignInWithEmail> createState() => _SignInWithEmailState();
}

class _SignInWithEmailState extends State<SignInWithEmail> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Authentication auth = Authentication();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          height: double.infinity,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/signup.png", height: 180),
              SizedBox(height: 20),
              Text(
                "Sign in with E-mail",
                style: TextStyle( fontSize: 25,fontWeight: FontWeight.bold,color: Color(0xFF2F80ED)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ISaveTextField(
                labelText: "E-mail",
                hintText: "steve@apple.com",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 25),
              ISaveTextField(
                labelText: "Password",
                hintText: "",
                controller: passwordController,
                keyboardType: TextInputType.text,
                obscureText: true,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    HapticFeedback.selectionClick();

                    if (passwordController.text.isEmpty ||
                        emailController.text.isEmpty) {
                      Utilities.showSnackbar(
                          isSuccess: false,
                          title: "Error",
                          description: "Please provide everything required!");
                      return;
                    }

                    Utilities.showLoadingDialog(context);

                    EmailSignInStatus status = await auth.signInWithEmail(
                        emailController.text, passwordController.text);

                    if (mounted) {
                      Navigator.pop(context);
                    }

                    if (status == EmailSignInStatus.successSignedIn) {
                      Get.to(() => const AddAccount());
                    } else if (status == EmailSignInStatus.successLoggedIn) {
                      if (mounted) {
                        Utilities.showLoadingDialog(context);
                      }
                      Utilities.getUserFromFirestore().then((_) {
                        Navigator.pop(context);
                        Get.to(() => const MainPage());
                      });
                    } else {
                      Utilities.showSnackbar(
                          isSuccess: false,
                          title: "Error",
                          description: status.message);
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(const Color(0xFF2F80ED)),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    textStyle: MaterialStateProperty.all(const TextStyle(fontWeight: FontWeight.w700)),
                    padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 15)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    elevation: MaterialStateProperty.all(0),
                  ),
                  child: const Text("Sign In",style: TextStyle(fontSize: 16),),
                ),
              )
            ],
          )),
    );
  }
}
