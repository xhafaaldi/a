import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/globals.dart' as globals;
import 'package:isave/pages/main/settings/change_categories/change_categories_details.dart';

class ChangeCategories extends StatefulWidget {
  const ChangeCategories({super.key});

  @override
  State<ChangeCategories> createState() => _ChangeCategoriesState();
}

class _ChangeCategoriesState extends State<ChangeCategories> {
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
              Text("Edit Categories",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),),
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
                child: TabBarView(
                  children: [
                    ChangeCategoriesDetails(categories: globals.incomeCategories!),
                    ChangeCategoriesDetails(categories: globals.expenseCategories!),
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