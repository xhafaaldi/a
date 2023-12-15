import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:isave/globals.dart' as globals;
import 'package:isave/utilities/models/transaction.dart';

import 'package:intl/intl.dart';
import 'package:isave/utilities/utilities.dart';
import 'package:isave/widgets/drawerwidget.dart';

import '../../../widgets/isave_card.dart';
import '../../../widgets/transaction/transaction_card.dart';

class TransactionsListPage extends StatefulWidget {
  const TransactionsListPage({super.key});

  @override
  State<TransactionsListPage> createState() => _TransactionsListPageState();
}

class _TransactionsListPageState extends State<TransactionsListPage> {
  final List<Transaction> transactions =
      globals.currentAccount!.transactions.reversed.toList();
  late final List<MapEntry<String, List<Transaction>>> groupedTransactions;

  DateTime currentDateTime = DateTime.now();
  String currentDate = DateFormat("MMMM yyyy").format(DateTime.now());
  List<Transaction> selectedMonthData = [];
  BannerAd? _bannerAd;

  @override
  void initState() {
    groupedTransactions = groupBy(
        transactions,
        (Transaction transaction) =>
            DateFormat("MMMM yyyy").format(transaction.date)).entries.toList();

    if (groupedTransactions.isNotEmpty) {
      selectedMonthData =
          groupedTransactions.firstWhere((e) => e.key == currentDate).value;
    }

    BannerAd(
      adUnitId: "ca-app-pub-1532914256578614/6186690319",
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xff2436db),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(onPressed: () {
                  Navigator.pop(context);
                }, icon: Icon(Icons.arrow_back,color: Colors.white,)),
                SizedBox(width: 10,),
                Text("Transactions",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();

                    setState(() {
                      if ((currentDateTime.month - 1) == 0) {
                        currentDateTime = DateTime(currentDateTime.year - 1, 12);
                      } else {
                        currentDateTime =
                            DateTime(currentDateTime.year, currentDateTime.month - 1);
                      }
                      currentDate = DateFormat("MMMM yyyy").format(currentDateTime);
                      if (globals.currentAccount!.statisticsByMonth[currentDate] !=
                          null) {
                        if (groupedTransactions.isNotEmpty) {
                          selectedMonthData = groupedTransactions
                              .firstWhere((e) => e.key == currentDate)
                              .value;
                        }
                      } else {
                        selectedMonthData = [];
                      }
                    });
                  },
                  icon: const Icon(CupertinoIcons.back,color: Colors.white,),
                ),
                Expanded(child: Center(child: Text(currentDate, style: const TextStyle(fontSize: 17,color: Colors.white)))),
                IconButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if ((currentDateTime.month + 1) == 13) {
                        currentDateTime = DateTime(currentDateTime.year + 1, 1);
                      } else {
                        currentDateTime = DateTime(
                            currentDateTime.year, currentDateTime.month + 1);
                      }
                      currentDate = DateFormat("MMMM yyyy").format(currentDateTime);
                      if (globals.currentAccount!.statisticsByMonth[currentDate] !=
                          null) {
                        if (groupedTransactions.isNotEmpty) {
                          selectedMonthData = groupedTransactions
                              .firstWhere((e) => e.key == currentDate)
                              .value;
                        }
                      } else {
                        selectedMonthData = [];
                      }
                    });
                  },
                  icon: const Icon(CupertinoIcons.forward,color: Colors.white,),
                ),
              ],
            ),
            SizedBox(height: 20,),
          ],
        ),
        leadingWidth: 0,
        toolbarHeight: 120,
        leading: Container(),
      ),
      body: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20),)
          ),
          height: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: buildCurrentMonthTransactions()),
    );
  }

  Widget buildCurrentMonthTransactions() {
    int length = selectedMonthData.length;

    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          mainAxisAlignment:  MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Utilities.displayBanner(_bannerAd),
            const SizedBox(height: 5),
            Text("$length Transactions",style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 22)),
            ListView.builder(
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 10),
              itemCount: length,
              itemBuilder: (BuildContext context, int index) {
                return TransactionCard(transaction: selectedMonthData[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}
