import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/globals.dart' as globals;
import 'package:isave/pages/main/wallet/wallet_adding_page.dart';
import 'package:isave/utilities/models/budget.dart';
import 'package:isave/utilities/models/wallet.dart';
import 'package:isave/utilities/utilities.dart';
import 'package:isave/widgets/drawerwidget.dart';
import 'package:isave/widgets/wallet/budget_card.dart';
import 'package:isave/widgets/wallet/goal_card.dart';
import 'package:isave/widgets/wallet/wallet_card.dart';
import 'package:isave/pages/main/wallet/goal/goal_adding_page.dart';
import 'package:isave/pages/main/wallet/budget/budget_adding_page.dart';
import 'package:isave/pages/main/wallet/debt/debt_adding_page.dart';
import 'package:isave/widgets/wallet/debt_card.dart';

import 'package:dotted_border/dotted_border.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../widgets/isave_card.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  BannerAd? _bannerAd;
  int position = 0;

  List<Widget> walletsList() {
    List<Widget> walletsWidget = [];

    for (Wallet wallet in globals.currentAccount!.wallets) {
      walletsWidget.add(WalletCard(wallet: wallet));
    }

    return walletsWidget.reversed.toList();
  }

  @override
  void initState() {
    BannerAd(
      adUnitId: "ca-app-pub-1532914256578614/8613581099",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2436db),
      drawer: getAppDrawer(context),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xff2436db),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: Image.asset('assets/icon1.png', ),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                    );
                  },
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Get.to(() => const WalletAddingPage())!
                        .then((_) => setState(() {}));
                  },
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    color: Colors.white,
                    radius: const Radius.circular(5),
                    padding: const EdgeInsets.all(3),
                    child: const Icon(CupertinoIcons.add, size: 20,color: Colors.white),
                  ),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 5),
              child: Column(
                children: [
                  CarouselSlider(
                    items: walletsList(),
                    options: CarouselOptions(
                        initialPage: 0,
                        onPageChanged: (int page, _) {
                          setState(() {
                            position = page;
                          });
                        },
                        aspectRatio: 2.25,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: false),
                  ),
                  const SizedBox(height: 5),
                  DotsIndicator(
                      position: position,
                      decorator: DotsDecorator(
                        activeColor: Color(0xff8de0fb)
                      ),
                      dotsCount: globals.currentAccount!.wallets.length),
                ],
              ),
            ),
          ],
        ),
        leadingWidth: 0,
        toolbarHeight: 260,
        leading: Container(),
      ),
      body: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20),)
        ),
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                    alignment: Alignment.center,
                    child: StatefulBuilder(
                        builder: (_, __) =>
                            Utilities.displayBanner(_bannerAd))),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Budgets",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500)),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Get.to(() => const BudgetAddingPage())!
                            .then((_) => setState(() {}));
                      },
                      // child: DottedBorder(
                      //   borderType: BorderType.RRect,
                      //   radius: const Radius.circular(5),
                      //   padding: const EdgeInsets.all(3),
                      //   child: const Icon(CupertinoIcons.add, size: 20),
                      // ),
                      child: const Icon(CupertinoIcons.add, size: 22,color: Color(0xff2436db)),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ISaveCard(title: "", body: Wrap(
                  children: [
                    buildBudgetsWidget(),
                  ],
                ), onTap: () {},),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Goals",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500)),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Get.to(() => const GoalAddingPage())!
                            .then((_) => setState(() {}));
                      },
                      // child: DottedBorder(
                      //   borderType: BorderType.RRect,
                      //   radius: const Radius.circular(5),
                      //   padding: const EdgeInsets.all(3),
                      //   child: const Icon(CupertinoIcons.add, size: 20),
                      // ),
                      child: const Icon(CupertinoIcons.add, size: 22,color: Color(0xff2436db)),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ISaveCard(title: "", body: Wrap(
                  children: [
                    buildGoalsWidget(),
                  ],
                ), onTap: () {},),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Debts",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500)),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Get.to(() => const DebtAddingPage())!
                            .then((_) => setState(() {}));
                      },
                      // child: DottedBorder(
                      //   borderType: BorderType.RRect,
                      //   radius: const Radius.circular(5),
                      //   padding: const EdgeInsets.all(3),
                      //   child: const Icon(CupertinoIcons.add, size: 20),
                      // ),
                      child: const Icon(CupertinoIcons.add, size: 22,color: Color(0xff2436db)),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ISaveCard(title: "", body: Wrap(
                  children: [
                    buildDebtsWidget()
                  ],
                ), onTap: () {},),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGoalsWidget() {
    if (globals.currentAccount!.goals.isNotEmpty) {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: globals.currentAccount!.goals.length,
        itemBuilder: (BuildContext context, int index) {
          return GoalCard(goal: globals.currentAccount!.goals[index]);
        },
      );
    } else {
      return const Text("Nothing yet!");
    }
  }

  Widget buildBudgetsWidget() {
    List<Budget> budgets = globals.currentAccount!.budgets;

    if (budgets.isNotEmpty) {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: budgets.length,
        itemBuilder: (BuildContext context, int index) {
          return BudgetCard(budget: budgets[index]);
        },
      );
    } else {
      return const Text("Nothing yet!", style: TextStyle(fontSize: 15));
    }
  }

  Widget buildDebtsWidget() {
    if (globals.currentAccount!.debts.isNotEmpty) {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: globals.currentAccount!.debts.length,
        itemBuilder: (BuildContext context, int index) {
          return DebtCard(debt: globals.currentAccount!.debts[index]);
        },
      );
    } else {
      return const Text("Nothing yet!");
    }
  }
}
