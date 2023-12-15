import 'package:flutter/material.dart';
import 'package:isave/utilities/models/enums/credit_card_type.dart';

import 'package:isave/utilities/models/enums/wallet_type.dart';
import 'package:isave/utilities/models/wallet.dart';
import 'package:isave/utilities/utilities.dart';

import 'package:auto_size_text/auto_size_text.dart';

class WalletCard extends StatelessWidget {
  final Wallet wallet;

  const WalletCard({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      child: Stack(
        children: [
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        wallet.color,
                        wallet.color.withOpacity(.8)
                      ]
                  )
              ),
              child: buildInside()
          ),
          Positioned(
            right: 0,
            child: Image.asset("assets/ping.png",height: 120,)
          )
        ],
      ),
    );
  }

  Widget buildInside() {
    Map<String, String> creditCardLogos = {
      "mastercard": "assets/mastercard.png",
      "visa": "assets/visa.png",
      "amex": "assets/amex.png",
      "other": "assets/other.png"
    };

    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  wallet.currency.code,
                  style: const TextStyle(color: Colors.white)
              ),
              const SizedBox(width: 5),
              if (wallet.type == WalletType.creditCard)
                Image.asset(
                  creditCardLogos[wallet.creditCardType!.name]!,
                  width: 40,
                  height: 30,
                  color: wallet.creditCardType! == CreditCardType.other ? Colors.white : null,
                  fit: BoxFit.fitHeight,
                ),
            ],
          ),
          Text(
            wallet.name,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AutoSizeText(
                    "${Utilities.formatNumber(wallet.amount)} ${wallet.currency.symbol}",
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                  if (wallet.type == WalletType.creditCard)
                    const Expanded(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text("**** **** **** ****", style: TextStyle(color: Colors.white, fontSize: 20)),
                      ),
                    )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}