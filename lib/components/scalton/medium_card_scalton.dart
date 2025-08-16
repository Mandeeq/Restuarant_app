import 'package:flutter/material.dart';

import '../scalton/scalton_line.dart';
import '../scalton/scalton_rounded_container.dart';

class MediumCardScalton extends StatelessWidget {
  const MediumCardScalton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160, // Fixed height instead of aspect ratio
            child: ScaltonRoundedContainer(),
          ),
          SizedBox(height: 16),
          ScaltonLine(width: 150),
          SizedBox(height: 16),
          ScaltonLine(),
          SizedBox(height: 16),
          ScaltonLine(),
        ],
      ),
    );
  }
}
