import 'package:flutter/widgets.dart';

/// The 4pt grid from DESIGN.md. These seven steps are the only gaps used.
abstract final class Spacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Horizontal screen margin.
  static const double gutter = md;

  /// Vertical gap between blocks.
  static const double block = lg;
}

/// Three radii for the whole application, no more.
abstract final class AppRadius {
  /// Printed matter is barely rounded: event cards and tickets.
  static const BorderRadius print = BorderRadius.all(Radius.circular(4));

  /// Inputs and buttons.
  static const BorderRadius control = BorderRadius.all(Radius.circular(8));

  /// Chips are rounded all the way.
  static const BorderRadius chip = BorderRadius.all(Radius.circular(999));
}

/// Fixed measurements that the layout leans on.
abstract final class AppSizes {
  /// No tap target is smaller than this.
  static const double minTouch = 48;

  /// Height of an input field and of a button. A minimum, so that the text
  /// still fits when the system font is scaled up.
  static const double control = 52;

  /// Poster proportion, width to height.
  static const double posterRatio = 3 / 4;

  /// Margin between the date stamp and the corner of the poster.
  static const double stampInset = 12;

  /// Width of the ink stub down the side of a ticket.
  static const double ticketSpine = 6;

  static const double hairline = 1;
  static const double focusLine = 1.5;
  static const double stampLine = 2;

  /// Diameter of the `fluo` status dot.
  static const double statusDot = 8;

  /// Rotation of the date stamp and of the "погашен" stamp, in radians.
  static const double dateStampTilt = -4 * 3.1415926535897932 / 180;
  static const double usedStampTilt = -8 * 3.1415926535897932 / 180;
}
