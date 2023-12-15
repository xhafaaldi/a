import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isave/utilities/utilities.dart';

import 'package:isave/widgets/isave_card.dart';
import 'package:isave/widgets/premium_row.dart';
import 'package:isave/globals.dart' as globals;

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription _subscription;

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        Utilities.showLoadingDialog(context);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        Navigator.pop(context);
        Utilities.showSnackbar(
          isSuccess: false,
          title: "Error!",
          description: "There was an error while processing your purchase."
        );
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        bool valid = await checkPurchaseValidity(purchaseDetails);
        if (mounted) {
          Navigator.pop(context);
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();

        if (valid) {
          globals.isPremium = true;
          await prefs.setBool("premium", true);
          Utilities.showSnackbar(
            isSuccess: true,
            title: "Success!",
            description: "Thank you for your purchase!"
          );
        } else {
          globals.isPremium = false;
          await prefs.setBool("premium", false);
          Utilities.showSnackbar(
            isSuccess: false,
            title: "Error!",
            description: "We couldn't process your payment."
          );
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<bool> checkPurchaseValidity(PurchaseDetails purchaseDetails) async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  Future<void> _restorePurchases() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      await _inAppPurchase.restorePurchases();
    } catch (error) {
      debugPrint("Error restoring purchases: $error");
      Utilities.showSnackbar(
        isSuccess: false,
        title: "Error!",
        description: "There was an error while restoring your purchase. $error"
      );
      await prefs.setBool("premium", false);
    }
  }

  @override
  void initState() {
    final Stream purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      debugPrint(error.toString());
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
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
            Text("Premium",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),),
          ],
        ),
        leadingWidth: 0,
        toolbarHeight: 60,
        leading: Container(),
      ),
      body: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20),)
        ),
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SafeArea(
            child: ISaveCard(
              title: "Pay now, use forever!",
              body: Column(
                children: [
                  const Divider(),
                  const PremiumRow(
                    icon: Icon(Icons.fingerprint, size: 29, color: Colors.blue),
                    title: "Biometrics Unlock",
                    description: "You can use FaceID or TouchID to unlock iSave."
                  ),
                  const SizedBox(height: 10),
                  const PremiumRow(
                    icon: Icon(Icons.remove_circle_outlined, size: 29, color: Colors.red),
                    title: "No Ads",
                    description: "Remove and enjoy the app without annoying advertisement."
                  ),
                  const SizedBox(height: 10),
                  const PremiumRow(
                    icon: Icon(CupertinoIcons.moon_fill, size: 28, color: Colors.black),
                    title: "Dark Mode",
                    description: "Gives a new look and reduces eye strain on the bright screen."
                  ),
                  const SizedBox(height: 10),
                  const PremiumRow(
                    icon: Icon(CupertinoIcons.rectangle_fill_on_rectangle_angled_fill, size: 28, color: Colors.lightGreen),
                    title: "More Photos",
                    description: "Add up to three images for each transaction memo."
                  ),
                  const SizedBox(height: 10),
                  const PremiumRow(
                    icon: Icon(CupertinoIcons.lightbulb_fill, size: 28, color: Colors.orangeAccent),
                    title: "Unlimited Features",
                    description: "Unlock and enjoy all the app features without any restrictions."
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: ElevatedButton(
                          onPressed: () async {
                            HapticFeedback.selectionClick();
                            await _inAppPurchase.buyNonConsumable(
                              purchaseParam: PurchaseParam(productDetails: ProductDetails(
                                id: "isavepremium",
                                title: "Premium",
                                description: "Access all the locked features with premium!",
                                currencyCode: "USD",
                                price: "\$1.99",
                                rawPrice: 1.99
                              ), applicationUserName: "iSave"));
                          },
                          child: const Text("Buy Now, \$1.99")),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            _restorePurchases();
                          },
                          child: const Text(
                            "Restore Purchases",
                            textAlign: TextAlign.center,
                            style: TextStyle(height: 1.07),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              onTap: () {},
            ),
          ),
        ),
      ),
    );
  }
}