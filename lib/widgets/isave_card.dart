import 'package:flutter/material.dart';

class ISaveCard extends StatelessWidget {
  final String title;
  final Widget body;
  final EdgeInsets? padding;
  final Function() onTap;
  final HitTestBehavior? behavior;
  final Widget? action;
  final Color? backgroundColor;

  const ISaveCard(
      {super.key,
      required this.title,
      required this.body,
      required this.onTap,
      this.padding,
      this.behavior,
      this.action,
      this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: behavior ?? HitTestBehavior.translucent,
      child: Container(
          // padding: padding ?? const EdgeInsets.all(15),
          width: double.infinity,
          // decoration: BoxDecoration(
          //     color: backgroundColor ?? const Color(0xFFF7F7F7),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Color(0x65919191),
          //         spreadRadius: 0.01,
          //         blurRadius: 8,
          //         offset: Offset(0.0, 1),
          //       )
          //     ],
          //     borderRadius: BorderRadius.circular(15),
          //     border: Border.all(color: Color(0xffcccccc), width: 1)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(title.isNotEmpty)
                    Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 22)),
                  if (action != null) action!
                ],
              ),
              body
            ],
          )),
    );
  }
}
