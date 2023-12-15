import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:isave/pages/main/wallet/goal/goal_details_page.dart';

import 'package:isave/utilities/utilities.dart';
import 'package:isave/utilities/models/goal.dart';
import 'package:isave/globals.dart' as globals;

import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:intl/intl.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    double balance = Utilities.calculateBalance(globals.currentAccount!);
    double percentage = (balance <= goal.amount)
      ? balance / goal.amount
      : 1;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Get.to(() => GoalDetailsPage(goal: goal));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  goal.name,
                  style: const TextStyle(fontSize: 15)
              ),
              Text("${Utilities.formatNumber(percentage * 100)}/100",
                  style: const TextStyle(fontSize: 15)
              ),
            ],
          ),
          SizedBox(height: 5,),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            animation: true,
            // trailing: Padding(
            //   padding: const EdgeInsets.only(left: 5),
            //   child: Text(DateFormat("dd/MM/yyyy").format(goal.targetDate)),
            // ),
            barRadius: const Radius.circular(5),
            lineHeight: 6,
            animationDuration: 500,
            percent: percentage,
            backgroundColor: Color(0xff8c8c8c),
            // center: Text(
            //   "${percentage * 100}% (${Utilities.formatNumber(
            //     balance
            //   )}/${Utilities.formatNumber(goal.amount)})",
            //   style: const TextStyle(color: Colors.white)
            // ),
            progressColor: Utilities.progressBarColor(percentage * 100),
          ),
          SizedBox(height: 10,),
        ],
      ),
    );
  }
}