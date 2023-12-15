import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:isave/globals.dart' as globals;
import 'package:isave/utilities/utilities.dart';

import 'package:intl/intl.dart';
import 'package:isave/widgets/drawerwidget.dart';
import 'package:isave/widgets/isave_card.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  DateTime currentDateTime = DateTime.now();
  String currentDate = DateFormat("MMMM yyyy").format(DateTime.now());
  BannerAd? _bannerAd;

  late Map<String, dynamic> selectedMonthData;

  @override
  void initState() {
    selectedMonthData = globals.currentAccount!.statisticsByMonth[currentDate];
    BannerAd(
      adUnitId: "ca-app-pub-1532914256578614/9926662764",
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
    Map<String, double> expenseCategories = {};

    if ((selectedMonthData["expenseCategories"] as Map<dynamic, dynamic>).isEmpty) {
      expenseCategories["Nothing yet!"] = 0;
    } else {
      (selectedMonthData["expenseCategories"] as Map<dynamic, dynamic>).forEach((key, value) {
        expenseCategories[key] = value;
      });
    }

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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 5),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            if ((currentDateTime.month - 1) == 0) {
                              currentDateTime = DateTime(currentDateTime.year - 1, 12);
                            } else {
                              currentDateTime = DateTime(currentDateTime.year, currentDateTime.month - 1);
                            }
                            currentDate = DateFormat("MMMM yyyy").format(currentDateTime);
                            if (globals.currentAccount!.statisticsByMonth[currentDate] != null) {
                              selectedMonthData = globals.currentAccount!.statisticsByMonth[currentDate];
                            } else {
                              selectedMonthData = {
                                "income": 0.0,
                                "expense": 0.0,
                                "expenseCategories": {},
                                "openingBalance": 0.0
                              };
                            }
                          });
                        },
                        icon: const Icon(CupertinoIcons.back,color: Colors.white),
                      ),
                      Expanded(child: Center(child: Text(currentDate, style: const TextStyle(fontSize: 17,color: Colors.white)))),
                      IconButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            if ((currentDateTime.month + 1) == 13) {
                              currentDateTime = DateTime(currentDateTime.year + 1, 1);
                            } else {
                              currentDateTime = DateTime(currentDateTime.year, currentDateTime.month + 1);
                            }
                            currentDate = DateFormat("MMMM yyyy").format(currentDateTime);
                            if (globals.currentAccount!.statisticsByMonth[currentDate] != null) {
                              selectedMonthData = globals.currentAccount!.statisticsByMonth[currentDate];
                            } else {
                              selectedMonthData = {
                                "income": 0.0,
                                "expense": 0.0,
                                "expenseCategories": {},
                                "openingBalance": 0.0
                              };
                            }
                          });
                        },
                        icon: const Icon(CupertinoIcons.forward,color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Opening Balance",style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w500)),
                          const SizedBox(height: 0),
                          Text(
                              "${globals.currentAccount!.currency.symbol} ${Utilities.formatNumber(
                                  selectedMonthData["openingBalance"]
                              )}",
                              style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20)
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Ending Balance",style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w500)),
                          const SizedBox(height: 0),
                          Text(
                              "${globals.currentAccount!.currency.symbol} ${Utilities.formatNumber(
                                  Utilities.calculateEndBalance(currentDate))
                              }",
                              style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20)
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        leadingWidth: 0,
        toolbarHeight: 190,
        leading: Container(),
      ),
      body: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20),)
        ),
        height: double.infinity,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 25, right: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Utilities.displayBanner(_bannerAd),
                  ),
                  const SizedBox(height: 10),
                  const Text("Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: Get.width * 0.4,
                        padding: EdgeInsets.symmetric(vertical: 12,horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x65919191),
                              spreadRadius: 0.01,
                              blurRadius: 8,
                              offset: Offset(0.0, 1),
                            )
                          ],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(backgroundColor: Colors.green,radius: 5,),
                                SizedBox(width: 6,),
                                const Text("Income"),
                              ],
                            ),
                            Text(
                                "${globals.currentAccount!.currency.symbol} ${Utilities.formatNumber(
                                    double.parse(selectedMonthData["income"].toString())
                                )}",
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: Get.width * 0.4,
                        padding: EdgeInsets.symmetric(vertical: 12,horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x65919191),
                              spreadRadius: 0.01,
                              blurRadius: 8,
                              offset: Offset(0.0, 1),
                            )
                          ],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(backgroundColor: Colors.red,radius: 5,),
                                SizedBox(width: 6,),
                                const Text("Expense"),
                              ],
                            ),
                            Text(
                                "${globals.currentAccount!.currency.symbol} ${Utilities.formatNumber(
                                    double.parse(selectedMonthData["expense"].toString())
                                )}",
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12,horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x65919191),
                          spreadRadius: 0.01,
                          blurRadius: 8,
                          offset: Offset(0.0, 1),
                        )
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(backgroundColor: Color(0xff2436db),radius: 5,),
                            SizedBox(width: 6,),
                            const Text("Total"),
                          ],
                        ),
                        Text(
                            "${globals.currentAccount!.currency.symbol} ${Utilities.formatNumber(
                                double.parse((selectedMonthData["income"] - selectedMonthData["expense"]).toString())
                            )}",
                            style: const TextStyle(color: Color(0xff2436db), fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Expense Structure", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ISaveCard(title: "", body: Wrap(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: PieChart(
                          dataMap: expenseCategories,
                          animationDuration: const Duration(milliseconds: 300),
                          chartLegendSpacing: 32,
                          chartRadius: 150,
                          initialAngleInDegree: 0,
                          chartType: ChartType.ring,
                          ringStrokeWidth: 15,
                          centerText: "Total: ${selectedMonthData["expense"]}${globals.currentAccount!.currency.symbol}",
                          legendOptions: const LegendOptions(
                            showLegendsInRow: false,
                            legendPosition: LegendPosition.right,
                            showLegends: true,
                            legendShape: BoxShape.circle,
                            legendTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          chartValuesOptions: const ChartValuesOptions(
                            showChartValueBackground: true,
                            showChartValues: false,
                            showChartValuesInPercentage: true,
                            showChartValuesOutside: false,
                            decimalPlaces: 1,
                          ),
                        ),
                      ),
                    ],
                  ), onTap: () {},),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}