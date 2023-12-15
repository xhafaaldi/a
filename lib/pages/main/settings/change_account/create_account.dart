import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/utilities/models/account.dart';
import 'package:isave/utilities/models/currency.dart';
import 'package:isave/utilities/models/enums/wallet_type.dart';
import 'package:isave/utilities/utilities.dart';
import 'package:isave/utilities/models/wallet.dart';
import 'package:isave/globals.dart' as globals;
import 'package:isave/widgets/isave_dropdown.dart';
import 'package:isave/widgets/isave_textfield.dart';

import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:currency_picker/currency_picker.dart' as picker;

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController initialAmountController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  Currency? selectedCurrency;

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
            Text("Create Account",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),),
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
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                ISaveTextField(
                  controller: nameController,
                  keyboardType: TextInputType.text,
                  hintText: "Give your account a name...",
                  labelText: "Name",
                ),
                const SizedBox(height: 20),
                ISaveTextField(
                  controller: initialAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  hintText: "Give an initial amount to your account...",
                  labelText: "Initial Amount",
                ),
                const SizedBox(height: 10),
                ISaveDropdown(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    picker.showCurrencyPicker(
                      context: context,
                      showFlag: true,
                      showCurrencyName: true,
                      showCurrencyCode: true,
                      onSelect: (picker.Currency currency) async {
                        setState(() {
                          selectedCurrency = Currency(
                            code: currency.code,
                            symbol: currency.symbol,
                            rate: 1.0,
                          );
                        });
                      },
                    );
                  },
                  child: Text(
                    selectedCurrency != null ? selectedCurrency!.code : "Select Currency",
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();

                      if (nameController.text.isEmpty || initialAmountController.text.isEmpty
                          || selectedCurrency == null) {
                        Utilities.showSnackbar(
                          isSuccess: false,
                          title: "Error!",
                          description: "Please fill in every required step!"
                        );
                        return;
                      } else {
                        Wallet wallet = Wallet(
                          id: const Uuid().v4(),
                          name: "Cash",
                          type: WalletType.general,
                          amount: double.parse(initialAmountController.text),
                          color: Colors.blue,
                          currency: selectedCurrency!
                        );

                        Map<String, Map<String, dynamic>> currentMonthStats = {
                          DateFormat("MMMM yyyy").format(DateTime.now()): {
                            "income": double.parse(initialAmountController.text),
                            "expense": 0,
                            "expenseCategories": {},
                            "openingBalance": double.parse(initialAmountController.text),
                          }
                        };

                        Utilities.createAccount(Account(
                          id: const Uuid().v4(),
                          name: nameController.text,
                          wallets: [wallet],
                          currency: selectedCurrency!,
                          transactions: [],
                          statisticsByMonth: currentMonthStats,
                          goals: [],
                          debts: [],
                          budgets: [],
                          transactionTemplates: []
                        )).then((_) => Navigator.pop(context));
                      }
                    },
                    style: globals.defaultButtonStyle,
                    child: const Text("Create Account")
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