// Copyright 2023 Bruce Eleniak. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

part of '../dial.dart';

const double _kUninitializedDegrees = 1000.00;
const double _kTwoPi = 2.0 * math.pi;
const double _kPiOverTwo = math.pi / 2.0;

extension _DoubleExtensions on double {
  double toRadians() {
    return (this * math.pi) / 180.0;
  }

  double toDegrees() {
    return (this * 180.0) / math.pi;
  }
}

class _DialState extends State<Dial> {
  Offset startDial = const Offset(0, 0);
  late final double radius;
  late final double innerRadius;
  late final Offset center;
  late final Size widgetSize;
  late final Color indicatorColor;
  late final double indicatorStartRadius;
  late final double orientation;
  late final double orientationOffsetRadians;
  late final SweepGradient? sweepGradient;
  late final SweepGradient? nullGradient;
  late Color mainColor;

  // state variables
  bool enabled = false;

  // percent [0-100] tracking
  double prevPercent = 0.0;
  double curPercent = 0.0;
  bool needForward = false;
  bool needBackward = false;

  // tracking percentage, infinite on closed interval [0,100]
  late double trackingPercent;

  // stops [0,100] (or infinite if no stops)
  late double percentPerStop;
  late double stopPercent;

  @override
  void initState() {
    super.initState();
    radius = widget.size / 2.0;
    innerRadius = radius - math.min(widget.ringWidth, radius);
    center = Offset(radius, radius);
    widgetSize = Size(widget.size, widget.size);
    trackingPercent = widget.value;
    // adjust reference to dead center bottom
    orientation = widget.orientation - 90.0;
    orientationOffsetRadians = orientation.toRadians();
    mainColor = widget.color.withValues(alpha: widget.opacity);
    indicatorColor = widget.indicatorColor ?? Colors.transparent;
    if (widget.indicatorLength != null) {
      indicatorStartRadius = math.max(radius - widget.indicatorLength!, 0);
    } else {
      indicatorStartRadius = radius / 3; // default length = 2/3 of radius
    }

    // Create gradiants (visible and invisible)
    sweepGradient = _createGradient();
    if (widget.hotColor != null) {
      nullGradient =
          const SweepGradient(colors: [Colors.transparent, Colors.transparent]);
    } else {
      nullGradient = null;
    }

    percentPerStop = widget.stopCount > 0 ? 100.0 / widget.stopCount : 0.0;
    stopPercent = _findNearestStopPercent(trackingPercent);

    // Keep results as expected.
    // case: rebuild forced by changing the Widget's key
    Future.delayed(Duration.zero, () {
      widget.onDialed?.call(
        3.6 * trackingPercent,
        trackingPercent,
        _findNearestStop(stopPercent),
      );
    });
  }

  // returns the closest stop number, zero if no stops
  int _findNearestStop(double percent) {
    double nearest = 0.0;
    if (widget.stopCount > 0) {
      double val = percent / percentPerStop;
      nearest = val.round() * percentPerStop;
      return (nearest ~/ percentPerStop);
    }
    return 0;
  }

  // find the closest stop percent, input = output of no stops
  double _findNearestStopPercent(double percent) {
    double nearest = percent;
    if (widget.stopCount > 0) {
      double val = percent / percentPerStop;
      nearest = val.round() * percentPerStop;
    }
    return nearest;
  }

  // create the directed SweepGradient for the dial control if configured
  SweepGradient? _createGradient() {
    SweepGradient? gradient;
    if (widget.hotColor != null) {
      Color color1 = widget.color.withValues(alpha: widget.opacity);
      Color color2 = widget.hotColor!.withValues(alpha: widget.opacity);
      List<Color> gradientColors =
          widget.clockwise ? [color1, color2] : [color2, color1];
      gradient = SweepGradient(
        colors: gradientColors,
        transform: GradientRotation(-orientationOffsetRadians),
      );
    }
    return gradient;
  }

  // returns radians at a given offset from center
  double _radians(Offset offset) {
    return math.atan2((widget.size - offset.dy) - radius, offset.dx - radius);
  }

  // returns degrees corrected clockwise / counterclockwise
  double _directedDegrees(double radians) {
    double degrees = radians.toDegrees();
    if (widget.clockwise) {
      degrees = -degrees;
    }
    return degrees;
  }

  // returns radians corrected clockwise / counterclockwise
  double _directedRadians(double radians) {
    return widget.clockwise ? radians : -radians;
  }

  // return true if a a point at position is with the control handle
  bool _survivesClip(Offset position) {
    if (!widget.clip) {
      return true;
    }
    final double distance = (position - center).distance;
    return (distance <= radius) && (distance >= innerRadius);
  }

  // indicator angle given widget rotation and cw/ccw
  double _indicatorRadians(double percent) {
    int piMultiplier = widget.clockwise ? -3 : 1;
    double adjustedOrientation =
        widget.clockwise ? 180.0 - orientation : orientation;
    double orientedRadians = adjustedOrientation.toRadians();
    double indicatorAngle = orientedRadians +
        (piMultiplier * _kPiOverTwo) +
        (percent * _kTwoPi) / 100.0;
    return indicatorAngle;
  }

