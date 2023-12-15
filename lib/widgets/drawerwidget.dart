import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:isave/pages/main/about_us_page.dart';
import 'package:isave/pages/main/bar_pages/search_page.dart';
import 'package:isave/pages/main/settings/settings_page.dart';

import '../pages/main/bar_pages/premium_page.dart';
import '../pages/main/bar_pages/transactions_list_page.dart';

getAppDrawer(BuildContext context){
  User user = FirebaseAuth.instance.currentUser!;

  return Drawer(
    backgroundColor: Color(0xff2436db),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 25,),
              buildPfp(user.photoURL),
              const SizedBox(width: 10),
              Text(
                  user.displayName!, style: const TextStyle(fontSize: 22,color: Colors.white))
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20),)
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.workspace_premium),
                  title: const Text("Premium"),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(99),
                          bottomRight: Radius.circular(99)
                      )
                  ),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    Get.to(() => const PremiumPage());
                  },
                ),
                ListTile(
                  leading: const Icon(CupertinoIcons.list_bullet),
                  title: const Text("Transactions"),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    Get.to(() => const TransactionsListPage());
                  },
                ),
                ListTile(
                  leading: const Icon(CupertinoIcons.search),
                  title: const Text("Search"),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    Get.to(() => const SearchPage());
                  },
                ),
                ListTile(
                  leading: const Icon(CupertinoIcons.gear_solid),
                  title: const Text("Settings"),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    Get.to(() => const SettingsPage());
                  },
                ),
                ListTile(
                  leading: const Icon(CupertinoIcons.info),
                  title: const Text("About Us"),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    Get.to(() => const AboutUsPage());
                  },
                ),
                ListTile(
                  leading: const Icon(CupertinoIcons.star),
                  title: const Text("Rate us"),
                  onTap: () async {
                    HapticFeedback.selectionClick();

                    final InAppReview inAppReview = InAppReview.instance;

                    if (await inAppReview.isAvailable()) {
                      inAppReview.requestReview();
                    }
                  },
                ),
              ],
            ),
          ),
        )
      ],
    ),
  );
}


Widget buildPfp(String? photoURL) {
  if (photoURL == null) {
    return const Icon(Icons.account_circle, size: 100,color: Colors.white,);
  } else {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(99)),
      child: SizedBox(
          height: 35,
          width: 35,
          child: CachedNetworkImage(imageUrl: photoURL)
      ),
    );
  }
}