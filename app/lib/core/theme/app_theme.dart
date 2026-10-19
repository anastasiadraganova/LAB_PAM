import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'spacing.dart';

/// Light and dark themes assembled from the design tokens by hand.
///
/// `ColorScheme.fromSeed` is deliberately not used: the palette is a fixed set
/// of riso inks, not a generated harmony.
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, AppPalette.light);

  static ThemeData dark() => _build(Brightness.dark, AppPalette.dark);

  static ThemeData _build(Brightness brightness, AppPalette palette) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: palette.ink,
      onPrimary: AppPalette.onInk,
      secondary: palette.fluo,
      onSecondary: AppPalette.onInk,
      // Errors are set in black, never in red — see DESIGN.md.
      error: palette.black,
      onError: palette.surface,
      surface: palette.surface,
      onSurface: palette.black,
      outline: palette.rule,
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.paper,
      canvasColor: palette.paper,
      textTheme: AppTypography.textTheme(palette),
      iconTheme: IconThemeData(color: palette.black),
      dividerTheme: DividerThemeData(
        color: palette.rule,
        thickness: 1,
        space: 1,
      ),
      // No shadows anywhere: a card is told apart by its fill and its outline.
      appBarTheme: AppBarTheme(
        backgroundColor: palette.paper,
        foregroundColor: palette.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      // Messages are printed in black on paper, like everything else.
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.black,
        contentTextStyle: AppTypography.body.copyWith(color: palette.paper),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.control),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: palette.rule,
      ),
      extensions: <ThemeExtension<dynamic>>[palette],
    );
  }
}
