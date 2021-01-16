import 'package:flutter/material.dart';
import 'package:tinycolor/tinycolor.dart';
import 'color_utils.dart';

/// * This is a sample button I have created for my view. You can modify your button and make a consistent UI.
/// onClick - Button click
/// text - Button text
/// textColor - Button textColor
/// color - Button Background color
/// splashColor - Color displayed when the button is touched
/// minWidth - Minimum width of a button
/// height - Button height
/// leadingIcon - If you want to display an icon before button text
/// trailingIcon - If you want to display an icon after button text
///
ButtonTheme bottleCapButton({
  VoidCallback onClick,
  String text,
  Color textColor,
  double textFontSize = 20,
  Color color,
  Color splashColor,
  // double minWidth = 150,
  double height = 100,
  double leadingIconMargin = 0,
  Widget leadingIcon,
}) {
  return ButtonTheme(
    // minWidth: minWidth,
    height: height,
    child: RaisedButton(
        splashColor: Colors.grey.withOpacity(0.5) ?? colorBlack,
        shape: CircleBorder(
          side: BorderSide(width: 5, color: color.darken(10)),
        ),
        textColor: Colors.white,
        color: color,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          // This is must when you are using Row widget inside Raised Button
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildLeadingIcon(leadingIcon, leadingIconMargin),
            Text(
              text ?? '',
              style: TextStyle(
                color: Colors.white,
                fontSize: textFontSize,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        onPressed: () {
          return onClick();
        }),
  );
}

Widget _buildLeadingIcon(Widget leadingIcon, double leadingIconMargin) {
  if (leadingIcon != null) {
    return Row(
      children: <Widget>[leadingIcon, SizedBox(width: leadingIconMargin)],
    );
  }
  return Container();
}
