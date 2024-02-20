import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle appStyle(double size, FontWeight fw, Color color) {
  return GoogleFonts.poppins(fontSize: size, fontWeight: fw, color: color);
}

TextStyle appStyleWithHt(double size, FontWeight fw, Color color, double ht) {
  return GoogleFonts.poppins(
      fontSize: size, fontWeight: fw, color: color, height: ht);
}
