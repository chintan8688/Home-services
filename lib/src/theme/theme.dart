import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final TextTheme textTheme = TextTheme();

TextTheme getTextTheme(TextTheme theme) {
  var baseTextColor = Colors.black;

  return theme.copyWith(
    headline1: GoogleFonts.roboto(
        fontSize: 96,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.5,
        color: baseTextColor),
    headline2: GoogleFonts.roboto(
        fontSize: 60,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
        color: baseTextColor),
    headline3: GoogleFonts.roboto(
        fontSize: 48, fontWeight: FontWeight.w400, color: baseTextColor),
    headline4: GoogleFonts.roboto(
        fontSize: 34,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: baseTextColor),
    headline5: GoogleFonts.roboto(
        fontSize: 24, fontWeight: FontWeight.bold, color: baseTextColor),
    headline6: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.52,
        color: baseTextColor),
    subtitle1: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        color: baseTextColor),
    subtitle2: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: baseTextColor),
    bodyText2: GoogleFonts.roboto(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: baseTextColor),
    bodyText1: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: baseTextColor),
    button: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.25,
        color: baseTextColor),
    caption: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: baseTextColor),
    overline: GoogleFonts.roboto(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.5,
        color: baseTextColor),
  );
}

const primary_color = Color(0xFF07d16f);
const accent_color = Color(0xFF07d16f);
const primary_background_color = Color(0xFFffffff);
const text_field_background_color = Color(0xFFd1ffe9);
const button_secondary = const Color(0xFF236344);
const primary_font = Colors.white;
const error_color = Colors.redAccent;

const shadow_color = const Color(0xFFF7F7F7);
final secondary_color = Colors.grey[200];
const secondary_background_color = Colors.black54;
const black_color = Colors.black;
const grey_color = Colors.grey;
const stepper_background = const Color(0xFFF3F3F3);
const stepper_color = const Color(0xFFDDDDDD);

const primary_color_seller = const Color(0xFFF65321);
const accent_color_seller = const Color(0xFF8A280B);
const text_field_background_color_seller = Color(0xFFFFE1D8);
const primary_background_color_seller = const Color(0xFFFFFFFF);
const primary_font_seller = Colors.white;
const error_color_seller = Colors.redAccent;

final ButtonThemeData buttonThemeDataBuyer = ButtonThemeData(
    buttonColor: primary_color,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.0),
    ),
    textTheme: ButtonTextTheme.primary);

final ButtonThemeData buttonThemeDataSeller = ButtonThemeData(
  buttonColor: primary_color_seller,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(5.0),
  ),
  textTheme: ButtonTextTheme.primary,
);

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

