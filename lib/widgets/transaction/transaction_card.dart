import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/pages/main/transaction/transaction_details.dart';
import 'package:isave/utilities/models/enums/transaction_type.dart';
import 'package:isave/utilities/models/transaction.dart';
import 'package:isave/utilities/utilities.dart';

import 'package:get/get.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final Color? textColor;

  const TransactionCard({super.key, required this.transaction, this.textColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Get.to(() => TransactionDetails(transaction: transaction));
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        // height: 60,
        margin: EdgeInsets.symmetric(vertical: 10),
        // padding: const EdgeInsets.all(10),
        // decoration: BoxDecoration(
        //     color:  Color(0xFFF7F7F7),
        //     borderRadius: BorderRadius.circular(15),
        //     boxShadow: [
        //       BoxShadow(
        //         color: Color(0x65919191),
        //         spreadRadius: 0.01,
        //         blurRadius: 8,
        //         offset: Offset(0.0, 1),
        //       )
        //     ],
        //   border: Border.all(color: Color(0xffcccccc),width: 1)
        // ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: Utilities.transactionColor(transaction.type)
              ),
              child: buildIcon(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                      transaction.title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontSize: 16
                      )
                  ),
                  Text(
                    transaction.category,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                    )
                  ),
                ],
              ),
            ),
            Text(
                "${transaction.currency.symbol}${Utilities.formatNumber(transaction.amount)}",
                style: TextStyle(
                    color: textColor ?? Utilities.transactionColor(transaction.type),
                    fontWeight: FontWeight.bold,
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIcon() {
    switch (transaction.type) {
      case TransactionType.income:
        return const Icon(CupertinoIcons.up_arrow, size: 24, color: Colors.white);
      case TransactionType.expense:
        return const Icon(CupertinoIcons.down_arrow, size: 24, color: Colors.white);
      case TransactionType.transfer:
        return const Icon(Icons.compare_arrows, size: 24, color: Colors.white);
    }
  }
}