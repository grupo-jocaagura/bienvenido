import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Draws a tri-orbit logo composed of:
/// - A main circular container.
/// - Two optional orbits (outer & inner).
/// - Three big nodes rotating clockwise on the outer orbit.
/// - Three small nodes rotating counter-clockwise on the inner orbit.
///
/// ### Geometry (relative to [diameter])
/// - Outer orbit diameter = `0.7333333 * diameter`
/// - Inner orbit diameter = `0.293333 * diameter`
/// - Big node diameter    = `0.20 * diameter`
/// - Small node diameter  = `0.08 * diameter`
///
/// Nodes are placed on the vertices of an equilateral triangle, with the top
/// vertex at `initialAngleDeg` (default 90°, “12 o'clock”).
///
/// ### Animation
/// - When [animate] is true, the outer set spins with [outerPeriod] and the
///   inner set with [innerPeriod].
/// - Directions can be inverted with [outerClockwise] / [innerClockwise].
/// - Animation uses [curve].
/// - Animation auto-pauses when offstage via `TickerMode`.
///
/// ### Depth scale
/// If [depthScaleEnabled] is true, nodes scale between [farScale] (top) and
/// [nearScale] (bottom) according to their vertical position along the orbit,
/// giving a near/far illusion. Defaults to 0.8–1.2.
///
/// ### Example
/// ```dart
/// LogoWidget(
///   diameter: 320,
///   parrotColor: const Color(0xFF5AB115),
///   turtleColor: const Color(0xFFFFB53C),
///   titiColor:   const Color(0xFF433038),
///   animate: true,
///   showOuterOrbit: true,
///   showInnerOrbit: true,
///   depthScaleEnabled: true,
///   curve: Curves.easeInOut,
/// )
/// ```
class LogoWidget extends StatefulWidget {
  const LogoWidget({
    required this.diameter,
    super.key,
    this.parrotColor = const Color(0xFF5AB115), // Loro (Educación)
    this.turtleColor = const Color(0xFFFFB53C), // Tortuga (Logística)
    this.titiColor = const Color(0xFF433038), // Tití (Comercio)
    this.backgroundColor = Colors.transparent,
    this.adaptiveBackground = false,
    this.animate = true,
    this.showOuterOrbit = false,
    this.showInnerOrbit = false,
    this.outerClockwise = true,
    this.innerClockwise = false,
    this.outerPeriod = const Duration(seconds: 12),
    this.innerPeriod = const Duration(seconds: 8),
    this.curve = Curves.linear,
    this.stroke = 2.0,
    this.orbitColor = const Color(0x33FFFFFF),
    this.initialAngleDeg = 90.0,
    this.depthScaleEnabled = false,
    this.nearScale = 1.2,
    this.farScale = 0.8,
  });

  /// Main container diameter (in logical pixels).
  final double diameter;

  /// Brand colors for the three nodes.
  final Color parrotColor;
  final Color turtleColor;
  final Color titiColor;

  /// Main circle fill color. If transparent and [adaptiveBackground] is `true`,
  /// a color will be resolved from the current Theme.
  final Color backgroundColor;

  /// Enable background auto-color based on Theme if [backgroundColor] is transparent.
  final bool adaptiveBackground;

  /// Whether to animate both orbits.
  final bool animate;

  /// Whether to paint the outer orbit.
  final bool showOuterOrbit;

  /// Whether to paint the inner orbit.
  final bool showInnerOrbit;

  /// Rotation direction for the big nodes on the outer orbit.
  final bool outerClockwise;

  /// Rotation direction for the small nodes on the inner orbit.
  final bool innerClockwise;

  /// Period for a full revolution of the outer set.
  final Duration outerPeriod;

  /// Period for a full revolution of the inner set.
  final Duration innerPeriod;

  /// Animation curve (applied to both sets).
  final Curve curve;

  /// Stroke width for the orbit circles.
  final double stroke;

  /// Color used to draw the orbits.
  final Color orbitColor;

  /// Base orientation angle in degrees. 90° means top vertex at 12 o'clock.
  final double initialAngleDeg;

  /// Enables depth scaling (near/far illusion).
  final bool depthScaleEnabled;

  /// Scale when the node is visually closest (bottom of the orbit).
  final double nearScale;

  /// Scale when the node is visually farthest (top of the orbit).
  final double farScale;

  @override
  State<LogoWidget> createState() => _LogoWidgetState();
}

class _LogoWidgetState extends State<LogoWidget> with TickerProviderStateMixin {
  late final AnimationController _outerCtrl;
  late final AnimationController _innerCtrl;

  @override
  void initState() {
    super.initState();
    _outerCtrl = AnimationController(vsync: this, duration: widget.outerPeriod);
    _innerCtrl = AnimationController(vsync: this, duration: widget.innerPeriod);
    // No TickerMode here.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeStart(); // Safe to touch TickerMode here.
  }

