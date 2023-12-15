import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/utilities/models/enums/wallet_type.dart';
import 'package:isave/utilities/models/wallet.dart';
import 'package:isave/utilities/utilities.dart';
import 'package:isave/globals.dart' as globals;
import 'package:isave/widgets/isave_textfield.dart';
import 'package:isave/utilities/models/enums/credit_card_type.dart';

import 'package:uuid/uuid.dart';

class WalletAddingPage extends StatefulWidget {
  const WalletAddingPage({super.key});

  @override
  State<WalletAddingPage> createState() => _WalletAddingPageState();
}

class _WalletAddingPageState extends State<WalletAddingPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  WalletType selectedType = WalletType.general;
  CreditCardType selectedCardType = CreditCardType.other;

  Color selectedColor = Colors.blue;
  final List<Color> colors = [
    Colors.lightBlue,
    Colors.blue,
    Colors.greenAccent,
    Colors.green,
    Colors.redAccent,
    Colors.red,
    Colors.orangeAccent,
    Colors.orange,
    Colors.deepOrangeAccent,
    Colors.deepOrange
  ];

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
           Text("Add Wallet",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),),
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
           padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 25),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const SizedBox(height: 10),
               ISaveTextField(
                 controller: nameController,
                 maxLength: 30,
                 hintText: "Wallet's Name",
                 labelText: "Name",
               ),
               DropdownMenu(
                 inputDecorationTheme: InputDecorationTheme(
                   border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(10),
                     borderSide: const BorderSide(width: 1, color: Color.fromRGBO(0, 0, 0, 0.15)),
                   ),
                 ),
                 label: const Text("Type"),
                 initialSelection: WalletType.general,
                 onSelected: (WalletType? value) {
                   setState(() {
                     selectedType = value!;
                   });
                 },
                 dropdownMenuEntries: WalletType.values.map<DropdownMenuEntry<WalletType>>((WalletType value) {
                   return DropdownMenuEntry<WalletType>(value: value, label: value.value);
                 }).toList(),
               ),
               const SizedBox(height: 20),
               ISaveTextField(
                 controller: amountController,
                 maxLength: 30,
                 labelText: "Initial Amount",
                 hintText: "e. g. 60",
                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
                 prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                 prefixIcon: Padding(
                   padding: const EdgeInsets.only(left: 20, right: 10),
                   child: Text("${globals.currentAccount!.currency.symbol} ", style: const TextStyle(fontSize: 15)),
                 )
               ),
               const Text("Color", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
               DropdownButton<Color>(
                 underline: const SizedBox(),
                 value: selectedColor,
                 onChanged: (color) {
                   setState(() {
                     selectedColor = color!;
                   });
                 },
                 items: colors.map((e) => DropdownMenuItem(
                   value: e,
                   child: Container(
                     decoration: BoxDecoration(
                       color: e,
                       borderRadius: BorderRadius.circular(10)
                     ),
                     width: MediaQuery.of(context).size.width - 150,
                     height: 40,
                   ),
                 ),
               ).toList()),
               const SizedBox(height: 20),
               if (selectedType == WalletType.creditCard)
                 buildCardTypeSelector(),
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
                     }

                     await Utilities.createWallet(Wallet(
                       id: const Uuid().v4(),
                       name: nameController.text,
                       amount: amountController.text.isNotEmpty
                         ? double.parse(amountController.text)
                         : 0,
                       color: selectedColor,
                       currency: globals.currentAccount!.currency,
                       type: selectedType,
                       creditCardType: selectedType == WalletType.creditCard ? selectedCardType : null
                     ));

                     Navigator.pop(context);
                   },
                   style: globals.defaultButtonStyle,
                   child: const Text("Add Wallet")
                 ),
               )
             ],
           ),
         ),
       ),
     ),
   );
  }

  Widget buildCardTypeSelector() {
    return DropdownMenu(
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(width: 1, color: Color.fromRGBO(0, 0, 0, 0.15)),
        ),
      ),
      label: const Text("Credit Card Type"),
      initialSelection: CreditCardType.other,
      onSelected: (CreditCardType? value) {
        setState(() {
          selectedCardType = value!;
        });
      },
      dropdownMenuEntries: CreditCardType.values.map<DropdownMenuEntry<CreditCardType>>((CreditCardType value) {
        return DropdownMenuEntry<CreditCardType>(value: value, label: value.value);
      }).toList(),
    );
  }
}