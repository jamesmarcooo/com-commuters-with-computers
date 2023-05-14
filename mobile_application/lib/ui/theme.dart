import 'dart:ui';

import 'package:flutter/material.dart';

extension XPadding on Widget {
  Padding paddingAll(double value) {
    return Padding(
      padding: EdgeInsets.all(value),
      child: this,
    );
  }

  Padding paddingLeft(double value) {
    return Padding(
      padding: EdgeInsets.only(left: value),
      child: this,
    );
  }

  Padding paddingRight(double value) {
    return Padding(
      padding: EdgeInsets.only(right: value),
      child: this,
    );
  }

  Padding paddingBottom(double value) {
    return Padding(
      padding: EdgeInsets.only(bottom: value),
      child: this,
    );
  }

  Padding paddingTop(double value) {
    return Padding(
      padding: EdgeInsets.only(top: value),
      child: this,
    );
  }

  Padding paddingVertical(double value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: value),
      child: this,
    );
  }

  Padding paddingHorizontal(double value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: value),
      child: this,
    );
  }
}

class ComAppTheme {
  static const double elementSpacing = 16;

  static const Color comPurple = const Color(0xFF5644B2);
  static const Color comWhite = const Color(0xFFFFFFFF);
  static const Color cityBlack = const Color(0xFF3E3D3D);
  static const Color cityLightGrey = const Color(0xFFE6E7E8);
  static const Color cityGrey = Color(0xFF707070);
  static const Color cityOrange = Color(0xFFE39219);

  static ThemeData theme = ThemeData(
    primaryColor: comPurple,
    backgroundColor: comWhite,
  );
}