  @override
  void didUpdateWidget(covariant LogoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.outerPeriod != widget.outerPeriod) {
      _outerCtrl.duration = widget.outerPeriod;
      if (_outerCtrl.isAnimating) {
        _outerCtrl.repeat();
      }
    }
    if (oldWidget.innerPeriod != widget.innerPeriod) {
      _innerCtrl.duration = widget.innerPeriod;
      if (_innerCtrl.isAnimating) {
        _innerCtrl.repeat();
      }
    }
    _maybeStart();
  }

  void _maybeStart() {
    final bool enabled = TickerMode.of(context);
    if (widget.animate && enabled) {
      if (!_outerCtrl.isAnimating) {
        _outerCtrl.repeat();
      }
      if (!_innerCtrl.isAnimating) {
        _innerCtrl.repeat();
      }
    } else {
      _outerCtrl.stop();
      _innerCtrl.stop();
    }
  }

  @override
  void dispose() {
    _outerCtrl.dispose();
    _innerCtrl.dispose();
    super.dispose();
  }

  Color _resolveBackground(BuildContext context) {
    if (!widget.adaptiveBackground || widget.backgroundColor.a > 0.0) {
      return widget.backgroundColor;
    }
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return dark ? Colors.white : Colors.black12;
    // Tip: tweak if you need brand background.
  }

  @override
  Widget build(BuildContext context) {
    final Color bg = _resolveBackground(context);
    return SizedBox.square(
      dimension: widget.diameter,
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[_outerCtrl, _innerCtrl]),
        builder: (BuildContext context, _) {
          final double outerT = widget.curve.transform(_outerCtrl.value);
          final double innerT = widget.curve.transform(_innerCtrl.value);
          return CustomPaint(
            painter: _LogoPainter(
              diameter: widget.diameter,
              parrot: widget.parrotColor,
              turtle: widget.turtleColor,
              titi: widget.titiColor,
              background: bg,
              showOuterOrbit: widget.showOuterOrbit,
              showInnerOrbit: widget.showInnerOrbit,
              orbitColor: widget.orbitColor,
              stroke: widget.stroke,
              initialAngleDeg: widget.initialAngleDeg,
              outerAngle:
                  (widget.outerClockwise ? 1 : -1) * 2 * math.pi * outerT,
              innerAngle:
                  (widget.innerClockwise ? 1 : -1) * 2 * math.pi * innerT,
              depthScaleEnabled: widget.depthScaleEnabled,
              nearScale: widget.nearScale,
              farScale: widget.farScale,
            ),
          );
        },
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter({
    required this.diameter,
    required this.parrot,
    required this.turtle,
    required this.titi,
    required this.background,
    required this.showOuterOrbit,
    required this.showInnerOrbit,
    required this.orbitColor,
    required this.stroke,
    required this.initialAngleDeg,
    required this.outerAngle,
    required this.innerAngle,
    required this.depthScaleEnabled,
    required this.nearScale,
    required this.farScale,
  });

  final double diameter;
  final Color parrot, turtle, titi, background, orbitColor;
  final bool showOuterOrbit, showInnerOrbit;
  final double stroke;
  final double initialAngleDeg;
  final double outerAngle, innerAngle;

  final bool depthScaleEnabled;
  final double nearScale; // 1.2
  final double farScale; // 0.8

  // Geometry factors.
  static const double _kOuterOrbitFactor = 0.7333333;
  static const double _kInnerOrbitFactor = 0.293333;
  static const double _kBigNodeFactor = 0.20;
  static const double _kSmallNodeFactor = 0.08;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final Paint fill = Paint()..style = PaintingStyle.fill;
    final Paint orbit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = orbitColor;

    // Main circle
    fill.color = background;
    canvas.drawCircle(c, diameter / 2, fill);

    // Orbits
    final double rOuter = _kOuterOrbitFactor * diameter / 2;
    final double rInner = _kInnerOrbitFactor * diameter / 2;
    if (showOuterOrbit) {
      canvas.drawCircle(c, rOuter, orbit);
    }
    if (showInnerOrbit) {
      canvas.drawCircle(c, rInner, orbit);
    }

    // Base orientation
    final double base = _deg2rad(initialAngleDeg);

    // Vertex phases of an equilateral triangle.
    final List<double> phases = <double>[0, 120, 240].map(_deg2rad).toList();

    // Helpers
    double scaleForDy(double dy, double r) {
      if (!depthScaleEnabled) {
        return 1.0;
      }
      // dy in [-r, r]; map to t in [0,1], top->0 (far), bottom->1 (near)
      final double t = (dy / r + 1.0) / 2.0;
      return _lerpDouble(farScale, nearScale, t);
    }

    // Big nodes (outer orbit) — colors: parrot, turtle, titi
    final double bigR = _kBigNodeFactor * diameter / 2;
    final List<Color> bigColors = <Color>[parrot, turtle, titi];
    for (int i = 0; i < 3; i++) {
      final double a = base + phases[i] + outerAngle;
      final double dx = rOuter * math.cos(a);
      final double dy = rOuter * math.sin(a);
      final Offset p = c + Offset(dx, dy);
      final double s = scaleForDy(dy, rOuter);
      fill.color = bigColors[i];
      canvas.drawCircle(p, bigR * s, fill);
    }

    // Small nodes (inner orbit) — reuse same colors
    final double smallR = _kSmallNodeFactor * diameter / 2;
    final List<Color> smallColors = <Color>[parrot, turtle, titi];
    for (int i = 0; i < 3; i++) {
      final double a = base + phases[i] + innerAngle;
      final double dx = rInner * math.cos(a);
      final double dy = rInner * math.sin(a);
      final Offset p = c + Offset(dx, dy);
      final double s = scaleForDy(dy, rInner);
      fill.color = smallColors[i];
      canvas.drawCircle(p, smallR * s, fill);
    }
  }

  @override
  bool shouldRepaint(covariant _LogoPainter old) {
    return diameter != old.diameter ||
        parrot != old.parrot ||
        turtle != old.turtle ||
        titi != old.titi ||
        background != old.background ||
        showOuterOrbit != old.showOuterOrbit ||
        showInnerOrbit != old.showInnerOrbit ||
        orbitColor != old.orbitColor ||
        stroke != old.stroke ||
        initialAngleDeg != old.initialAngleDeg ||
        outerAngle != old.outerAngle ||
        innerAngle != old.innerAngle ||
        depthScaleEnabled != old.depthScaleEnabled ||
        nearScale != old.nearScale ||
        farScale != old.farScale;
  }

  static double _deg2rad(double d) => d * math.pi / 180.0;

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
