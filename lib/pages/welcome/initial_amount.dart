import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/utilities/models/enums/wallet_type.dart';
import 'package:isave/utilities/utilities.dart';
import 'package:isave/globals.dart' as globals;
import 'package:isave/utilities/models/wallet.dart';

import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';


class InitialAmount extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  InitialAmount({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              const Text("Initial Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 5),
              const Text(
                "How much money do you have in your cash wallet?",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,

                decoration: InputDecoration(
                  prefix: Text(globals.currentAccount!.currency.symbol),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.blueGrey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.5,
                child: TextButton(
                  onPressed: () async {
                    HapticFeedback.selectionClick();
                    Wallet currentWallet = Wallet(
                      id: const Uuid().v4(),
                      name: "Cash",
                      type: WalletType.general,
                      amount: double.parse(controller.text),
                      color: Colors.blue,
                      currency: globals.currentAccount!.currency
                    );

                    String formattedDate = DateFormat("MMMM yyyy").format(DateTime.now());
                    Map<String, dynamic> currentMonthStats = globals.currentAccount!.statisticsByMonth;
                    currentMonthStats[formattedDate]["openingBalance"] = double.parse(controller.text);
                    currentMonthStats[formattedDate]["income"] = double.parse(controller.text);

                    Utilities.updateAccount(
                      wallets: [currentWallet],
                      statisticsByMonth: currentMonthStats
                    );

                    if (context.mounted) {

                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(globals.enabledButtonColor),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ))
                  ),
                  child: const Text("Next")
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}