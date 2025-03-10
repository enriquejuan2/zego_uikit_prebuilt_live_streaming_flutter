// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil_zego/flutter_screenutil_zego.dart';

// size
Size get zegoLiveButtonSize => Size(72.r, 72.r);

Size get zegoLiveButtonIconSize => Size(40.r, 40.r);

SizedBox get zegoLiveButtonPadding =>
    SizedBox.fromSize(size: Size.fromRadius(8.r));

Size getTextSize(String text, TextStyle textStyle) {
  final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}

enum PopupItemValue {
  inviteConnect,
  kickCoHost,
  kickOutAttendance,
  cancel,
}

class PopupItem {
  final PopupItemValue value;
  final String text;

  const PopupItem(this.value, this.text);
}

bool isRTL(BuildContext context) {
  return Directionality.of(context) == TextDirection.rtl;
}
