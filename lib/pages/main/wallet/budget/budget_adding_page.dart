import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/utilities/models/budget.dart';
import 'package:isave/utilities/models/enums/recurring_type.dart';
import 'package:isave/utilities/utilities.dart';
import 'package:isave/globals.dart' as globals;
import 'package:isave/widgets/isave_dropdown.dart';
import 'package:isave/widgets/isave_textfield.dart';

import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class BudgetAddingPage extends StatefulWidget {
  const BudgetAddingPage({super.key});

  @override
  State<BudgetAddingPage> createState() => _BudgetAddingPageState();
}

class _BudgetAddingPageState extends State<BudgetAddingPage> with RestorationMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final RestorableDateTime selectedDate = RestorableDateTime(DateTime.now());

  late final RestorableRouteFuture _restorableDatePickerRouteFuture = RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  bool recurring = false;
  RecurringType recurringType = RecurringType.none;

  @override
  String? get restorationId => "debt";

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
          initialDate: DateTime(now.year, now.month, now.day + 1),
          firstDate: DateTime(now.year, now.month, now.day + 1),
          lastDate: DateTime(2100),
        );
      },
    );
  }

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
            Text("Add Budget",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),),
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
            padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: !recurring,
                  child: Column(
                    children: [
                      ISaveDropdown(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          _restorableDatePickerRouteFuture.present();
                        },
                        child: Text(
                          "Target Date: ${DateFormat("dd/MM/yyyy").format(selectedDate.value)}",
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                ISaveTextField(
                  controller: nameController,
                  hintText: "Give your budget a name...",
                  labelText: "Name",
                ),
                const SizedBox(height: 20),
                ISaveTextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 10),
                    child: Text("${globals.currentAccount!.currency.symbol} ", style: const TextStyle(fontSize: 15)),
                  ),
                  labelText: "Amount",
                  hintText: "e. g. 60",
                ),
                const SizedBox(height: 10),
                const Text("Recurring", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Switch(
                      value: recurring,
                      activeColor: Colors.blueGrey,
                      onChanged: (bool value) {
                        setState(() {
                          recurring = value;
                          if (!value) {
                            recurringType = RecurringType.none;
                          }
                        });
                      },
                    ),
                    Visibility(
                      visible: recurring,
                      child: Row(
                        children: [
                          DropdownMenu(
                            initialSelection: RecurringType.none,
                            onSelected: (RecurringType? value) {
                              setState(() {
                                recurringType = value!;
                              });
                            },
                            dropdownMenuEntries: RecurringType.values.map<DropdownMenuEntry<RecurringType>>((RecurringType value) {
                              return DropdownMenuEntry<RecurringType>(value: value, label: value.name.capitalizeFirst!);
                            }).toList(),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat("dd/MM/yyyy").format(Utilities.calculateSelectedDate(
                              recurringType,
                              selectedDate.value
                            )),
                            style: const TextStyle(fontSize: 18),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      HapticFeedback.selectionClick();
                      if (nameController.text.isEmpty) {
                        Utilities.showSnackbar(
                          isSuccess: false,
                          title: "Error!",
                          description: "Please type in a name!"
                        );
                        return;
                      } else if (amountController.text.isEmpty) {
                        Utilities.showSnackbar(
                          isSuccess: false,
                          title: "Error!",
                          description: "Please type in an amount!"
                        );
                        return;
                      } else {
                        await Utilities.createBudget(Budget(
                          id: const Uuid().v4(),
                          creationDate: DateTime.now(),
                          untilDate: Utilities.calculateSelectedDate(
                            recurringType,
                            selectedDate.value
                          ),
                          name: nameController.text,
                          amount: double.parse(amountController.text),
                          totalSpent: 0,
                          recurring: recurring,
                          recurringType: recurringType
                        ));

                        if (mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    style: globals.defaultButtonStyle,
                    child: const Text("Add"),
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