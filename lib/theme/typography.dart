// lib/theme/typography.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppText {
  static TextStyle get titleSmall => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static TextStyle get subtitleSmall =>
      GoogleFonts.poppins(fontSize: 10, color: Colors.black54);

  static TextStyle get bodyMuted =>
      GoogleFonts.poppins(fontSize: 13, color: Colors.black54);
}
