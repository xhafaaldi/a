import 'package:flutter/material.dart';

import 'package:isave/utilities/models/transaction_template.dart';
import 'package:isave/utilities/utilities.dart';
import 'package:isave/widgets/isave_card.dart';

import 'package:get/get.dart';

class TransactionTemplateCard extends StatelessWidget {
  final TransactionTemplate template;
  final Function()? onTap;
  const TransactionTemplateCard({super.key, required this.template, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: ISaveCard(
          title: template.name,
          body: Wrap(
            runSpacing: 10,
            spacing: 10,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Title", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    template.title
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Type", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    template.transactionType.name.capitalizeFirst!
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    template.category
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Amount", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    "${template.wallet.currency.symbol}${Utilities.formatNumber(template.amount)}"
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Wallet", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    template.wallet.name
                  )
                ],
              ),
            ],
          ),
          onTap: onTap ?? () {}
        ),
      ),
    );
  }

}