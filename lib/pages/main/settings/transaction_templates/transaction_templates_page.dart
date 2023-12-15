import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/utilities/models/transaction_template.dart';
import 'package:isave/globals.dart' as globals;
import 'package:isave/widgets/transaction/transaction_template_card.dart';
import 'package:isave/pages/main/settings/transaction_templates/create_transaction_template.dart';

import 'package:get/get.dart';

class TransactionTemplatesPage extends StatefulWidget {
  const TransactionTemplatesPage({super.key});

  @override
  State<TransactionTemplatesPage> createState() => _TransactionTemplatesPageState();
}

class _TransactionTemplatesPageState extends State<TransactionTemplatesPage> {
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
            Text("Transaction Templates",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
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
        child: SafeArea(child: buildTemplates())
      ),
      floatingActionButton: FloatingActionButton(
        child: const Text("Add"),
        onPressed: () {
          HapticFeedback.selectionClick();
          Get.to(() => const CreateTransactionTemplate())!.then((_) => setState(() {}));
        },
      ),
    );
  }

  Widget buildTemplates() {
    List<TransactionTemplate> transactionTemplates = globals.currentAccount!.transactionTemplates;

    if (transactionTemplates.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "No Record",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                )
              ),
              Text("Tap the + button to add your first template."),
            ],
          ),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: transactionTemplates.length,
        itemBuilder: (BuildContext context, int index) {
          return TransactionTemplateCard(template: transactionTemplates[index]);
        },
      );
    }
  }
}