import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class MomentiHeroImage extends StatelessWidget {
  const MomentiHeroImage({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Image.network(
        imageUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
