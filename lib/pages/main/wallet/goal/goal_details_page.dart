import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:isave/utilities/models/goal.dart';
import 'package:isave/widgets/isave_card.dart';
import 'package:isave/utilities/utilities.dart';
import 'package:isave/globals.dart' as globals;

class GoalDetailsPage extends StatelessWidget {
  final Goal goal;

  const GoalDetailsPage({super.key, required this.goal});

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
            Expanded(child: Text("Goal",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),)),
            IconButton(
              icon: const Icon(CupertinoIcons.delete,color: Colors.white,),
              onPressed: () {
                HapticFeedback.selectionClick();
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Are you sure?",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        backgroundColor: Colors.red,
                        content: const Text("This action cannot be undone.",
                            style: TextStyle(color: Colors.white)),
                        actions: [
                          ElevatedButton(
                              onPressed: () async {
                                HapticFeedback.selectionClick();
                                await Utilities.removeGoal(goal);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text("Yes",
                                  style: TextStyle(color: Colors.red))),
                          ElevatedButton(
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                Navigator.pop(context);
                              },
                              child: const Text("No",
                                  style: TextStyle(color: Colors.red)))
                        ],
                      );
                    });
              },
            ),
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 15),
            child: Column(
              children: [
                const SizedBox(height: 5),
                ISaveCard(
                    onTap: () {},
                    title: goal.name,
                    body: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Divider(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Creation Date:",
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                DateFormat("dd/MM/yyyy")
                                    .format(goal.creationDate),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Target Date:",
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                DateFormat("dd/MM/yyyy").format(goal.targetDate),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              const Text("Amount:",
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "${globals.currentAccount!.currency.symbol}${Utilities.formatNumber(goal.amount)}",
                              )
                            ],
                          ),
                        ])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
