// lib/core/constants/app_text_styles.dart
// Định nghĩa text styles chuẩn (semantic names).

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Headline 1 — lớn, dùng cho titles chính.
const TextStyle kH1 = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w700,
  color: kTextSecondary,
  height: 1.2,
);

/// Headline 2 — vừa, dùng cho titles phụ.
const TextStyle kH2 = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: kTextPrimary,
  height: 1.3,
);

/// Body large — đoạn văn chính.
const TextStyle kBody = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: kTextPrimary,
  height: 1.5,
);

// Text style nổi bật
const TextStyle kBodyEmphasized = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: kTextAccent,
  height: 1.5,
);

/// Caption / auxiliary text
const TextStyle kCaption = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: kTextAccent,
);

// Text style riêng cho tiêu đề login/register
const TextStyle kFormTitle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w700,
  color: kSecondaryColor,
);

// Text style nguy hiểm (alerts, errors)
const TextStyle kDangerText = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: kDanger,
);

// Text style flashcard

const TextStyle kFlashcardText = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.normal,
  color: kTextPrimary,
  fontFamily: 'Poppins',
);
