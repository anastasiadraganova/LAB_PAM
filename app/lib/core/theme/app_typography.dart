import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Type scale from DESIGN.md.
///
/// Fira Sans Extra Condensed sets everything that reads like print — titles,
/// dates, prices, stamps. Manrope carries the rest of the interface. If the
/// extra condensed cut ever turns out too narrow on long titles, swapping it
/// for Fira Sans Condensed is a change to this file alone.
abstract final class AppTypography {
  static const List<FontFeature> _tabular = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  /// Event title in a card.
  static TextStyle get poster => GoogleFonts.firaSansExtraCondensed(
        fontSize: 32,
        height: 34 / 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  /// Main heading of a screen, and the number in the ticket counter.
  static TextStyle get posterXL => GoogleFonts.firaSansExtraCondensed(
        fontSize: 44,
        height: 46 / 44,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        fontFeatures: _tabular,
      );

  /// Day separator in the listing.
  static TextStyle get dayRule => GoogleFonts.firaSansExtraCondensed(
        fontSize: 26,
        height: 28 / 26,
        fontWeight: FontWeight.w600,
        fontFeatures: _tabular,
      );

  /// Text inside a stamp. The only place where upper case is allowed.
  static TextStyle get stamp => GoogleFonts.firaSansExtraCondensed(
        fontSize: 15,
        height: 16 / 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        fontFeatures: _tabular,
      );

  /// Price, total.
  static TextStyle get price => GoogleFonts.firaSansExtraCondensed(
        fontSize: 22,
        height: 24 / 22,
        fontWeight: FontWeight.w700,
        fontFeatures: _tabular,
      );

  /// Description, running text.
  static TextStyle get body => GoogleFonts.manrope(
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w400,
      );

  /// Venue, time, category.
  static TextStyle get meta => GoogleFonts.manrope(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w500,
      );

  /// Secondary captions.
  static TextStyle get caption => GoogleFonts.manrope(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w400,
      );

  /// Button label.
  static TextStyle get button => GoogleFonts.manrope(
        fontSize: 16,
        height: 20 / 16,
        fontWeight: FontWeight.w700,
      );

  /// Material slots are filled so that stray framework text still lands in the
  /// project typography instead of falling back to Roboto.
  static TextTheme textTheme(AppPalette palette) {
    return TextTheme(
      displayLarge: posterXL.copyWith(color: palette.black),
      headlineMedium: poster.copyWith(color: palette.black),
      titleLarge: dayRule.copyWith(color: palette.black),
      titleMedium: price.copyWith(color: palette.black),
      bodyMedium: body.copyWith(color: palette.black),
      bodySmall: meta.copyWith(color: palette.grey),
      labelLarge: button.copyWith(color: palette.black),
      labelSmall: caption.copyWith(color: palette.grey),
    );
  }
}
