// Copyright 2023 Bruce Eleniak. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

library;

import 'dart:math' as math;

import 'widgets/radial_painters.dart';
import 'package:flutter/material.dart';

part 'widgets/dial_state.dart';

/// Creates a widget that acts as a dial.
///
/// When focused, the dial will display a control ring of [ringWidth] logical pixels
/// If [clip] is true, panning off of this ring will end the current pan,
/// otherwise panning outside of the widget will continue to update the dial.
///
/// The supplied image will not be rotated in order to preserve visual characteristics.
/// Use [indicatorColor], [indicatorWidth], and [indicatorLength] to simulate rotation.
///
/// If [hotColor] is null, the control ring will be [color] color, otherwise it
/// will be a gradient of [color, hotColor], with [opacity] applied.
///
/// The initial precentage on creation of the widget is supplied through [value] [0,100]
///
/// The dial may be oriented clockwise or counterclockwise via [clockwise]. and the
/// mounting orientation is supplied via [orientation] in degrees from bottom,
/// typically [-180, 180].
///
/// If [stopCount] is zero, it is infinitely dialable withing [0,360] degrees,
/// if non-zero, the dial will dial to [stopCount] evenly spaced stops.
class Dial extends StatefulWidget {
  /// Creates an Dial
  Dial({
    super.key,
    this.value = 0.0,
    required this.image,
    required this.size,
    required this.ringWidth,
    required this.color,
    this.hotColor,
    this.opacity = 1.0,
    this.stopCount = 0,
    this.clip = false,
    this.clockwise = true,
    this.orientation = 0.0,
    this.indicatorColor,
    this.indicatorWidth = 1.0,
    this.indicatorLength,
    this.onDialed,
    this.onFocusChange,
  }) {
    assert(size > 0);
    assert(ringWidth >= 0 && ringWidth < size / 2);
    assert(opacity > 0.0 && opacity <= 1);
    assert(value >= 0.0 && value <= 360.0);
    assert(orientation >= -360.0 && orientation <= 360.0);
    assert(indicatorWidth >= 0.0);
  }

  /// The percentage value of the control ring on creation.
  final double value;

  /// The image used for the dial.
  final Image image;

  /// The size of the widget, Size([size,size]) in logical pixels.
  final double size;

  /// The width of the control ring in logical pixels.
  /// If larger than the calculated radius of the dial, this will
  /// be set to the radius of the dial.
  final double ringWidth;

  /// The color of the control ring if [hotColor] is null,
  /// otherwise the cool color (low values) side of the control rings gradient.
  final Color color;

  /// If non-null, the hot color (high values) side of the control ring.
  final Color? hotColor;

  /// The opacity of the control ring
  final double opacity;

  /// The number of non-zero evenly placed stops around the dial.
  /// If <= zero, there are no stops and the dial is infinite on [0.0,360.0]
  /// eg) stopCount: 10
  /// will result in a stop at "zero" and 10 subsequent evenly distributed
  /// radial stops at degrees (36, 72, 108, ... 360)
  final int stopCount;

  /// Set to true to end panning when outside of the control ring.
  /// Default - false
  final bool clip;

  /// Panning direction to increase the dials value.
  /// Set to true to pan clockwise, false for counterclockwise.
  /// default - true.
  final bool clockwise;

  /// The mounting orientation of the dial in degrees counterclockwise.
  /// 0.0 is bottom oriented, 180.0 is top oriented.
  /// Default 0.0
  final double orientation;

  /// The color of the dial position indicator line.
  /// The position indicator will be transparent if not specified
  final Color? indicatorColor;

  /// This width of the dial indicator line in logical pixels.
  /// Default 1.0
  final double indicatorWidth;

  /// The length of the dial indicator line in loogical pixels.
  /// If over dial radius, it will be set equal dial radius.
  final double? indicatorLength;

  /// Called when the dial is turned via the panning on the control ring.
  ///
  /// The value passed to the callback is true if focus is gained by tap and
  /// is false if the focus is lost to do a second tap or tapping another dial.
  ///
  /// Called with:
  /// - [degrees - 0.0-360.0] - degrees of rotation of the indicator.
  /// - [percent - 0.0-100.0] - percent rotation of the indicator.
  /// - [stopNumber 0-numberOfStops] - the stop number the indicator is at, 0 if stopCount < 1.
  final void Function(double degrees, double percent, int stopNumber)? onDialed;

  /// Called when the focus changes.
  ///
  /// Called with:
  /// - [focused = true] if focus is gained by tap.
  /// - [focused = false] if the focus is lost due to do a second tap
  ///   on this dial or focus gained by another widget.
  final void Function(bool focused)? onFocusChange;

  @override
  State<Dial> createState() => _DialState();
}
