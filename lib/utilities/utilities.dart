import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:isave/utilities/models/budget.dart';
import 'package:isave/utilities/models/transaction.dart';
import 'package:isave/utilities/models/enums/transaction_type.dart';
import 'package:isave/globals.dart' as globals;
import 'package:isave/utilities/models/transaction_template.dart';
import 'package:isave/utilities/models/wallet.dart';
import 'package:isave/utilities/models/debt.dart';
import 'package:isave/utilities/models/goal.dart';
import 'package:isave/utilities/models/account.dart';
import 'package:isave/utilities/models/currency.dart' as isave;
import 'package:isave/utilities/models/enums/recurring_type.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class Utilities {
  static void showSnackbar({
    required bool isSuccess,
    required String title,
    required String description
  }) {
    Get.snackbar(
      title,
      description,
      icon: isSuccess
        ? const Icon(Icons.check, color: Colors.green)
        : const Icon(Icons.warning_amber, color: Colors.red)
    );
  }

  static Future<void> setString({
    required String key,
    required String value
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getString({
   required String key
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> setStringList({
    required String key,
    required List<String> value
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, value);
  }

  static Future<void> setInt({
    required String key,
    required int value
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  static Future<void> setBool({
    required String key,
    required bool value
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<void> removeTransaction(Transaction transaction) async {
    String formattedDate = DateFormat("MMMM yyyy").format(DateTime.now());
    List<Transaction> transactions = globals.currentAccount!.transactions;
    Map<String, dynamic> statisticsByMonth = globals.currentAccount!.statisticsByMonth;

    transactions.removeWhere((e) => e.id == transaction.id);

    Map<String, dynamic> currentMonthStats = {
      "income": globals.currentAccount!.statisticsByMonth[formattedDate]["income"],
      "expense": globals.currentAccount!.statisticsByMonth[formattedDate]["expense"],
      "expenseCategories": globals.currentAccount!.statisticsByMonth[formattedDate]["expenseCategories"],
      "openingBalance": globals.currentAccount!.statisticsByMonth[formattedDate]["openingBalance"],
    };

    if (transaction.type == TransactionType.expense) {
      currentMonthStats["expense"] -= transaction.amount;
    } else if (transaction.type == TransactionType.income) {
      currentMonthStats["income"] -= transaction.amount;
    }

    await Utilities.addToWallet(Transaction(
      id: transaction.id,
      date: transaction.date,
      amount: -(transaction.amount),
      title: transaction.title,
      type: transaction.type,
      currency: transaction.currency,
      category: transaction.category,
      wallet: transaction.wallet,
      memo: transaction.memo,
      toWallet: transaction.toWallet,
      fromWallet: transaction.fromWallet
    ), true).then((_) async {
      statisticsByMonth[formattedDate] = currentMonthStats;

      await Utilities.updateAccount(
        transactions: transactions,
        statisticsByMonth: statisticsByMonth
      );
    });
  }

  static Widget displayBanner(BannerAd? bannerAd) {
    if (bannerAd != null && !globals.isPremium!) {
      return Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: SizedBox(
          width: bannerAd.size.width.toDouble(),
          height: bannerAd.size.height.toDouble(),
          child: AdWidget(ad: bannerAd),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  static Future<void> removeGoal(Goal goal) async {
    List<Goal> goals = globals.currentAccount!.goals;

    goals.removeWhere((g) => g.id == goal.id);
    await Utilities.updateAccount(goals: goals);
  }

  static Future<void> removeBudget(Budget budget) async {
    List<Budget> budgets = globals.currentAccount!.budgets;

    budgets.removeWhere((b) => b.id == budget.id);
    await Utilities.updateAccount(budgets: budgets);
  }

  static Future<void> removeDebt(Debt debt) async {
    List<Debt> debts = globals.currentAccount!.debts;

    debts.removeWhere((d) => d.id == debt.id);
    await Utilities.updateAccount(debts: debts);
  }

  static Future<void> addToWallet(Transaction transaction, bool isRemoved) async {
    List<Wallet> wallets = globals.currentAccount!.wallets;
    Wallet selectedWallet = wallets.firstWhere((e) => e.id == transaction.wallet.id);
    double amount = 0;

    switch (transaction.type) {
      case TransactionType.income:
        amount = transaction.amount;
      case TransactionType.expense:
        amount = -(transaction.amount);
      case TransactionType.transfer:
        amount = 0;
    }

    if (transaction.type != TransactionType.transfer) {
      wallets.remove(selectedWallet);
      wallets.add(Wallet(
        id: selectedWallet.id,
        name: selectedWallet.name,
        amount: double.parse((selectedWallet.amount + amount).toStringAsFixed(1)),
        color: selectedWallet.color,
        currency: selectedWallet.currency,
        type: selectedWallet.type,
        creditCardType: selectedWallet.creditCardType
      ));

      if (!isRemoved) {
        await Utilities.addTransactionAmountByMonth(
          amount,
          transaction.category
        );
      }
    } else {
      wallets.remove(transaction.toWallet!);
      wallets.add(Wallet(
        id: transaction.toWallet!.id,
        name: transaction.toWallet!.name,
        amount: double.parse((transaction.toWallet!.amount + (!isRemoved ? transaction.amount : -(transaction.amount))).toStringAsFixed(1)),
        color: transaction.toWallet!.color,
        currency: transaction.toWallet!.currency,
        type: transaction.toWallet!.type,
        creditCardType: transaction.toWallet!.creditCardType
      ));

      wallets.remove(transaction.fromWallet!);
      wallets.add(Wallet(
        id: transaction.fromWallet!.id,
        name: transaction.fromWallet!.name,
        amount: double.parse((transaction.fromWallet!.amount + (!isRemoved ? -(transaction.amount) : transaction.amount)).toStringAsExponential(1)),
        color: transaction.fromWallet!.color,
        currency: transaction.fromWallet!.currency,
        type: transaction.fromWallet!.type,
        creditCardType: transaction.fromWallet!.creditCardType
      ));
    }
    await Utilities.updateAccount(wallets: wallets);
    return;
  }

  static double calculateEndBalance(String selectedDate) {
    double endBalance = 0;
    String currentDate = DateFormat("MMMM yyyy").format(DateTime.now());

    if (selectedDate == currentDate) {
      return double.parse((globals.currentAccount!.statisticsByMonth[currentDate]["income"] - globals.currentAccount!.statisticsByMonth[currentDate]["expense"]).toString());
    }

    return endBalance;
  }
  
  static String formatNumber(double number) {
    return NumberFormat.decimalPatternDigits(
      locale: "en_us",
      decimalDigits: 1,
    ).format(number);
  }

  static DateTime calculateSelectedDate(RecurringType recurringType, DateTime selectedDate) {
    DateTime now = DateTime.now();

    switch (recurringType) {
      case RecurringType.weekly:
        return DateTime(now.year, now.month, now.day + 7);
      case RecurringType.monthly:
        return DateTime(now.year, now.month + 1, now.day);
      case RecurringType.daily:
        return DateTime(now.year, now.month, now.day + 1);
      case RecurringType.yearly:
        return DateTime(now.year + 1, now.month, now.day);
      case RecurringType.none:
        return selectedDate;
    }
  }

  static Future<void> addTransaction(BuildContext context, Transaction transaction) async {
    List<Transaction> transactions = globals.currentAccount!.transactions;
    List<Budget>? newBudgets;

    if (transaction.type == TransactionType.expense) {
      List<Budget> budgets = globals.currentAccount!.budgets;
      newBudgets = [];

      for (Budget budget in budgets) {
        newBudgets.add(Budget(
          id: budget.id,
          name: budget.name,
          creationDate: budget.creationDate,
          untilDate: budget.untilDate,
          amount: budget.amount,
          totalSpent: budget.totalSpent + transaction.amount,
          recurring: budget.recurring,
          recurringType: budget.recurringType
        ));
      }
    }

    transactions.add(transaction);

    await Utilities.updateAccount(
      transactions: transactions,
      budgets: newBudgets ?? globals.currentAccount!.budgets
    );
    await Utilities.addToWallet(transaction, false);
  }

  static Future<void> editTransaction(BuildContext context, Transaction transaction) async {
    Utilities.removeTransaction(transaction);
    Utilities.addTransaction(context, transaction);
  }

  static Future<void> addTransactionAmountByMonth(double amount, String category) async {
    String dateText = DateFormat("MMMM yyyy").format(DateTime.now());
    Map<String, dynamic> statisticsByMonth = globals.currentAccount!.statisticsByMonth;

    try {
      Map<String, dynamic> selectedStat = statisticsByMonth[dateText];
      Map<dynamic, dynamic> expenseCategories = selectedStat["expenseCategories"];

      if (amount >= 0) {
        selectedStat["income"] += double.parse(amount.toStringAsFixed(1));
      } else {
        selectedStat["expense"] += -double.parse(amount.toStringAsFixed(1));
        if (expenseCategories[category] != null) {
          expenseCategories[category] = expenseCategories[category]! + -double.parse(amount.toStringAsFixed(1));
        } else {
          expenseCategories[category] = -double.parse(amount.toStringAsFixed(1));
        }
      }
    } catch (e, stack) {
      debugPrint(e.toString());
      debugPrint(stack.toString());
      Map<String, dynamic> expenseCategories = {};

      if (amount <= 0) {
        expenseCategories[category] = double.parse(amount.toStringAsFixed(1));
      } else {
        expenseCategories = {};
      }

      statisticsByMonth[dateText] = {
        "income": amount >= 0 ? double.parse(amount.toStringAsFixed(1)) : 0,
        "expense": amount >= 0 ? 0 : -(double.parse(amount.toStringAsFixed(1))),
        "expenseCategories": expenseCategories,
        "openingBalance": double.parse(amount.toStringAsFixed(1)),
      };
    }

    await Utilities.updateAccount(statisticsByMonth: statisticsByMonth);
  }

  static Future<void> createWallet(Wallet wallet) async {
    List<Wallet> wallets = globals.currentAccount!.wallets;
    wallets.add(wallet);

    String formattedDate = DateFormat("MMMM yyyy").format(DateTime.now());
    Map<String, dynamic> statisticsByMonth = globals.currentAccount!.statisticsByMonth;
    statisticsByMonth[formattedDate]["openingBalance"] = (double.tryParse(statisticsByMonth[formattedDate]["openingBalance"].toString()) ?? 0) + wallet.amount;
    statisticsByMonth[formattedDate]["endingBalance"] = (double.tryParse(statisticsByMonth[formattedDate]["endingBalance"].toString()) ?? 0) + wallet.amount;

    await Utilities.updateAccount(
      wallets: wallets,
      statisticsByMonth: statisticsByMonth
    );
  }

  static Future<void> createGoal(Goal goal) async {
    List<Goal> goals = globals.currentAccount!.goals;
    goals.add(goal);

    await Utilities.updateAccount(goals: goals);
  }

  static Future<void> createAccount(Account account) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> accountsStringList = prefs.getStringList("accounts")!;

    List<Account> accounts = globals.accounts!;
    accounts.add(account);

    accountsStringList.add(jsonEncode(account.toJson()));
    await prefs.setStringList("accounts", accountsStringList);
  }

  static Future<void> updateAccount({
    String? name,
    isave.Currency? currency,
    List<Wallet>? wallets,
    List<Transaction>? transactions,
    List<Debt>? debts,
    List<Goal>? goals,
    List<Budget>? budgets,
    Map<String, dynamic>? statisticsByMonth,
    List<TransactionTemplate>? transactionTemplates
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> accountsStringList = prefs.getStringList("accounts")!;
    List<Account> accountsList = globals.accounts!;
    accountsStringList.removeWhere((e) => Account.fromJson(jsonDecode(e)).id == globals.currentAccount!.id);
    accountsList.removeWhere((e) => e.id == globals.currentAccount!.id);

    Account account = Account(
      id: globals.currentAccount!.id,
      name: name ?? globals.currentAccount!.name,
      currency: currency ?? globals.currentAccount!.currency,
      wallets: wallets ?? globals.currentAccount!.wallets,
      transactions: transactions ?? globals.currentAccount!.transactions,
      debts: debts ?? globals.currentAccount!.debts,
      goals: goals ?? globals.currentAccount!.goals,
      statisticsByMonth: statisticsByMonth ?? globals.currentAccount!.statisticsByMonth,
      budgets: budgets ?? globals.currentAccount!.budgets,
      transactionTemplates: transactionTemplates ?? globals.currentAccount!.transactionTemplates
    );
    globals.currentAccount = account;

    String currentAccountString = jsonEncode(globals.currentAccount!.toJson());

    await prefs.setString("currentAccount", currentAccountString);

    accountsStringList.add(currentAccountString);
    await prefs.setStringList("accounts", accountsStringList);
    accountsList.add(account);
    globals.accounts = accountsList;

    await Utilities.updateFirestoreUser();
  }

  static Future<void> switchAccounts(Account toAccount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    globals.currentAccount = toAccount;
    await prefs.setString("currentAccount", jsonEncode(toAccount.toJson()));
  }

  static Future<void> createDebt(Debt debt) async {
    List<Debt> debts = globals.currentAccount!.debts;
    debts.add(debt);

    await Utilities.updateAccount(debts: debts);
  }

  static Future<void> createBudget(Budget budget) async {
    List<Budget> budgets = globals.currentAccount!.budgets;
    budgets.add(budget);

    await Utilities.updateAccount(budgets: budgets);
  }

  static double calculateBalance(Account account) {
    double balance = 0;

    for (Wallet wallet in account.wallets) {
      balance += wallet.amount;
    }

    return double.parse(balance.toStringAsFixed(1));
  }

  static Future<void> updateFirestoreUser() async {
    firestore.FirebaseFirestore firestoreInstance = firestore.FirebaseFirestore.instance;
    firestore.CollectionReference users = firestoreInstance.collection("users");
    User user = FirebaseAuth.instance.currentUser!;

    List<Map<String, dynamic>> accountsList = [];

    for (Account account in globals.accounts!) {
      accountsList.add(account.toJson());
    }

    String? email = await Utilities.getString(key: "email");

    Map<String, dynamic> data = {
      "email": email ?? user.email,
      "accounts": accountsList,
      "isPremium": globals.isPremium!
    };

    try {
      await users.doc(user.uid).update(data).onError((e, _) async {
        await users.doc(user.uid).set(data);
      });
    } catch (e, s) {
      debugPrint(s.toString());
      return;
    }
  }

  static Future<void> setupNotifications() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    await flutterLocalNotificationsPlugin.initialize(const InitializationSettings(
      iOS: DarwinInitializationSettings(
        requestCriticalPermission: false,
        requestSoundPermission: true,
        requestAlertPermission: true,
        requestBadgePermission: true,
      ),
      android: AndroidInitializationSettings("@mipmap/ic_launcher")
    ));

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails("", "", icon: "@mipmap/ic_launcher"),
    );
    await flutterLocalNotificationsPlugin.periodicallyShow(
      0,
      "Reminder!",
      "Did you add your expenses today?",
      RepeatInterval.daily,
      notificationDetails
    );
  }

  static Future<void> getUserFromFirestore() async {
    firestore.FirebaseFirestore firestoreInstance = firestore.FirebaseFirestore.instance;
    User user = FirebaseAuth.instance.currentUser!;
    Map<String, dynamic> userData = (await firestoreInstance.collection(
      "users"
    ).doc(user.uid).get()).data()!;
    List<dynamic> userAccounts = userData["accounts"];
    globals.accounts = [];

    for (Map<String, dynamic> account in userAccounts) {
      globals.accounts!.add(Account.fromJson(account));
    }

    globals.currentAccount = globals.accounts![0];
  }

  static Future<String?> uploadFile(String path, Uint8List data) async {
    final Reference ref = FirebaseStorage.instance.ref();
    final Reference imageRef = ref.child(path);

    try {
      await imageRef.putData(data);
      return await imageRef.getDownloadURL();
    } on FirebaseException catch (_) {
      return null;
    }
  }

  static Future<XFile?> selectImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    return image;
  }

  static Color transactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Colors.green;
      case TransactionType.expense:
        return Colors.red;
      case TransactionType.transfer:
        return Colors.orangeAccent;
    }
  }

  static Color progressBarColor(double value) {
    if (value <= 100 && value >= 75) {
      return Colors.green;
    } else if (value < 75 && value >= 50) {
      return Colors.lightGreen;
    } else if (value < 50 && value >= 25) {
      return Colors.redAccent;
    } else {
      return Colors.red;
    }
  }

  static void showLoadingDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return Container(
          color: Colors.black.withOpacity(.5),
          child: const Center(child: CircularProgressIndicator())
        );
      },
    );
  }
}