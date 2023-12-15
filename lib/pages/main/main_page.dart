import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/pages/main/bar_pages/premium_page.dart';
import 'package:isave/pages/main/bar_pages/transactions_list_page.dart';
import 'package:isave/pages/main/statistics/statistics_page.dart';
import 'package:isave/pages/main/transaction/add_transaction.dart';
import 'package:isave/pages/main/transaction/transactions_page.dart';
import 'package:isave/pages/main/calendar/calendar_page.dart';
import 'package:isave/pages/main/settings/settings_page.dart';
import 'package:isave/pages/main/wallet/wallet_page.dart';
import 'package:isave/pages/main/bar_pages/search_page.dart';
import 'package:isave/globals.dart' as globals;
import 'package:in_app_review/in_app_review.dart';
import 'package:isave/pages/main/about_us_page.dart';

import 'package:get/get.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  InterstitialAd? interstitialAd;
  int selectedBottomIndex = 0;

  void _onBottomItemTapped(int index) {
    if (!globals.isPremium!) {
      if (Random().nextInt(1) == 0) {
        interstitialAd?.show();
      }
    }
    setState(() {
      selectedBottomIndex = index;
    });
  }

  Future<void> _loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: "ca-app-pub-1532914256578614/2346968915",
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {

            },
          );

          setState(() {
            interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          debugPrint("Failed to load an interstitial ad: ${err.message}");
        },
      ),
    );
  }

  @override
  void initState() {
    _loadInterstitialAd();
    super.initState();
  }

  @override
  void dispose() {
    interstitialAd?.dispose();
    super.dispose();
  }

  List<Widget> pages = const [
    TransactionsPage(),
    CalendarPage(),
    AddTransaction(),
    StatisticsPage(),
    WalletPage()
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        child: pages.elementAt(selectedBottomIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.equal_square_fill),
            label: "Home",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: "Calendar",
          ),
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                  color: const Color(0xff4376FE),
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xff4376FE),
                        spreadRadius: 0.1,
                        blurRadius: 5,
                        offset: Offset(0.0, 0)
                    )
                  ]
              ),
              padding: const EdgeInsets.all(5),
              child: const Icon(
                  CupertinoIcons.add, color: Colors.white, size: 27),
            ),
            label: "",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.line_axis_outlined),
            label: "Statistics",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: "Wallet",
          ),
        ],
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedIconTheme: const IconThemeData(
            color: Color(0xff4376FE)
        ),
        currentIndex: selectedBottomIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.black87,
        onTap: _onBottomItemTapped,
      ),
    );
  }

}