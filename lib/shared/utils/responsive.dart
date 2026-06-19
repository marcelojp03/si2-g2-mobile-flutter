import 'package:flutter/material.dart';

class Responsive {
  final BuildContext _context;
  final double _width;
  final double _height;

  Responsive._(this._context) : _width = MediaQuery.of(_context).size.width,
      _height = MediaQuery.of(_context).size.height;

  factory Responsive.of(BuildContext context) => Responsive._(context);

  bool get isMobile => (_width < 600);
  bool get isTablet => (_width >= 600 && _width < 1024);
  bool get isDesktop => (_width >= 1024);
  bool get isPortrait => _height > _width;
  bool get isLandscape => _width > _height;

  double wp(double percent) => _width * percent / 100;
  double hp(double percent) => _height * percent / 100;

  double fontSize(double designPx) {
    final scale = _width / 375;
    final value = designPx * scale;
    return value.clamp(designPx * 0.8, designPx * 1.3);
  }

  double radius(double designPx) => designPx * (_width / 375);
  double spacing(double designPx) => designPx * (_width / 375);
  double iconSize(double designPx) {
    final value = designPx * (_width / 375);
    return value.clamp(designPx * 0.85, designPx * 1.25);
  }
}

extension ResponsiveContext on BuildContext {
  Responsive get responsive => Responsive.of(this);
}
