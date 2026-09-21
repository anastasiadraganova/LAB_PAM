import 'package:flutter/material.dart';

/// Riso palette from DESIGN.md.
///
/// The chrome is almost monochrome so that the posters stay the only loud
/// thing on screen; `ink` and `fluo` are the two places where colour carries
/// meaning and nothing else.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.black,
    required this.grey,
    required this.paper,
    required this.surface,
    required this.ink,
    required this.fluo,
    required this.rule,
  });

  /// Text, stamps, black print. True black on paper, paper white in the dark.
  final Color black;

  /// Secondary text, captions, inactive icons.
  final Color grey;

  /// Screen background — the paper itself.
  final Color paper;

  /// Cards, inputs, bottom bar.
  final Color surface;

  /// Riso ultramarine: primary button, date stamp, active filter.
  final Color ink;

  /// Riso pink: the `active` ticket status and the "starts soon" mark.
  final Color fluo;

  /// Field borders, separators, outlines.
  final Color rule;

  static const AppPalette light = AppPalette(
    black: Color(0xFF000000),
    grey: _greyOnPaper,
    paper: Color(0xFFF0EFEB),
    surface: Color(0xFFFFFFFF),
    ink: _ink,
    fluo: _fluo,
    rule: Color(0xFFD8D6D0),
  );

  static const AppPalette dark = AppPalette(
    black: Color(0xFFF0EFEB),
    grey: _greyOnDarkPaper,
    paper: Color(0xFF141412),
    surface: Color(0xFF1E1E1C),
    ink: _ink,
    fluo: _fluo,
    rule: Color(0xFF383835),
  );

  /// Fluorescent inks are printed the same way on paper and in the dark, so
  /// they do not flip with the theme.
  static const Color _ink = Color(0xFF2B35F5);
  static const Color _fluo = Color(0xFFFF4FA3);

  /// Secondary grey carries small text, so it is set per theme to clear 4.5:1
  /// against the paper it sits on: 4.70:1 on light, 5.28:1 on dark.
  static const Color _greyOnPaper = Color(0xFF6A6A6A);
  static const Color _greyOnDarkPaper = Color(0xFF8A8A86);

  /// White stays white on top of `ink` in both themes (7.0:1).
  static const Color onInk = Color(0xFFFFFFFF);

  @override
  AppPalette copyWith({
    Color? black,
    Color? grey,
    Color? paper,
    Color? surface,
    Color? ink,
    Color? fluo,
    Color? rule,
  }) {
    return AppPalette(
      black: black ?? this.black,
      grey: grey ?? this.grey,
      paper: paper ?? this.paper,
      surface: surface ?? this.surface,
      ink: ink ?? this.ink,
      fluo: fluo ?? this.fluo,
      rule: rule ?? this.rule,
    );
  }

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      black: Color.lerp(black, other.black, t)!,
      grey: Color.lerp(grey, other.grey, t)!,
      paper: Color.lerp(paper, other.paper, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      fluo: Color.lerp(fluo, other.fluo, t)!,
      rule: Color.lerp(rule, other.rule, t)!,
    );
  }
}

/// Shorthand for reading the palette inside a build method.
extension AppPaletteOf on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
