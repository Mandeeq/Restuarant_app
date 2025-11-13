import 'package:flutter/material.dart';

import '../../../theme.dart';

class TotalPrice extends StatelessWidget {
  const TotalPrice({
    super.key,
    required this.price,
  });

  final double price;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text.rich(
          TextSpan(
            text: "Total ",
            style: TextStyle(color: titleColor, fontWeight: FontWeight.w800),
            children: [
              TextSpan(
                text: "(incl. VAT)",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        Text(
          "\Ksh $price",
          style:
              const TextStyle(color: titleColor, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
