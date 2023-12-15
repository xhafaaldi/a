import 'package:flutter/material.dart';
import "package:collection/collection.dart";
import 'package:get/get.dart';
import 'package:isave/pages/main/bar_pages/transactions_list_page.dart';

import 'package:isave/utilities/models/transaction.dart';
import 'package:isave/utilities/utilities.dart';
import 'package:isave/widgets/drawerwidget.dart';
import 'package:isave/widgets/transaction/transaction_card.dart';
import 'package:isave/globals.dart' as globals;

import 'package:intl/intl.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  BannerAd? _bannerAd;
  String currentDate = DateFormat("MMMM yyyy").format(DateTime.now());
  late Map<String, dynamic> selectedMonthData;

  @override
  void initState() {
    selectedMonthData = globals.currentAccount!.statisticsByMonth[currentDate];
    BannerAd(
      adUnitId: "ca-app-pub-1532914256578614/1453238382",
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
            Text("Balance",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),),
            Text("${globals.currentAccount!.currency.symbol} ${Utilities.formatNumber(Utilities.calculateBalance(globals.currentAccount!))}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,),),
           SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  height: 150,
                  width: Get.width / 2.6,
                  decoration: BoxDecoration(
                    color: Color(0xff8de0fb),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("This month",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500)),
                      SizedBox(height: 20,),
                      Text("${globals.currentAccount!.currency.symbol} ${Utilities.formatNumber(
                          double.parse(selectedMonthData["income"].toString())
                      )}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
                      Text("Income",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color: Colors.black54)),
                    ],
                  ),
                ),
                Container(
                  height: 150,
                  width: Get.width / 2.6,
                  decoration: BoxDecoration(
                    color: Color(0xffffaf75),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("This month",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500)),
                      SizedBox(height: 20,),
                      Text("${globals.currentAccount!.currency.symbol} ${Utilities.formatNumber(
                          double.parse(selectedMonthData["expense"].toString())
                      )}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
                      Text("Expense",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        leadingWidth: 0,
        toolbarHeight: 300,
        leading: Container(),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20),)
        ),
        height: double.infinity,
        child: buildBody(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget buildBody() {
    List<Transaction> transactions = globals.currentAccount!.transactions.reversed.toList();

    if (transactions.isNotEmpty) {
      final List<MapEntry<DateTime, List<Transaction>>> groupedTransactions = groupBy(
        transactions,
        (Transaction transaction) => transaction.date
      ).entries.toList();

      List<Widget> cards = [];

      cards.add(Utilities.displayBanner(_bannerAd));
      cards.add(Padding(
        padding: const EdgeInsets.all( 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Transactions",
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18)
            ),
            InkWell(
              onTap: () {
                Get.to(()=> TransactionsListPage());
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 3,horizontal: 10),
                decoration: BoxDecoration(
                  color: Color(0xff5177ff).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text("See All",
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15,color: Color(0xff5177ff))
                ),
              ),
            ),
          ],
        ),
      ));

      for (MapEntry<DateTime, List<Transaction>> entry in groupedTransactions) {
        cards.add(Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                DateFormat("dd MMMM yyyy").format(entry.key),
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18)
              ),
              SizedBox(height: 5,),
              ListView.separated(
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                },
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entry.value.length,
                itemBuilder: (BuildContext context, int index) {
                  return TransactionCard(transaction: entry.value[index]);
                },
              )
            ],
          )
        ));
      }

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5, top: 5,right: 10,left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cards
          ),
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Utilities.displayBanner(_bannerAd),
              ),
            ),
            const Expanded(
              flex: 2,
              child: Column(
                children: [
                  Text(
                    "No Record",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    )
                  ),
                  Text("Tap the + button to add your first record."),
                ],
              ),
            )
          ],
        ),
      );
    }
  }
}