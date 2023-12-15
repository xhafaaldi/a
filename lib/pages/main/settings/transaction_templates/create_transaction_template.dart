import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/pages/main/settings/transaction_templates/create_transaction_template_details.dart';
import 'package:isave/utilities/models/enums/transaction_type.dart';

class CreateTransactionTemplate extends StatefulWidget {
  const CreateTransactionTemplate({super.key});

  @override
  State<CreateTransactionTemplate> createState() => _CreateTransactionTemplateState();
}

class _CreateTransactionTemplateState extends State<CreateTransactionTemplate> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
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
              Text("Create Transaction Template",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
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
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: "Income"),
                  Tab(text: "Expense"),
                ],
              ),
              Expanded(
                child: const TabBarView(
                  children: <Widget>[
                    CreateTransactionTemplateDetails(type: TransactionType.income),
                    CreateTransactionTemplateDetails(type: TransactionType.expense),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}