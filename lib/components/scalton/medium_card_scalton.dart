import 'package:flutter/material.dart';

import '../scalton/scalton_line.dart';
import '../scalton/scalton_rounded_container.dart';

class MediumCardScalton extends StatelessWidget {
  const MediumCardScalton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 160, // Fixed height instead of aspect ratio
            child: const ScaltonRoundedContainer(),
          ),
          const SizedBox(height: 16),
          const ScaltonLine(width: 150),
          const SizedBox(height: 16),
          const ScaltonLine(),
          const SizedBox(height: 16),
          const ScaltonLine(),
        ],
      ),
    );
  }
}
