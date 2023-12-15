library isave.globals;

import 'package:flutter/material.dart';
import 'package:isave/utilities/models/account.dart';

List<String>? incomeCategories;
List<String>? expenseCategories;
Account? currentAccount;
List<Account>? accounts;
bool? isPremium;
Color disabledButtonColor = const Color(0xffa9dcf8);
Color enabledButtonColor = const Color(0xff5cc0fa);
Brightness? selectedBrightness;
ButtonStyle defaultButtonStyle = ButtonStyle(
  backgroundColor: MaterialStateProperty.all(const Color(0xFF2F80ED)),
  foregroundColor: MaterialStateProperty.all(Colors.white),
  textStyle: MaterialStateProperty.all(const TextStyle(fontWeight: FontWeight.w700)),
  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 15)),
  shape: MaterialStateProperty.all(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  elevation: MaterialStateProperty.all(0),
);