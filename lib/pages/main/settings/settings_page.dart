import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/pages/main/settings/change_account/change_account.dart';
import 'package:isave/pages/main/settings/transaction_templates/transaction_templates_page.dart';
import 'package:isave/utilities/utilities.dart';
import 'package:isave/pages/main/settings/change_categories/change_categories.dart';
import 'package:isave/globals.dart' as globals;

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    BannerAd(
      adUnitId: "ca-app-pub-1532914256578614/7384259908",
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint("Failed to load a banner ad: ${err.message}");
          ad.dispose();
        },
      ),
    ).load();
    super.initState();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
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
            Text("Settings",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),),
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
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Utilities.displayBanner(_bannerAd),
                  ),
                  const SizedBox(height: 5),
                  const Text("Management", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15,),
                  const Divider(thickness: 2),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Get.to(() => const ChangeAccount());
                    },
                    behavior: HitTestBehavior.translucent,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 10),
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(CupertinoIcons.person_3, size: 28),
                            SizedBox(width: 10),
                            Text("Accounts", style: TextStyle(fontSize: 17)),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Icon(CupertinoIcons.forward),
                              )
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 10),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Get.to(() => const TransactionTemplatesPage());
                    },
                    behavior: HitTestBehavior.translucent,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(CupertinoIcons.rectangle_paperclip, size: 27),
                            SizedBox(width: 10),
                            Text("Transaction Templates", style: TextStyle(fontSize: 17)),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Icon(CupertinoIcons.forward),
                              )
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 10),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Get.to(() => const ChangeCategories());
                    },
                    behavior: HitTestBehavior.translucent,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(CupertinoIcons.book, size: 26),
                            SizedBox(width: 10),
                            Text("Categories", style: TextStyle(fontSize: 17)),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Icon(CupertinoIcons.forward),
                              )
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text("Go Premium", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  const Divider(thickness: 2, height: 6),
                  GestureDetector(
                    onTap: () {},
                    behavior: HitTestBehavior.translucent,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(CupertinoIcons.device_phone_portrait, size: 25),
                            SizedBox(width: 10),
                            Text("Startup Menu", style: TextStyle(fontSize: 17)),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Icon(CupertinoIcons.forward),
                              )
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 10),
                  GestureDetector(
                    onTap: () {},
                    behavior: HitTestBehavior.translucent,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 7, bottom: 7),
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(CupertinoIcons.padlock, size: 27),
                            SizedBox(width: 10),
                            Text("Password", style: TextStyle(fontSize: 17)),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Icon(CupertinoIcons.forward),
                              )
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(CupertinoIcons.moon, size: 27),
                        const SizedBox(width: 10),
                        const Text("Dark Mode", style: TextStyle(fontSize: 17)),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Switch(
                              value: darkMode,
                              onChanged: (bool value) async {
                                if (globals.isPremium!) {
                                  setState(() {
                                    darkMode = value;
                                  });
                                  await Utilities.setString(
                                    key: "selectedBrightness",
                                    value: value ? "dark" : "light"
                                  );
                                } else {
                                  setState(() {
                                    darkMode = false;
                                  });
                                  Utilities.showSnackbar(
                                    isSuccess: false,
                                    title: "Error!",
                                    description: "You need to purchase premium for this feature to work!"
                                  );
                                }
                              }
                            ),
                          )
                        )
                      ],
                    ),
                  ),
                  const Divider(),
                  /*
                  const SizedBox(height: 10),
                  const Text("Other", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(thickness: 2),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            launchUrl(Uri.parse(
                              "https://ktwapps-ad94a.firebaseapp.com/privacy_policy.html"
                            ));
                          },
                          behavior: HitTestBehavior.translucent,
                          child: const Padding(
                            padding: EdgeInsets.only(top: 5, bottom: 10),
                            child: SizedBox(
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(CupertinoIcons.news, size: 27),
                                  SizedBox(width: 10),
                                  Text("Privacy Policy", style: TextStyle(fontSize: 17)),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Icon(Icons.open_in_browser),
                                    )
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 10),
                      ],
                    ),
                  ),
                   */
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