  // Logic for limited turning [0,100]%
  // determines nearest stopp if applicable
  // updates the trackingPercentage
  // returns turn nearest percent, or stopped percentage if applicable
  double _doTurn(Offset offset) {
    final double radians = _radians(offset);
    double degrees = _directedDegrees(radians);
    bool forward = false;
    bool backward = false;

    // initial condition
    if (curPercent == _kUninitializedDegrees) {
      curPercent = prevPercent = degrees;
      return trackingPercent;
    }
    // jump discontinuity, rollover
    if ((degrees - prevPercent).abs() > 45.0) {
      prevPercent = curPercent = degrees;
      stopPercent = (widget.stopCount > 0)
          ? _findNearestStopPercent(trackingPercent)
          : trackingPercent;
      return stopPercent;
    }
    // determine direction
    if (degrees > prevPercent) {
      forward = true;
    }
    if (degrees < prevPercent) {
      backward = true;
    }

    // update the tracking percentage, respecting limits
    if (forward && !needBackward && trackingPercent < 100.0) {
      needForward = false;
      curPercent = degrees;
      double diff = curPercent - prevPercent;
      trackingPercent += diff / 3.60;
      if (trackingPercent > 100.0) {
        trackingPercent = 100.0;
        needBackward = true;
      }
    }

    if (backward && !needForward && trackingPercent > 0.0) {
      needBackward = false;
      curPercent = degrees;
      double diff = curPercent - prevPercent;
      trackingPercent += diff / 3.60;
      if (trackingPercent < 0.0) {
        trackingPercent = 0.0;
        needForward = true;
      }
    }

    prevPercent = curPercent;
    stopPercent = (widget.stopCount > 0)
        ? _findNearestStopPercent(trackingPercent)
        : trackingPercent;
    return stopPercent;
  }

  @override
  Widget build(BuildContext context) {
    double indicatorAngle = _indicatorRadians(stopPercent);

    Color? singleColor = enabled && widget.hotColor == null ? mainColor : null;
    SweepGradient? gradient =
        enabled && widget.hotColor != null ? sweepGradient : nullGradient;

    return FocusScope(
      child: Focus(
        onFocusChange: (focused) {
          setState(() => enabled = focused);
          widget.onFocusChange?.call(focused);
          final currentPercent = _findNearestStopPercent(trackingPercent);
          final int currentStop = _findNearestStop(currentPercent);
          widget.onDialed?.call(_directedRadians(indicatorAngle).toDegrees(),
              currentPercent, currentStop);
        },
        child: Builder(builder: (BuildContext context) {
          return GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onTap: () {
              setState(() => enabled = !enabled);
              final FocusNode focusNode = Focus.of(context);
              final bool hasFocus = focusNode.hasFocus;
              hasFocus ? focusNode.unfocus() : focusNode.requestFocus();
            },
            onPanStart: (details) {
              if (!enabled) return;
              startDial = details.localPosition;
              curPercent = prevPercent = _kUninitializedDegrees;
              final double percent = _doTurn(startDial);
              final int stop = _findNearestStop(percent);
              widget.onDialed?.call(
                  _directedRadians(indicatorAngle).toDegrees(), percent, stop);
              setState(() {});
            },
            onPanUpdate: (details) {
              if (!enabled) return;
              Offset currentDial = details.localPosition;
              if (_survivesClip(currentDial)) {
                final double percent = _doTurn(currentDial);
                final int stop = _findNearestStop(percent);
                widget.onDialed?.call(
                    _directedRadians(indicatorAngle).toDegrees(),
                    percent,
                    stop);
                setState(() {});
                return;
              }
            },
            onPanEnd: (details) {
              curPercent = prevPercent = _kUninitializedDegrees;
            },
            child: Stack(
              children: [
                Container(
                  height: widget.size,
                  width: widget.size,
                  foregroundDecoration: DialDecoration(
                    width: widget.ringWidth,
                    color: singleColor,
                    gradient: gradient,
                    shape: DialBorder(
                        center: Offset(radius, radius),
                        radius: radius,
                        width: widget.ringWidth),
                  ),
                  child: SizedBox(
                    height: widget.size,
                    width: widget.size,
                    child: widget.image,
                  ),
                ),
                RadialLine(
                  center: center,
                  startRadius: indicatorStartRadius,
                  endRadius: radius,
                  rotationRadians:
                      widget.clockwise ? indicatorAngle : -indicatorAngle,
                  width: widget.indicatorWidth,
                  color: indicatorColor,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// dial decoration
/// @nodoc
class DialDecoration extends ShapeDecoration {
  final double width;

  const DialDecoration(
      {required this.width, super.color, super.gradient, required super.shape});

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) {
    final Offset center = rect.center;
    final double radius = rect.shortestSide / 2.0;

    Path outerPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.nonZero;
    Path innerPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius - width))
      ..fillType = PathFillType.evenOdd;
    return Path.combine(PathOperation.difference, outerPath, innerPath);
  }

  @override
  bool hitTest(Size size, Offset position, {TextDirection? textDirection}) {
    assert((Offset.zero & size).contains(position));
    final Offset center = size.center(Offset.zero);
    final double distance = (position - center).distance;
    double outside = (size.width > size.height ? size.height : size.width) / 2;
    double inside = outside - width;
    return (distance <= outside) && (distance >= inside);
  }
}

// dial border
/// @nodoc
class DialBorder extends ShapeBorder {
  final Offset center;
  final double radius;
  final double width;
  const DialBorder({
    required this.center,
    required this.radius,
    required this.width,
  });
  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return _getPath(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _getPath(rect);
  }

  Path _getPath(Rect rect) {
    Offset center = this.center + Offset(rect.left, rect.top);
    Path outerPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.nonZero;
    Path innerPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius - width))
      ..fillType = PathFillType.evenOdd;
    return Path.combine(PathOperation.difference, outerPath, innerPath);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return DialBorder(center: center, radius: radius * t, width: width * t);
  }
}
