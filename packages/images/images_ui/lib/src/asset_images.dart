import 'package:flutter/material.dart';
import '../../gen/fonts.gen.dart';

class AssetImages {
  AssetImages._();

  static const String _kFontPkg = 'images_ui';

  static const IconData studentData = IconData(
    0xe803,
    fontFamily: FontFamily.studentIcon,
    fontPackage: _kFontPkg,
  );

  static Icon studentIcon([double? size]) => Icon(studentData, size: size);
}
