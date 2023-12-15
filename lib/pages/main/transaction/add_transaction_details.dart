import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/pages/main/transaction/transaction_details.dart';
import 'package:isave/utilities/models/enums/transaction_type.dart';
import 'package:isave/utilities/models/memo.dart';
import 'package:isave/utilities/models/transaction_template.dart';
import 'package:isave/utilities/models/wallet.dart';
import 'package:isave/utilities/utilities.dart';
import 'package:isave/globals.dart' as globals;
import 'package:isave/utilities/models/transaction.dart';
import 'package:isave/widgets/isave_dropdown.dart';
import 'package:isave/widgets/isave_textfield.dart';
import 'package:isave/widgets/transaction/transaction_template_card.dart';

import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddTransactionDetails extends StatefulWidget {
  final String? restorationId;
  final TransactionType type;

  const AddTransactionDetails({super.key, required this.type, required this.restorationId});

  @override
  State<AddTransactionDetails> createState() => _AddTransactionDetailsState();
}

class _AddTransactionDetailsState extends State<AddTransactionDetails> with RestorationMixin {
  final RestorableDateTime selectedDate = RestorableDateTime(DateTime.now());
  final TextEditingController amountController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController memoController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController walletController = TextEditingController();
  late final RestorableRouteFuture _restorableDatePickerRouteFuture = RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );
  late List<String>? selectedList = widget.type == TransactionType.income
      ? globals.incomeCategories
      : globals.expenseCategories;
  late String selectedCategory = widget.type == TransactionType.income
      ? globals.incomeCategories!.first
      : globals.expenseCategories!.first;

  Wallet selectedWallet = globals.currentAccount!.wallets[0];
  Wallet selectedToWallet = globals.currentAccount!.wallets[0];
  Wallet selectedFromWallet = globals.currentAccount!.wallets[0];
  List<Uint8List> selectedMemoImages = [];

  @override
  String? get restorationId => widget.restorationId;

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
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime(now.year, now.month, 1),
          lastDate: DateTime(2100),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double dropdownWidth = (MediaQuery.of(context).size.width / 2) - 15;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ISaveDropdown(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _restorableDatePickerRouteFuture.present();
                  },
                  child: Text(
                    "Date: ${DateFormat("dd/MM/yyyy").format(selectedDate.value)}",
                  ),
                ),
                const SizedBox(height: 20),
                ISaveTextField(
                  labelText: "Amount",
                  hintText: "e. g. 60",
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 10),
                    child: Text("${globals.currentAccount!.currency.symbol} ", style: const TextStyle(fontSize: 15)),
                  )
                ),
                const SizedBox(height: 20),
                ISaveTextField(
                  labelText: "Title",
                  hintText: "Short title",
                  controller: titleController,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 20),
                ISaveTextField(
                  labelText: "Memo",
                  hintText: "Give yourself a note",
                  controller: memoController,
                  keyboardType: TextInputType.text,
                  suffixIcon: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      if (!globals.isPremium! && selectedMemoImages.length == 1) {
                        Utilities.showSnackbar(
                          isSuccess: false,
                          title: "Error!",
                          description: "In order to select up to 3 images, you need premium!"
                        );
                      } else {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              padding: const EdgeInsets.all(15),
                              width: double.infinity,
                              height: 200,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10)
                                ),
                              ),
                              child: SafeArea(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: TextButton.icon(
                                        onPressed: () async {
                                          HapticFeedback.selectionClick();
                                          Utilities.showLoadingDialog(context);
                                          Utilities.selectImage(ImageSource.gallery).then((img) async {
                                            Navigator.pop(context);
                                            Navigator.pop(context);

                                            if (img != null) {
                                              selectedMemoImages.add(await img.readAsBytes());
                                              setState(() {});
                                            }
                                          });
                                        },
                                        style: globals.defaultButtonStyle,
                                        icon: const Icon(Icons.image),
                                        label: const Text("Upload from Gallery"),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: TextButton.icon(
                                        onPressed: () async {
                                          HapticFeedback.selectionClick();
                                          Utilities.showLoadingDialog(context);
                                          Utilities.selectImage(ImageSource.camera).then((img) async {
                                            Navigator.pop(context);
                                            Navigator.pop(context);

                                            if (img != null) {
                                              selectedMemoImages.add(await img.readAsBytes());
                                              setState(() {});
                                            }
                                          });
                                        },
                                        style: globals.defaultButtonStyle,
                                        icon: const Icon(Icons.camera_alt_outlined),
                                        label: const Text("Take with Camera"),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                        );
                      }
                    },
                    icon: const Icon(CupertinoIcons.camera_circle_fill, size: 32),
                  ),
                ),
                const SizedBox(height: 20),
                if (selectedMemoImages.isNotEmpty)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: selectedMemoImages.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Image.memory(selectedMemoImages[index]),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(8),
                                      icon: const Icon(
                                        CupertinoIcons.delete,
                                        color: Colors.red,
                                        size: 17,
                                      ),
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(Colors.white)
                                      ),
                                      onPressed: () {
                                        HapticFeedback.selectionClick();
                                        setState(() {
                                          selectedMemoImages.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        ),
                      ),
                      const SizedBox(height: 20)
                    ],
                  ),
                if (widget.type == TransactionType.transfer)
                  Wrap(
                    spacing: 10,
                    children: [
                      DropdownMenu(
                        width: dropdownWidth,
                        label: const Text("From Wallet"),
                        inputDecorationTheme: InputDecorationTheme(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(width: 1, color: Color.fromRGBO(0, 0, 0, 0.15)),
                          ),
                        ),
                        initialSelection: globals.currentAccount!.wallets.first,
                        onSelected: (Wallet? value) {
                          setState(() {
                            selectedFromWallet = value!;
                          });
                        },
                        dropdownMenuEntries: globals.currentAccount!.wallets.map<DropdownMenuEntry<Wallet>>((Wallet value) {
                          return DropdownMenuEntry<Wallet>(value: value, label: value.name);
                        }).toList(),
                      ),
                      DropdownMenu(
                        width: dropdownWidth,
                        inputDecorationTheme: InputDecorationTheme(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(width: 1, color: Color.fromRGBO(0, 0, 0, 0.15)),
                          ),
                        ),
                        label: const Text("To Wallet"),
                        initialSelection: globals.currentAccount!.wallets.first,
                        onSelected: (Wallet? value) {
                          setState(() {
                            selectedToWallet = value!;
                          });
                        },
                        dropdownMenuEntries: globals.currentAccount!.wallets.map<DropdownMenuEntry<Wallet>>((Wallet value) {
                          return DropdownMenuEntry<Wallet>(value: value, label: value.name);
                        }).toList(),
                      ),
                    ],
                  ),
                if (widget.type != TransactionType.transfer)
                  Wrap(
                    spacing: 10,
                    children: [
                      DropdownMenu(
                        width: dropdownWidth,
                        inputDecorationTheme: InputDecorationTheme(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(width: 1, color: Color.fromRGBO(0, 0, 0, 0.15)),
                          ),
                        ),
                        label: const Text("Wallet"),
                        controller: walletController,
                        initialSelection: globals.currentAccount!.wallets.first,
                        onSelected: (Wallet? value) {
                          setState(() {
                            selectedWallet = value!;
                          });
                        },
                        dropdownMenuEntries: globals.currentAccount!.wallets.map<DropdownMenuEntry<Wallet>>((Wallet value) {
                          return DropdownMenuEntry<Wallet>(value: value, label: value.name);
                        }).toList(),
                      ),
                      DropdownMenu(
                        width: dropdownWidth,
                        inputDecorationTheme: InputDecorationTheme(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(width: 1, color: Color.fromRGBO(0, 0, 0, 0.15)),
                          ),
                        ),
                        label: const Text("Category"),
                        controller: categoryController,
                        initialSelection: selectedList!.first,
                        onSelected: (String? value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                        dropdownMenuEntries: selectedList!.map<DropdownMenuEntry<String>>((String value) {
                          return DropdownMenuEntry<String>(value: value, label: value);
                        }).toList(),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      HapticFeedback.selectionClick();

                      if (titleController.text.isEmpty) {
                        Utilities.showSnackbar(
                          isSuccess: false,
                          title: "Error!",
                          description: "Please type in a title!"
                        );
                        return;
                      } else if (amountController.text.isEmpty) {
                        Utilities.showSnackbar(
                          isSuccess: false,
                          title: "Error!",
                          description: "Please type in an amount!"
                        );
                        return;
                      } else if (selectedFromWallet.id == selectedToWallet.id && widget.type == TransactionType.transfer) {
                        Utilities.showSnackbar(
                          isSuccess: false,
                          title: "Error!",
                          description: "You cannot transfer money from a wallet to the same one!"
                        );
                        return;
                      }

                      Utilities.showLoadingDialog(context);

                      String transactionId = const Uuid().v4();
                      List<String> selectedImages = [];

                      for (Uint8List image in selectedMemoImages) {
                        selectedImages.add((await Utilities.uploadFile(
                          "transactions/$transactionId/${selectedMemoImages.indexOf(image)}",
                          image
                        ))!);
                      }

                      Transaction transaction = Transaction(
                        id: transactionId,
                        amount: double.parse(amountController.text),
                        title: titleController.text,
                        currency: globals.currentAccount!.currency,
                        type: widget.type,
                        date: DateTime(
                          selectedDate.value.year,
                          selectedDate.value.month,
                          selectedDate.value.day
                        ),
                        wallet: selectedWallet,
                        toWallet: selectedToWallet,
                        fromWallet: selectedFromWallet,
                        memo: Memo(
                          id: const Uuid().v4(),
                          content: memoController.text,
                          images: selectedImages
                        ),
                        category: widget.type != TransactionType.transfer
                          ? selectedCategory
                          : "Transfer"
                      );

                      if (mounted) {
                        Utilities.addTransaction(
                          context,
                          transaction
                        ).then((value) {
                          Navigator.pop(context);
                          Utilities.showSnackbar(
                            isSuccess: true,
                            title: "Success!",
                            description: "Successfully added transaction."
                          );
                          Get.to(() => TransactionDetails(transaction: transaction));
                        });
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
      floatingActionButton: widget.type != TransactionType.transfer
        ? FloatingActionButton(
        child: const Icon(CupertinoIcons.rectangle_paperclip),
        onPressed: () {
          HapticFeedback.selectionClick();
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return SafeArea(
                child: Container(
                  height: MediaQuery.of(context).size.height / 2,
                  padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10)
                    )
                  ),
                  child: buildTemplates()
                ),
              );
            }
          );
        }
      ) : null,
    );
  }

  Widget buildTemplates() {
    List<TransactionTemplate> transactionTemplates = globals.currentAccount!.transactionTemplates;
    List<TransactionTemplate> typedTemplates = [];

    typedTemplates.addAll(transactionTemplates.where((t) => t.transactionType == widget.type));

    if (typedTemplates.isEmpty) {
      return const Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "No Record",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              )
            ),
            Text("Go to the Settings page to create templates"),
          ],
        ),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: typedTemplates.length,
        itemBuilder: (BuildContext context, int index) {
          TransactionTemplate template = typedTemplates[index];

          return TransactionTemplateCard(
            template: template,
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context);
              setState(() {
                titleController.text = template.title;
                amountController.text = template.amount.toString();
                selectedCategory = template.category;
                categoryController.text = template.category;
                selectedWallet = template.wallet;
                walletController.text = template.wallet.name;
                memoController.text = template.memo.content;
              });
            },
          );
        },
      );
    }
  }
}
