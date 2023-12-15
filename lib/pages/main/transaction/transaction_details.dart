import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/pages/main/transaction/edit_transaction.dart';
import 'package:isave/utilities/models/enums/transaction_type.dart';
import 'package:isave/utilities/models/transaction.dart';
import 'package:isave/utilities/utilities.dart';
import 'package:isave/widgets/isave_card.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class TransactionDetails extends StatefulWidget {
  final Transaction transaction;
  const TransactionDetails({super.key, required this.transaction});

  @override
  State<TransactionDetails> createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    BannerAd(
      adUnitId: "ca-app-pub-1532914256578614/4645829191",
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        title: const Text("Transaction"),
        actions: [
          if (widget.transaction.type != TransactionType.transfer)
            IconButton(
              icon: const Icon(CupertinoIcons.pencil),
              onPressed: () {
                HapticFeedback.selectionClick();
                Get.to(() => EditTransaction(transaction: widget.transaction));
              },
            ),
          IconButton(
            icon: const Icon(CupertinoIcons.delete),
            onPressed: () {
              HapticFeedback.selectionClick();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                      "Are you sure?",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                    ),
                    backgroundColor: Colors.red,
                    content: const Text(
                      "This action cannot be undone.",
                      style: TextStyle(color: Colors.white)
                    ),
                    actions: [
                      ElevatedButton(onPressed: () {
                        HapticFeedback.selectionClick();
                        Utilities.removeTransaction(widget.transaction);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }, child: const Text("Yes", style: TextStyle(color: Colors.red))),
                      ElevatedButton(onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.pop(context);
                      }, child: const Text("No", style: TextStyle(color: Colors.red)))
                    ],
                  );
                }
              );
            },
          )
        ],
      ),
      body: Container(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 25),
            child: Column(
              children: [
                Utilities.displayBanner(_bannerAd),
                const SizedBox(height: 5),
                ISaveCard(
                  onTap: () {},
                  title: widget.transaction.title,
                  body: Column(
                      children: [
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(widget.transaction.category)
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Amount", style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                    "${widget.transaction.currency.symbol}${Utilities.formatNumber(
                                        widget.transaction.amount)
                                    }",
                                    style: TextStyle(color: Utilities.transactionColor(widget.transaction.type))
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 15,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Date:", style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 10,),
                            Text(
                              DateFormat("dd/MM/yyyy").format(widget.transaction.date),
                            )
                          ],
                        ),
                        SizedBox(height: 8,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Wallet:", style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 10,),
                            Text(
                                widget.transaction.wallet.name
                            )
                          ],
                        ),
                        SizedBox(height: 8,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Type:", style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 10,),
                            Text(
                                widget.transaction.type.name.capitalizeFirst!
                            )
                          ],
                        ),
                        SizedBox(height: 8,),
                        if (widget.transaction.memo.content.isNotEmpty)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Memo:", style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(width: 10,),
                              Text(
                                  widget.transaction.memo.content
                              )
                            ],
                          ),
                        if (widget.transaction.memo.images.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Images", style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.transaction.memo.images.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return GestureDetector(
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          showGeneralDialog(
                                              context: context,
                                              pageBuilder: (BuildContext context, _, __) {
                                                return Container(
                                                  decoration: const BoxDecoration(
                                                      color: Colors.black87
                                                  ),
                                                  child: SafeArea(
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(10),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          IconButton(
                                                            onPressed: () => Navigator.pop(context),
                                                            iconSize: 30,
                                                            icon: const Icon(
                                                              Icons.cancel_outlined,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                          CachedNetworkImage(
                                                            imageUrl: widget.transaction.memo.images[index],
                                                            fit: BoxFit.fitHeight,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                          );
                                        },
                                        child: CachedNetworkImage(
                                          imageUrl: widget.transaction.memo.images[index],
                                        )
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        if (widget.transaction.type == TransactionType.transfer)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("From Wallet", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                  widget.transaction.fromWallet!.name
                              )
                            ],
                          ),
                        if (widget.transaction.type == TransactionType.transfer)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("To Wallet", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                  widget.transaction.toWallet!.name
                              )
                            ],
                          )
                      ]
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}