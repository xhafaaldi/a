import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/utilities/models/currency.dart';
import 'package:isave/utilities/utilities.dart';
import 'package:isave/pages/welcome/initial_amount.dart';
import 'package:isave/globals.dart' as globals;

import 'package:currency_picker/currency_picker.dart' as picker;

class CurrencySelector extends StatelessWidget {
  const CurrencySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Select Currency", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: TextButton(
                    onPressed: () async {
                      HapticFeedback.selectionClick();

                      picker.showCurrencyPicker(
                        context: context,
                        showFlag: true,
                        showCurrencyName: true,
                        showCurrencyCode: true,
                        onSelect: (picker.Currency currency) async {
                          await Utilities.setBool(key: "didFinishSetup", value: true);
                          Utilities.updateAccount(currency: Currency(
                            code: currency.code,
                            symbol: currency.symbol,
                            rate: 1.0
                          ));

                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => InitialAmount())
                            );
                          }
                        },
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(globals.enabledButtonColor),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ))
                    ),
                    child: const Text("Select")
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}