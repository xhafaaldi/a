import 'package:flutter/material.dart';

class ISaveDropdown extends StatelessWidget {
  final Function() onPressed;
  final Widget child;
  const ISaveDropdown({
    super.key,
    required this.onPressed,
    required this.child
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
        foregroundColor: MaterialStateProperty.all(Colors.black),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        )),
        side: MaterialStateProperty.all(const BorderSide(
          width: 1,
          color: Color.fromRGBO(0, 0, 0, 0.5),
        )),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            child,
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}