import 'package:flutter/material.dart';

import 'package:isave/utilities/models/transaction.dart';
import 'package:isave/utilities/utilities.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';

class TransactionDataSource extends CalendarDataSource {
  TransactionDataSource(List<Transaction> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].date;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].date;
  }

  @override
  String getSubject(int index) {
    return appointments![index].title;
  }

  @override
  Color getColor(int index) {
    return Utilities.transactionColor(appointments![index].type);
  }

  @override
  String getNotes(int index) {
    return appointments![index].id;
  }

  @override
  bool isAllDay(int index) {
    return false;
  }
}