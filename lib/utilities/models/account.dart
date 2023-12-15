import 'package:isave/utilities/models/budget.dart';
import 'package:isave/utilities/models/currency.dart';
import 'package:isave/utilities/models/debt.dart';
import 'package:isave/utilities/models/goal.dart';
import 'package:isave/utilities/models/transaction.dart';
import 'package:isave/utilities/models/transaction_template.dart';
import 'package:isave/utilities/models/wallet.dart';

class Account {
  final String id;
  final String name;
  final List<Wallet> wallets;
  final Currency currency;
  final List<Transaction> transactions;
  final Map<String, dynamic> statisticsByMonth;
  final List<Goal> goals;
  final List<Debt> debts;
  final List<Budget> budgets;
  final List<TransactionTemplate> transactionTemplates;

  Account({
    required this.id,
    required this.name,
    required this.wallets,
    required this.currency,
    required this.transactions,
    required this.statisticsByMonth,
    required this.goals,
    required this.debts,
    required this.budgets,
    required this.transactionTemplates
  });

  factory Account.fromJson(Map<String, dynamic> data) {
    List<Wallet> wallets = [];
    List<Transaction> transactions = [];
    List<Goal> goals = [];
    List<Debt> debts = [];
    List<Budget> budgets = [];
    List<TransactionTemplate> transactionTemplates = [];

    for (Map<String, dynamic> wallet in data["wallets"]) {
      wallets.add(Wallet.fromJson(wallet));
    }

    for (Map<String, dynamic> transaction in data["transactions"]) {
      transactions.add(Transaction.fromJson(transaction));
    }

    for (Map<String, dynamic> goal in data["goals"]) {
      goals.add(Goal.fromJson(goal));
    }

    for (Map<String, dynamic> debt in data["debts"]) {
      debts.add(Debt.fromJson(debt));
    }

    for (Map<String, dynamic> budget in data["budgets"]) {
      budgets.add(Budget.fromJson(budget));
    }

    for (Map<String, dynamic> template in data["transactionTemplates"]) {
      transactionTemplates.add(TransactionTemplate.fromJson(template));
    }

    return Account(
      id: data["id"],
      name: data["name"],
      wallets: wallets,
      currency: Currency.fromJson(data["currency"]),
      transactions: transactions,
      statisticsByMonth: data["statisticsByMonth"],
      goals: goals,
      debts: debts,
      budgets: budgets,
      transactionTemplates: transactionTemplates
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> walletsMap = [];
    List<Map<String, dynamic>> transactionsMap = [];
    List<Map<String, dynamic>> goalsMap = [];
    List<Map<String, dynamic>> debtsMap = [];
    List<Map<String, dynamic>> budgetsMap = [];
    List<Map<String, dynamic>> transactionTemplatesMap = [];

    for (Wallet wallet in wallets) {
      walletsMap.add(wallet.toJson());
    }

    for (Transaction transaction in transactions) {
      transactionsMap.add(transaction.toJson());
    }

    for (Goal goal in goals) {
      goalsMap.add(goal.toJson());
    }

    for (Debt debt in debts) {
      debtsMap.add(debt.toJson());
    }

    for (Budget budget in budgets) {
      budgetsMap.add(budget.toJson());
    }

    for (TransactionTemplate template in transactionTemplates) {
      transactionTemplatesMap.add(template.toJson());
    }

    return {
      "id": id,
      "name": name,
      "wallets": walletsMap,
      "currency": currency.toJson(),
      "transactions": transactionsMap,
      "statisticsByMonth": statisticsByMonth,
      "goals": goalsMap,
      "debts": debtsMap,
      "budgets": budgetsMap,
      "transactionTemplates": transactionTemplatesMap
    };
  }
}