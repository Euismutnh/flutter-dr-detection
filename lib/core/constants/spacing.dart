// lib/core/constants/spacing.dart
import 'package:flutter/material.dart';

/// App Spacing System
/// 8dp grid system for consistent spacing across the app
/// Based on Material Design spacing guidelines
class Spacing {
  // Private constructor
  Spacing._();

  // ============================================================================
  // BASE SPACING VALUES (8dp grid system)
  // ============================================================================
  
  /// Extra extra small - 2dp
  static const double xxs = 2.0;
  
  /// Extra small - 4dp
  static const double xs = 4.0;
  
  /// Small - 8dp
  static const double sm = 8.0;
  
  /// Medium - 16dp (base unit)
  static const double md = 16.0;
  
  /// Large - 24dp
  static const double lg = 24.0;
  
  /// Extra large - 32dp
  static const double xl = 32.0;
  
  /// Extra extra large - 48dp
  static const double xxl = 48.0;
  
  /// Extra extra extra large - 64dp
  static const double xxxl = 64.0;

  // ============================================================================
  // EDGE INSETS (Padding/Margin shortcuts)
  // ============================================================================
  
  /// No padding
  static const EdgeInsets none = EdgeInsets.zero;
  
  /// Extra small padding - 4dp all sides
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  
  /// Small padding - 8dp all sides
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  
  /// Medium padding - 16dp all sides (default)
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  
  /// Large padding - 24dp all sides
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  
  /// Extra large padding - 32dp all sides
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  
  /// Screen padding - 24dp horizontal, 16dp vertical
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
  
  /// Card padding - 16dp all sides
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  
  /// Button padding - 16dp vertical, 24dp horizontal
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    vertical: md,
    horizontal: lg,
  );
  
  /// List item padding - 16dp all sides
  static const EdgeInsets listItemPadding = EdgeInsets.all(md);

  // ============================================================================
  // SIZED BOX (Vertical/Horizontal spacing shortcuts)
  // ============================================================================

  static const SizedBox verticalXXS = SizedBox(height: xxs);
  /// Vertical spacing - Extra small (4dp)
  static const SizedBox verticalXS = SizedBox(height: xs);
  
  /// Vertical spacing - Small (8dp)
  static const SizedBox verticalSM = SizedBox(height: sm);
  
  /// Vertical spacing - Medium (16dp)
  static const SizedBox verticalMD = SizedBox(height: md);
  
  /// Vertical spacing - Large (24dp)
  static const SizedBox verticalLG = SizedBox(height: lg);
  
  /// Vertical spacing - Extra large (32dp)
  static const SizedBox verticalXL = SizedBox(height: xl);
  
  /// Vertical spacing - Extra extra large (48dp)
  static const SizedBox verticalXXL = SizedBox(height: xxl);

  static const SizedBox verticalXXXL = SizedBox(height: xxxl);
  
  /// Horizontal spacing - Extra small (4dp)
  static const SizedBox horizontalXS = SizedBox(width: xs);
  
  /// Horizontal spacing - Small (8dp)
  static const SizedBox horizontalSM = SizedBox(width: sm);
  
  /// Horizontal spacing - Medium (16dp)
  static const SizedBox horizontalMD = SizedBox(width: md);
  
  /// Horizontal spacing - Large (24dp)
  static const SizedBox horizontalLG = SizedBox(width: lg);
  
  /// Horizontal spacing - Extra large (32dp)
  static const SizedBox horizontalXL = SizedBox(width: xl);

  // ============================================================================
  // BORDER RADIUS (Rounded corners)
  // ============================================================================
  
  /// Small radius - 8dp
  static const BorderRadius radiusSM = BorderRadius.all(Radius.circular(sm));
  
  /// Medium radius - 12dp
  static const BorderRadius radiusMD = BorderRadius.all(Radius.circular(12));
  
  /// Large radius - 16dp (default for cards)
  static const BorderRadius radiusLG = BorderRadius.all(Radius.circular(md));
  
  /// Extra large radius - 20dp
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(20));
  
  /// Extra extra large radius - 24dp (buttons)
  static const BorderRadius radiusXXL = BorderRadius.all(Radius.circular(lg));
  
  /// Circular radius - 999dp (pills, avatars)
  static const BorderRadius radiusCircular = BorderRadius.all(Radius.circular(999));
  
  /// Top only radius - 20dp (bottom sheets)
  static const BorderRadius radiusTopXL = BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(20),
  );
  
  /// Bottom only radius - 20dp
  static const BorderRadius radiusBottomXL = BorderRadius.only(
    bottomLeft: Radius.circular(20),
    bottomRight: Radius.circular(20),
  );

  // ============================================================================
  // ELEVATION (Box shadows)
  // ============================================================================
  
  /// Small elevation - 2dp
  static const double elevationSM = 2.0;
  
  /// Medium elevation - 4dp
  static const double elevationMD = 4.0;
  
  /// Large elevation - 8dp
  static const double elevationLG = 8.0;
  
  /// Extra large elevation - 16dp
  static const double elevationXL = 16.0;

  // ============================================================================
  // ICON SIZES
  // ============================================================================
  
  /// Small icon - 16dp
  static const double iconSM = 16.0;
  
  /// Medium icon - 24dp (default)
  static const double iconMD = 24.0;
  
  /// Large icon - 32dp
  static const double iconLG = 32.0;
  
  /// Extra large icon - 48dp
  static const double iconXL = 48.0;

  // ============================================================================
  // AVATAR SIZES
  // ============================================================================
  
  /// Small avatar - 32dp
  static const double avatarSM = 32.0;
  
  /// Medium avatar - 48dp
  static const double avatarMD = 48.0;
  
  /// Large avatar - 64dp
  static const double avatarLG = 64.0;
  
  /// Extra large avatar - 96dp
  static const double avatarXL = 96.0;
  
  /// Extra extra large avatar - 120dp
  static const double avatarXXL = 120.0;

  // ============================================================================
  // BUTTON SIZES
  // ============================================================================
  
  /// Small button height - 36dp
  static const double buttonHeightSM = 36.0;
  
  /// Medium button height - 48dp
  static const double buttonHeightMD = 48.0;
  
  /// Large button height - 56dp
  static const double buttonHeightLG = 56.0;

  // ============================================================================
  // INPUT FIELD SIZES
  // ============================================================================
  
  /// Input field height - 56dp
  static const double inputHeight = 56.0;
  
  /// Input field border radius - 16dp
  static const double inputRadius = 16.0;

  // ============================================================================
  // DIVIDER THICKNESS
  // ============================================================================
  
  /// Thin divider - 1dp
  static const double dividerThin = 1.0;
  
  /// Medium divider - 2dp
  static const double dividerMedium = 2.0;
  
  /// Thick divider - 4dp
  static const double dividerThick = 4.0;

  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Create custom vertical spacing
  static SizedBox vertical(double height) => SizedBox(height: height);
  
  /// Create custom horizontal spacing
  static SizedBox horizontal(double width) => SizedBox(width: width);
  
  /// Create custom padding
  static EdgeInsets padding({
    double all = 0,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return EdgeInsets.only(
      top: top ?? vertical ?? all,
      bottom: bottom ?? vertical ?? all,
      left: left ?? horizontal ?? all,
      right: right ?? horizontal ?? all,
    );
  }
  
  /// Create custom border radius
  static BorderRadius radius(double value) {
    return BorderRadius.circular(value);
  }
  
  /// Create custom border radius for specific corners
  static BorderRadius customRadius({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    );
  }
}