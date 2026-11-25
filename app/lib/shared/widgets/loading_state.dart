import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A thin black spinner in the middle of the free space, while data is on its
/// way.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: context.palette.black,
        strokeWidth: 2,
      ),
    );
  }
}
