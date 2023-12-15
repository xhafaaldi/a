import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

class PremiumRow extends StatelessWidget {
  final Icon icon;
  final String title;
  final String description;

  const PremiumRow({
    super.key,
    required this.icon,
    required this.title,
    required this.description
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        icon,
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              )
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 99,
              child: AutoSizeText(
                description,
                style: const TextStyle(
                  fontSize: 15,
                ),
                maxLines: 10,
                minFontSize: 10,
              ),
            ),
          ],
        )
      ],
    );
  }
}