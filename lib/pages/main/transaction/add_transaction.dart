import 'package:flutter/material.dart';

import 'package:isave/pages/main/transaction/add_transaction_details.dart';
import 'package:isave/utilities/models/enums/transaction_type.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({super.key});

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          leading: const SizedBox(),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Income"),
              Tab(text: "Expense"),
              Tab(text: "Transfer"),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            AddTransactionDetails(type: TransactionType.income, restorationId: "main"),
            AddTransactionDetails(type: TransactionType.expense, restorationId: "main"),
            AddTransactionDetails(type: TransactionType.transfer, restorationId: "main")
          ],
        ),
      ),
    );
  }
}