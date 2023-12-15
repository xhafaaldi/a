import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/globals.dart' as globals;
import 'package:isave/pages/main/main_page.dart';
import 'package:isave/pages/main/settings/change_account/create_account.dart';
import 'package:isave/utilities/models/account.dart';

import 'package:get/get.dart';
import 'package:isave/utilities/utilities.dart';
import 'package:isave/widgets/isave_card.dart';

class ChangeAccount extends StatefulWidget {
  const ChangeAccount({super.key});

  @override
  State<ChangeAccount> createState() => _ChangeAccountState();
}

class _ChangeAccountState extends State<ChangeAccount> {
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
            Text("Accounts",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),),
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
            padding: const EdgeInsets.all(10),
            child: ListView.builder(
              itemCount: globals.accounts!.length,
              itemBuilder: (BuildContext context, int index) {
                Account account = globals.accounts![index];
                bool isCurrentAccount = globals.currentAccount!.id == account.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ISaveCard(
                    title: account.name,
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Balance: ${Utilities.formatNumber(Utilities.calculateBalance(account))}${account.currency.symbol}",
                            ),
                            if (isCurrentAccount)
                              const Icon(CupertinoIcons.check_mark_circled_solid)
                          ],
                        )
                      ],
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (!isCurrentAccount) {
                        Utilities.switchAccounts(account);
                        Utilities.showSnackbar(
                          isSuccess: true,
                          title: "Success!",
                          description: "Successfully changed accounts."
                        );
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainPage()
                          ),
                          (route) => false
                        );
                      }
                    },
                  )
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(CupertinoIcons.add),
        onPressed: () {
          HapticFeedback.selectionClick();
          Get.to(() => const CreateAccount())!.then((_) => setState(() {}));
        },
      ),
    );
  }
}