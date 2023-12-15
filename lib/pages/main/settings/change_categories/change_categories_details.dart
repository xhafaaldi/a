import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:isave/globals.dart' as globals;
import 'package:isave/utilities/utilities.dart';

class ChangeCategoriesDetails extends StatefulWidget {
  final List<String> categories;
  const ChangeCategoriesDetails({super.key, required this.categories});

  @override
  State<ChangeCategoriesDetails> createState() => _ChangeCategoriesDetailsState();
}

class _ChangeCategoriesDetailsState extends State<ChangeCategoriesDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10)
        ),
        child: ListView.separated(
          itemCount: widget.categories.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              padding: const EdgeInsets.only(bottom: 5, top: 5, left: 10, right: 10),
              child: Row(
                children: [
                  Text(
                    widget.categories[index],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  IconButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (widget.categories == globals.incomeCategories!) {
                          globals.incomeCategories!.removeAt(index);
                          Utilities.setStringList(
                            key: "incomeCategories",
                            value: globals.incomeCategories!
                          );
                        } else {
                          globals.expenseCategories!.removeAt(index);
                          Utilities.setStringList(
                            key: "expenseCategories",
                            value: globals.expenseCategories!
                          );
                        }
                      });
                    },
                    icon: const Icon(CupertinoIcons.delete, size: 20)
                  )
                ],
              )
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(height: 1);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Text("New"),
        onPressed: () {
          HapticFeedback.selectionClick();
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              final TextEditingController controller = TextEditingController();
              String selectedCategory = "Income";

              return Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10)
                  )
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              CupertinoIcons.xmark_circle_fill,
                              color: Colors.red,
                              size: 30,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          IconButton(
                            icon: const Icon(
                              CupertinoIcons.plus_app_fill,
                              color: Colors.blueGrey,
                              size: 30,
                            ),
                            onPressed: () {
                              HapticFeedback.selectionClick();

                              if (controller.text.isEmpty) {
                                Utilities.showSnackbar(
                                  isSuccess: false,
                                  title: "Error!",
                                  description: "Please give your category a name!"
                                );
                                return;
                              }

                              if (selectedCategory == "Income") {
                                globals.incomeCategories!.add(controller.text);
                                Utilities.setStringList(
                                  key: "incomeCategories",
                                  value: globals.incomeCategories!
                                );
                              } else {
                                globals.expenseCategories!.add(controller.text);
                                Utilities.setStringList(
                                  key: "expenseCategories",
                                  value: globals.expenseCategories!
                                );
                              }
                              Navigator.pop(context);
                              setState(() {});
                              Utilities.showSnackbar(
                                isSuccess: true,
                                title: "Success!",
                                description: "Added category \"${controller.text}\""
                              );
                            },
                          ),
                        ],
                      ),
                      TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: "Give your category a name"
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownMenu(
                        initialSelection: "Income",
                        onSelected: (String? value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                        dropdownMenuEntries: ["Income", "Expense"].map<DropdownMenuEntry<String>>((String value) {
                          return DropdownMenuEntry<String>(value: value, label: value);
                        }).toList(),
                      )
                    ],
                  ),
                ),
              );
            }
          );
        },
      ),
    );
  }
}