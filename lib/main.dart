import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/pages/main/main_page.dart';
import 'package:isave/pages/welcome/start_page.dart';
import 'package:isave/globals.dart' as globals;
import 'package:isave/utilities/models/account.dart';
import 'package:isave/utilities/models/budget.dart';
import 'package:isave/utilities/models/currency.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:isave/utilities/utilities.dart';
import 'package:isave/firebase_options.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      statusBarBrightness: Brightness.dark,
    ));
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  // await prefs.setBool("didFinishSetup", false);
  bool? didFinishSetup = prefs.getBool("didFinishSetup");

  await Utilities.setupNotifications();

  if (didFinishSetup == null || !didFinishSetup) {
    List<String> incomeCategories = [
      "Allowance",
      "Award",
      "Bonus",
      "Dividend",
      "Investment",
      "Lottery",
      "Salary",
      "Tips",
      "Others"
    ];
    List<String> expenseCategories = [
      "Bills",
      "Clothing",
      "Education",
      "Entertainment",
      "Fitness",
      "Food",
      "Gifts",
      "Health",
      "Furniture",
      "Pet",
      "Shopping",
      "Transportation",
      "Travel",
      "Others"
    ];

    Map<String, Map<String, dynamic>> currentMonthStats = {
      DateFormat("MMMM yyyy").format(DateTime.now()): {
        "income": 0.0,
        "expense": 0.0,
        "expenseCategories": {},
        "openingBalance": 0.0,
      }
    };

    Account account = Account(
      id: const Uuid().v4(),
      name: "",
      wallets: [],
      currency: Currency(
        code: "USD",
        symbol: "\$",
        rate: 1
      ),
      transactions: [],
      statisticsByMonth: currentMonthStats,
      goals: [],
      debts: [],
      budgets: [],
      transactionTemplates: []
    );

    globals.incomeCategories = incomeCategories;
    globals.expenseCategories = expenseCategories;
    globals.currentAccount = account;
    globals.accounts = [account];
    globals.isPremium = false;
    globals.selectedBrightness = Brightness.light;
    await prefs.setStringList("incomeCategories", incomeCategories);
    await prefs.setStringList("expenseCategories", expenseCategories);
    await prefs.setStringList("accounts", [jsonEncode(account.toJson())]);
    await prefs.setString("currentAccount", jsonEncode(account.toJson()));
    await prefs.setBool("premium", false);
    await prefs.setString("selectedBrightness", globals.selectedBrightness!.name);

    runApp(App(home: StartPage()));
  } else {
    await Utilities.getUserFromFirestore();

    List<Budget> budgets = globals.currentAccount!.budgets;

    globals.incomeCategories = prefs.getStringList("incomeCategories");
    globals.expenseCategories = prefs.getStringList("expenseCategories");
    globals.isPremium = prefs.getBool("premium");
    globals.selectedBrightness = Brightness.values.byName(prefs.getString("selectedBrightness")!);

    for (Budget budget in budgets) {
      if (DateUtils.isSameDay(budget.untilDate, DateTime.now()) && budget.recurring) {
        budgets.removeWhere((b) => b.id == budget.id);
        budgets.add(Budget(
          id: budget.id,
          creationDate: budget.creationDate,
          untilDate: Utilities.calculateSelectedDate(
            budget.recurringType,
            DateTime.now()
          ),
          name: budget.name,
          amount: budget.amount,
          totalSpent: 0,
          recurring: budget.recurring,
          recurringType: budget.recurringType
        ));
      }
    }

    Utilities.updateAccount(budgets: budgets);

    runApp(const App(home: MainPage()));
  }
  await MobileAds.instance.initialize();
}

class App extends StatelessWidget {
  final Widget home;
  const App({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        Brightness currentBrightness = globals.isPremium!
          ? globals.selectedBrightness!
          : Brightness.light;

        return GetMaterialApp(
          title: "iSave",
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Poppins',
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueGrey,
              brightness: currentBrightness
            ),
            useMaterial3: true,
          ),
          home: home
        );
      }
    );
  }
}