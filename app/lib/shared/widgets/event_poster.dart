import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';

/// A poster in its 3:4 frame.
///
/// The image is never tinted, never gradient-backed and never cropped shorter
/// than the proportion. While it loads there is a paper rectangle in its place,
/// and if it fails to load the same rectangle carries the event title, so the
/// listing never shows an empty grey block.
class EventPoster extends StatelessWidget {
  const EventPoster({
    super.key,
    required this.imageUrl,
    required this.title,
    this.borderRadius = BorderRadius.zero,
  });

  final String imageUrl;
  final String title;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: AppSizes.posterRatio,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          placeholder: (context, url) => const _PosterPaper(),
          errorWidget: (context, url, error) => _PosterPaper(title: title),
        ),
      ),
    );
  }
}

/// The paper stand-in shown while the poster loads or instead of one that
/// could not be fetched.
class _PosterPaper extends StatelessWidget {
  const _PosterPaper({this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final title = this.title;

    return Container(
      color: palette.rule,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(Spacing.md),
      child: title == null
          ? null
          : Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.poster.copyWith(color: palette.black),
            ),
    );
  }
}
