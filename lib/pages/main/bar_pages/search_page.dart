import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/utilities/models/transaction.dart';
import 'package:isave/globals.dart' as globals;
import 'package:isave/widgets/transaction/transaction_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController controller = TextEditingController();
  List<Transaction> transactions = [];
  Widget centerWidget = const Text("Nothing found!", style: TextStyle(fontWeight: FontWeight.bold));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2436db),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xff2436db),
        title: Row(
          children: [
            IconButton(onPressed: () {
              Navigator.pop(context);
            }, icon: Icon(Icons.arrow_back,color: Colors.white,)),
            SizedBox(width: 10,),
            Text("Search",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),),
          ],
        ),
        leadingWidth: 0,
        toolbarHeight: 60,
        leading: Container(),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20),)
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
                child: SearchBar(
                  hintText: "Search something...",
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  controller: controller,
                  onSubmitted: (String data) {
                    setState(() {
                      transactions = [];
                      centerWidget = const CupertinoActivityIndicator();
                    });
                    for (Transaction transaction in globals.currentAccount!.transactions) {
                      if (transaction.title.toLowerCase().contains(data)) {
                        transactions.add(transaction);
                      }
                    }
                    setState(() {
                      centerWidget = const Text("Nothing found!", style: TextStyle(fontWeight: FontWeight.bold));
                    });
                  }
                ),
              ),
              Expanded(child: buildTransactionsList())
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTransactionsList() {
    if (transactions.isEmpty) {
      return Center(child: centerWidget);
    } else {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: transactions.length,
        itemBuilder: (BuildContext context, int index) {
          return TransactionCard(transaction: transactions[index]);
        }
      );
    }
  }
}