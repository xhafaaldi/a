import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  String version = "";
  String buildNumber = "";

  @override
  Widget build(BuildContext context) {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        version = packageInfo.version;
        buildNumber = packageInfo.buildNumber;
      });
    });

    return Scaffold(
      backgroundColor: Color(0xff2436db),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xff2436db),
        title: Row(
          children: [
            IconButton(onPressed: () {
              Navigator.pop(context);
            }, icon: Icon(Icons.arrow_back,color: Colors.white,)),
            SizedBox(width: 10,),
            Text("About Us",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),),
          ],
        ),
        leadingWidth: 0,
        toolbarHeight: 60,
        leading: Container(),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20),)
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Welcome to iSave, your comprehensive financial ally designed to simplify the complexities of managing your money. With intuitive features for tracking expenses, budgeting, and setting financial goals, iSave empowers you to take control of your financial journey. Seamlessly manage multiple accounts and wallets, collaborate with family and friends, and enjoy the convenience of QR code transactions. Unleash the power of financial freedom with iSave—where innovation meets simplicity, providing you the tools you need to achieve your financial aspirations with confidence."),
                const SizedBox(height: 10),
                Wrap(
                  children: [
                    TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        backgroundColor: MaterialStateProperty.all(Colors.black12)
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        launchUrl(Uri.parse("https://i-Save.app/"));
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.globe),
                          SizedBox(width: 10),
                          Text("Website")
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        backgroundColor: MaterialStateProperty.all(Colors.black12)
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        launchUrl(Uri.parse(
                          "https://idev.al/isave-privacy-policy/"
                        ));
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.news),
                          SizedBox(width: 10),
                          Text("Privacy Policy")
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        backgroundColor: MaterialStateProperty.all(Colors.black12)
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        launchUrl(Uri.parse("https://idev.al/contact/"));
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.mail),
                          SizedBox(width: 10),
                          Text("Contact")
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black),
                        children: [
                          const TextSpan(text: "Version ", style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: version),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black),
                        children: [
                          const TextSpan(text: "Build Number ", style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: buildNumber),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black),
                        children: [
                          const TextSpan(text: "© ", style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: "iDev, ${buildDate()} | Created by Emir S."),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String buildDate() {
    int year = DateTime.now().year;

    if (year == 2023) {
      return "2023";
    } else {
      return "2023 - $year";
    }
  }
}