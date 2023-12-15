import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/utilities/models/enums/transaction_type.dart';
import 'package:isave/utilities/models/memo.dart';
import 'package:isave/utilities/models/transaction_template.dart';
import 'package:isave/utilities/models/wallet.dart';
import 'package:isave/utilities/utilities.dart';
import 'package:isave/globals.dart' as globals;
import 'package:isave/widgets/isave_textfield.dart';

import 'package:uuid/uuid.dart';

class CreateTransactionTemplateDetails extends StatefulWidget {
  final TransactionType type;
  const CreateTransactionTemplateDetails({super.key, required this.type});

  @override
  State<CreateTransactionTemplateDetails> createState() => _CreateTransactionTemplateDetailsState();
}

class _CreateTransactionTemplateDetailsState extends State<CreateTransactionTemplateDetails> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController memoController = TextEditingController();
  final TextEditingController titleController = TextEditingController();

  late List<String>? selectedList = widget.type == TransactionType.income
      ? globals.incomeCategories
      : globals.expenseCategories;
  late String selectedCategory = widget.type == TransactionType.income
      ? globals.incomeCategories!.first
      : globals.expenseCategories!.first;

  Wallet selectedWallet = globals.currentAccount!.wallets[0];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            ISaveTextField(
              controller: nameController,
              keyboardType: TextInputType.text,
              hintText: "Give your template a name",
              labelText: "Name",
            ),
            const SizedBox(height: 20),
            ISaveTextField(
              controller: titleController,
              keyboardType: TextInputType.text,
              hintText: "Title of the template transaction",
              labelText: "Title",
            ),
            const SizedBox(height: 20),
            ISaveTextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              hintText: "e. g. 60",
              labelText: "Title",
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 20, right: 10),
                child: Text("${globals.currentAccount!.currency.symbol} ", style: const TextStyle(fontSize: 15)),
              )
            ),
            const SizedBox(height: 20),
            DropdownMenu(
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(width: 1, color: Color.fromRGBO(0, 0, 0, 0.15)),
                ),
              ),
              label: const Text("Category"),
              initialSelection: selectedList!.first,
              onSelected: (String? value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
              dropdownMenuEntries: selectedList!.map<DropdownMenuEntry<String>>((String value) {
                return DropdownMenuEntry<String>(value: value, label: value);
              }).toList(),
            ),
            const SizedBox(height: 20),
            DropdownMenu(
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(width: 1, color: Color.fromRGBO(0, 0, 0, 0.15)),
                ),
              ),
              label: const Text("Wallet"),
              initialSelection: globals.currentAccount!.wallets.first,
              onSelected: (Wallet? value) {
                setState(() {
                  selectedWallet = value!;
                });
              },
              dropdownMenuEntries: globals.currentAccount!.wallets.map<DropdownMenuEntry<Wallet>>((Wallet value) {
                return DropdownMenuEntry<Wallet>(value: value, label: value.name);
              }).toList(),
            ),
            const SizedBox(height: 20),
            ISaveTextField(
              controller: memoController,
              keyboardType: TextInputType.text,
              hintText: "Memo of the template transaction",
              labelText: "Memo",
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  if (nameController.text.isNotEmpty && amountController.text.isNotEmpty
                      && titleController.text.isNotEmpty) {
                    Utilities.showLoadingDialog(context);
                    List<TransactionTemplate> transactionTemplates = globals.currentAccount!.transactionTemplates;

                    transactionTemplates.add(TransactionTemplate(
                      id: const Uuid().v4(),
                      name: nameController.text,
                      amount: double.parse(amountController.text),
                      transactionType: widget.type,
                      title: titleController.text,
                      category: selectedCategory,
                      wallet: selectedWallet,
                      memo: Memo(
                        id: const Uuid().v4(),
                        content: memoController.text,
                        images: []
                      )
                    ));

                    Utilities.updateAccount(
                      transactionTemplates: transactionTemplates
                    ).then((_) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    });
                  } else {
                    Utilities.showSnackbar(
                      isSuccess: false,
                      title: "Error!",
                      description: "Please fill in every required step!"
                    );
                  }
                },
                style: globals.defaultButtonStyle,
                child: const Text("Add Template"),
              ),
            )
          ],
        ),
      ),
    );
  }
}