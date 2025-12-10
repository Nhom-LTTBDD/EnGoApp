// lib/core/constants/app_spacing.dart
// Các kích thước spacing dùng toàn app để consistent layout.

import 'package:flutter/widgets.dart';

/// Generic spacing scale (in px)
const double spaceXs = 4.0;
const double spaceSm = 8.0;
const double spaceMd = 16.0;
const double spaceLg = 24.0;
const double spaceXl = 32.0;

/// Common paddings
const EdgeInsets kPaddingScreen = EdgeInsets.symmetric(horizontal: spaceMd);
const EdgeInsets kPaddingCard = EdgeInsets.all(spaceSm);

/// Border radii
const BorderRadius kRadiusSmall = BorderRadius.all(Radius.circular(8.0));
const BorderRadius kRadiusMedium = BorderRadius.all(Radius.circular(12.0));
const BorderRadius kRadiusLarge = BorderRadius.all(Radius.circular(20.0));
