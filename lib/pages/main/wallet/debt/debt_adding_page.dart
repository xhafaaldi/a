import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/utilities/models/debt.dart';
import 'package:isave/utilities/utilities.dart';
import 'package:isave/globals.dart' as globals;
import 'package:isave/widgets/isave_dropdown.dart';
import 'package:isave/widgets/isave_textfield.dart';

import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class DebtAddingPage extends StatefulWidget {
  const DebtAddingPage({super.key});

  @override
  State<DebtAddingPage> createState() => _DebtAddingPageState();
}

class _DebtAddingPageState extends State<DebtAddingPage> with RestorationMixin {
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

  @override
  String? get restorationId => "debt";

  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: "date_picker_dialog",
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime.now(),
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
            Text("Add Debt",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),),
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
                const SizedBox(height: 20),
                ISaveTextField(
                  controller: nameController,
                  hintText: "Give your debt a name...",
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
                        await Utilities.createDebt(Debt(
                          id: const Uuid().v4(),
                          creationDate: DateTime.now(),
                          targetDate: selectedDate.value,
                          name: nameController.text,
                          amount: double.parse(amountController.text)
                        ));

                        if (mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    style: globals.defaultButtonStyle,
                    child: const Text("Add"),
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