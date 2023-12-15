import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:isave/widgets/drawerwidget.dart';
import 'package:isave/utilities/models/transaction_data_source.dart';
import 'package:isave/globals.dart' as globals;
import 'package:isave/utilities/utilities.dart';
import 'package:isave/utilities/models/transaction.dart';
import 'package:isave/pages/main/transaction/transaction_details.dart';
import 'package:isave/widgets/transaction/transaction_card.dart';

import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:get/get.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final CalendarController controller = CalendarController();
  BannerAd? bannerAd;
  final List<Transaction> _appointmentDetails = <Transaction>[];

  late TransactionDataSource dataSource;

  @override
  void initState() {
    controller.selectedDate = DateTime.now();
    dataSource = TransactionDataSource(globals.currentAccount!.transactions.reversed.toList());
    BannerAd(
      adUnitId: "ca-app-pub-1532914256578614/6273238657",
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint("Failed to load a banner ad: ${err.message}");
          ad.dispose();
        },
      ),
    ).load();
    super.initState();
  }

  void getSelectedDateAppointments(DateTime? selectedDate) {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        _appointmentDetails.clear();
      });

      if (dataSource.appointments!.isEmpty) {
        return;
      }

      for (int i = 0; i < dataSource.appointments!.length; i++) {
        Transaction appointment = dataSource.appointments![i] as Transaction;
        /// It return the occurrence appointment for the given pattern appointment at the selected date.
        final Appointment? occurrenceAppointment = dataSource.getOccurrenceAppointment(appointment, selectedDate!, '');
        if ((DateTime(appointment.date.year, appointment.date.month,
            appointment.date.day) == DateTime(selectedDate.year,selectedDate.month,
            selectedDate.day)) || occurrenceAppointment != null) {
          setState(() {
            _appointmentDetails.add(appointment);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget centerWidget = Center(child: const Text("Nothing found!", style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white)));

    return Scaffold(
      backgroundColor: Color(0xff2436db),
      drawer: getAppDrawer(context),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xff2436db),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Builder(
              builder: (context) {
                return IconButton(
                  icon: Image.asset('assets/icon1.png',),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                );
              }
            ),
            Container(
              height: Get.height * 0.32,
              child: _appointmentDetails.isEmpty ? centerWidget : ListView.separated(
                padding: const EdgeInsets.all(2),
                itemCount: _appointmentDetails.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return TransactionCard(transaction: _appointmentDetails[index],textColor: Colors.white,);
                },
                separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 5,),
              ),
            ),
          ],
        ),
        leadingWidth: 0,
        toolbarHeight: Get.height * 0.4,
        leading: Container(),
      ),
      bottomNavigationBar: StatefulBuilder(builder: (_, __) => Utilities.displayBanner(bannerAd)),
      body: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20),)
        ),
        height: double.infinity,
        child: SfCalendar(
          // allowAppointmentResize: false,
          // controller: controller,
          view: CalendarView.month,
          initialSelectedDate: DateTime.now(),
          dataSource: dataSource,
          cellBorderColor: Colors.transparent,
          headerStyle: CalendarHeaderStyle(textAlign: TextAlign.center,),
          headerHeight: 70,
          // monthViewSettings: const MonthViewSettings(
          //   showAgenda: true,
          // ),
          // onTap: (CalendarTapDetails details) {
          //   if (details.targetElement == CalendarElement.appointment) {
          //     Get.to(() => TransactionDetails(
          //         transaction: details.appointments![0]))!.then((_) => setState(() {})
          //     );
          //   }
          // },
          onSelectionChanged: (calendarSelectionDetails) => getSelectedDateAppointments(calendarSelectionDetails.date),
          // appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
          //   Transaction transaction = details.appointments.first;
          //
          //   return Container(
          //     decoration: BoxDecoration(
          //         color: Utilities.transactionColor(transaction.type),
          //         borderRadius: BorderRadius.circular(5)
          //     ),
          //     padding: const EdgeInsets.all(5),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text(
          //             transaction.title,
          //             style: const TextStyle(
          //                 fontWeight: FontWeight.bold,
          //                 color: Colors.white
          //             )
          //         ),
          //         Text(
          //             "${transaction.wallet.currency.symbol}${transaction.amount.toString()} - ${transaction.category}",
          //             style: const TextStyle(
          //                 color: Colors.white
          //             )
          //         )
          //       ],
          //     ),
          //   );
          // },
        ),
      ),
    );
  }
}