// lib/core/constants/app_colors.dart
// Palette màu dùng toàn app. Dùng tên semantic, không dùng tên vật lý (ví dụ: blue1).

import 'package:flutter/material.dart';

// Màu xanh dương chính của app
const Color kPrimaryColor = Color(0xFF1196EF);
// Màu xanh dương phụ của app
const Color kSecondaryColor = Color(0xFF38CEEB);

// Màu nền
// Màu nền chính của app
const Color kBackgroundColor = Color(0xFFEEEDED);
// Nền bề mặt chính của app
const Color kSurfaceColor = Color(0xFFFDFDFD);
// Màu nền trang profile
const Color kProfileBackgroundColor = Color(0xFFC2ECFF);
// Gradient nền chính của app
const LinearGradient kBackgroundGradient = LinearGradient(
  colors: [Color(0xFFFFFFFF), Color(0xFFB2E0FF)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
// Gradient nền card ielts
const LinearGradient kIeltsCardGradient = LinearGradient(
  colors: [Color(0xFFFF3434), Color(0xFFFF8585), Color(0xFFFC6B6B)],
  begin: Alignment.centerRight,
  end: Alignment.centerLeft,
  stops: [0.31, 0.79, 1.0],
);
// Gradient nền card toeic
const LinearGradient kToeicCardGradient = LinearGradient(
  colors: [Color(0xFF73CEF8), Color(0xFF8DCAF3), Color(0xFFF4FDFF)],
  begin: Alignment.centerRight,
  end: Alignment.centerLeft,
  stops: [0.0, 0.53, 1.0],
);

// màu logo
const LinearGradient kLogoGradient = LinearGradient(
  colors: [kPrimaryColor, Color(0xFF66297C)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// màu icon menu flashcard
const Color kIconFlashcardColor = Color(0xFF299CB2);

//Màu icon back
const Color kIconBackColor = Color(0xFF6F6F6F);

// Gradient cup vàng
const LinearGradient kGoldCupGradient = LinearGradient(
  colors: [Color(0xFF36AAAC), Color(0xFFEAAD15)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  stops: [0.04, 0.43],
);

// Màu nút bấm
// Button nổi bật (Get Start, Đăng ký, đăng nhập)
const LinearGradient kPrimaryButtonGradient = LinearGradient(
  colors: [kPrimaryColor, Color(0xFF605ACD)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);
// Button primary
const Color kPrimaryButtonColor = Color(0xFF2F6BB2);
// Button success
const Color kSuccessButtonColor = Color(0xFF27AE60);

//Màu nút fullscreen
const Color kFullscreenButtonColor = Color.fromARGB(255, 120, 120, 120);

//Màu outline
const Color kOutlineColor = Color(0xFFC7C3C3);

// Màu text
// Màu text: primary text, secondary text, disabled, accent, link.
const Color kTextPrimary = Color(0xFF000000);
const Color kTextSecondary = Color(0xFFFFFFFF);
const Color kTextThird = Color(0xFF3F3C3C);
const Color kTextDisabled = Color(0xFFA8A8A8);
const Color kTextAccent = Color(0xFF5A92CD);
const Color kLinkTextColor = Color(0xFF5638EB);

// Màu trạng thái
const Color kSuccess = Color(0xFF27AE60);
const Color kSuccessColor = Color(0xFF27AE60); // Alias for consistency
const Color kWarning = Color(0xFFF2C94C);
const Color kWarningColor = Color(0xFFF2C94C); // Alias for consistency
const Color kDanger = Color(0xFFCC1212);
const Color kSpecial = Color(0xFFD44CF2);
const Color kAccentColor = Color(0xFFD44CF2); // Alias for consistency

/// Example Material swatch for theming (optional).
const MaterialColor kPrimarySwatch = MaterialColor(0xFF0A84FF, <int, Color>{
  50: Color(0xFFEAF4FF),
  100: Color(0xFFD6EAFF),
  200: Color(0xFFBDE0FF),
  300: Color(0xFF84CCFF),
  400: Color(0xFF48B3FF),
  500: Color(0xFF0A84FF), // main
  600: Color(0xFF076FE6),
  700: Color(0xFF0558CC),
  800: Color(0xFF0345B3),
  900: Color(0xFF012E80),
});
