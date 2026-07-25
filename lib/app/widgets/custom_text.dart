import 'package:flutter/material.dart';

class CText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;
  final FontStyle? fontStyle;
  final double? letterSpacing;
  final double? height;

  const CText(
    this.text, {
    super.key,
    this.fontSize = 14,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.fontStyle,
    this.letterSpacing,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        decoration: decoration,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        height: height,
      ),
    );
  }
}