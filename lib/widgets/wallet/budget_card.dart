import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/pages/main/wallet/budget/budget_details_page.dart';
import 'package:isave/utilities/utilities.dart';
import 'package:isave/utilities/models/budget.dart';

import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  const BudgetCard({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    double percentage = (budget.totalSpent < budget.amount)
      ? budget.totalSpent / budget.amount
      : 1;

    if (percentage < 0) {
      percentage = 0;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Get.to(() => BudgetDetailsPage(budget: budget));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                budget.name,
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
            //   child: Text(DateFormat("dd/MM/yyyy").format(budget.untilDate)),
            // ),
            barRadius: const Radius.circular(5),
            lineHeight: 6,
            animationDuration: 500,
            percent: percentage,
            backgroundColor: Color(0xff8c8c8c),
            // center: Text(
            //   "${Utilities.formatNumber(percentage * 100)}% (${Utilities.formatNumber(
            //     budget.totalSpent
            //   )}/${Utilities.formatNumber(budget.amount)})",
            //   style: const TextStyle(color: Colors.white)
            // ),
            progressColor: Utilities.progressBarColor(percentage * 100),
          ),
          SizedBox(height: 10,)
        ],
      ),
    );
  }
}