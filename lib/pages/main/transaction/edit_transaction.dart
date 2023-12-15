import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/pages/main/main_page.dart';
import 'package:isave/utilities/models/enums/transaction_type.dart';
import 'package:isave/utilities/models/memo.dart';
import 'package:isave/utilities/models/transaction.dart';
import 'package:isave/utilities/models/wallet.dart';
import 'package:isave/utilities/utilities.dart';
import 'package:isave/widgets/isave_dropdown.dart';
import 'package:isave/widgets/isave_textfield.dart';
import 'package:isave/globals.dart' as globals;

import 'package:intl/intl.dart';

class EditTransaction extends StatefulWidget {
  final Transaction transaction;
  const EditTransaction({super.key, required this.transaction});

  @override
  State<EditTransaction> createState() => _EditTransactionState();
}

class _EditTransactionState extends State<EditTransaction> with RestorationMixin{
  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    DateTime now = DateTime.now();
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: "date_picker_dialog",
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime(now.year, now.month, 1),
          lastDate: DateTime(2100),
        );
      },
    );
  }

  final RestorableDateTime selectedDate = RestorableDateTime(DateTime.now());
  final TextEditingController amountController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController memoController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController walletController = TextEditingController();

  late final RestorableRouteFuture _restorableDatePickerRouteFuture = RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  late List<String>? selectedList = widget.transaction.type == TransactionType.income
    ? globals.incomeCategories
    : globals.expenseCategories;
  late String selectedCategory = widget.transaction.type == TransactionType.income
    ? globals.incomeCategories!.first
    : globals.expenseCategories!.first;

  Wallet selectedWallet = globals.currentAccount!.wallets[0];

  @override
  String? get restorationId => "edit";

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(selectedDate, "selected_date");
    registerForRestoration(
      _restorableDatePickerRouteFuture,
      "date_picker_route_future"
    );
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        selectedDate.value = newSelectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        centerTitle: false,
        title: const Text("Edit Transaction"),
      ),
      body: Container(
        height: double.infinity,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ISaveDropdown(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _restorableDatePickerRouteFuture.present();
                  },
                  child: Text(
                    "Date: ${DateFormat("dd/MM/yyyy").format(selectedDate.value)}",
                  ),
                ),
                const SizedBox(height: 20),
                ISaveTextField(
                  labelText: "Amount",
                  hintText: "e. g. 60",
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 10),
                    child: Text("${globals.currentAccount!.currency.symbol} ", style: const TextStyle(fontSize: 15)),
                  )
                ),
                const SizedBox(height: 20),
                ISaveTextField(
                  labelText: "Title",
                  hintText: "Short title",
                  controller: titleController,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 20),
                ISaveTextField(
                  labelText: "Memo",
                  hintText: "Give yourself a note",
                  controller: memoController,
                  keyboardType: TextInputType.text,
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
                  controller: walletController,
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
                DropdownMenu(
                  inputDecorationTheme: InputDecorationTheme(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(width: 1, color: Color.fromRGBO(0, 0, 0, 0.15)),
                    ),
                  ),
                  label: const Text("Category"),
                  controller: categoryController,
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
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();

                      if (titleController.text.isEmpty) {
                        Utilities.showSnackbar(
                          isSuccess: false,
                          title: "Error!",
                          description: "Please type in a title!"
                        );
                        return;
                      } else if (amountController.text.isEmpty) {
                        Utilities.showSnackbar(
                          isSuccess: false,
                          title: "Error!",
                          description: "Please type in an amount!"
                        );
                        return;
                      }

                      Utilities.showLoadingDialog(context);

                      Future.wait([
                        Utilities.removeTransaction(widget.transaction),
                        Utilities.addTransaction(
                          context,
                          Transaction(
                            id: widget.transaction.id,
                            amount: double.parse(amountController.text),
                            title: titleController.text,
                            currency: globals.currentAccount!.currency,
                            type: widget.transaction.type,
                            date: DateTime(
                              selectedDate.value.year,
                              selectedDate.value.month,
                              selectedDate.value.day
                            ),
                            category: selectedCategory,
                            memo: Memo(
                              id: widget.transaction.memo.id,
                              content: memoController.text,
                              images: widget.transaction.memo.images
                            ),
                            wallet: selectedWallet
                          )
                        )
                      ]).then((value) {
                        Utilities.showSnackbar(
                          isSuccess: true,
                          title: "Success!",
                          description: "Successfully added transaction."
                        );
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const MainPage()),
                          (route) => false
                        );
                      });
                    },
                    style: globals.defaultButtonStyle,
                    child: const Text("Edit"),
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