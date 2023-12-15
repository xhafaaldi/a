import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/utilities/utilities.dart';
import 'package:isave/globals.dart' as globals;
import 'package:isave/utilities/models/wallet.dart';
import 'package:isave/utilities/models/currency.dart';
import 'package:isave/utilities/models/enums/wallet_type.dart';
import 'package:isave/pages/main/main_page.dart';

import 'package:currency_picker/currency_picker.dart' as picker;
import 'package:isave/widgets/isave_dropdown.dart';
import 'package:isave/widgets/isave_textfield.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddAccount extends StatefulWidget {
  const AddAccount({Key? key}) : super(key: key);

  @override
  State<AddAccount> createState() => _AddAccountState();
}

class _AddAccountState extends State<AddAccount> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  bool enabled = false;
  Currency? selectedCurrency;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Get Started", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                const SizedBox(height: 5),
                const Text("Create an account instantly", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                ISaveTextField(
                  controller: usernameController,
                  onChanged: (String? data) {
                    if (data == null || data.isEmpty) {
                      setState(() {
                        enabled = false;
                      });
                    } else {
                      setState(() {
                        enabled = true;
                      });
                    }
                  },
                  labelText: "Username",
                  hintText: "e. g. makus",
                ),
                const SizedBox(height: 20),
                ISaveTextField(
                  controller: nameController,
                  onChanged: (String? data) {
                    if (data == null || data.isEmpty) {
                      setState(() {
                        enabled = false;
                      });
                    } else {
                      setState(() {
                        enabled = true;
                      });
                    }
                  },
                  labelText: "Account Name",
                  hintText: "e. g. Euro Account",
                ),
                const SizedBox(height: 20),
                ISaveTextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  labelText: "Initial Amount",
                  hintText: "e. g. 60",
                ),
                const SizedBox(height: 5),
                const Text("Select Currency", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                SizedBox(
                  width: double.infinity,
                  child: ISaveDropdown(
                    onPressed: () async {
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
                      selectedCurrency != null ? selectedCurrency!.code : "Select",
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Adjust the spacing here
                const Spacer(), // Move the button to the bottom
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      HapticFeedback.selectionClick();

                      if (enabled) {
                        if (nameController.text.isEmpty || amountController.text.isEmpty
                            || selectedCurrency == null || usernameController.text.isEmpty) {
                          Utilities.showSnackbar(
                            isSuccess: false,
                            title: "Error!",
                            description: "Please fill out everything needed!",
                          );
                        } else {
                          Wallet currentWallet = Wallet(
                            id: const Uuid().v4(),
                            name: "Cash",
                            type: WalletType.general,
                            amount: double.parse(amountController.text),
                            color: Colors.blue,
                            currency: selectedCurrency!,
                          );

                          String formattedDate = DateFormat("MMMM yyyy").format(DateTime.now());
                          Map<String, dynamic> currentMonthStats = globals.currentAccount!.statisticsByMonth;
                          currentMonthStats[formattedDate]["openingBalance"] = double.parse(amountController.text);

                          await Utilities.setBool(key: "didFinishSetup", value: true);
                          Utilities.updateAccount(
                            name: nameController.text,
                            currency: selectedCurrency,
                            wallets: [currentWallet],
                            statisticsByMonth: currentMonthStats,
                          );

                          await FirebaseAuth.instance.currentUser!.updateDisplayName(usernameController.text);

                          if (mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const MainPage()),
                              (route) => false,
                            );
                          }
                        }
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(enabled
                        ? globals.enabledButtonColor
                        : globals.disabledButtonColor
                      ),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ))
                    ),
                    child: const Text("Next", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
