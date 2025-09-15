import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../widgets/color_dot_widget.dart';
import '../widgets/logo_widget.dart';

class LogoDemoPage extends StatefulWidget {
  const LogoDemoPage({super.key});

  @override
  State<LogoDemoPage> createState() => _LogoDemoPageState();
}

class _LogoDemoPageState extends State<LogoDemoPage> {
  // ---------------- Canvas state ----------------
  double _diameter = 150;
  bool _animate = true;
  bool _outerOrbit = true;
  bool _innerOrbit = true;
  bool _outerCW = true;
  bool _innerCW = false;
  bool _adaptiveBg = true;
  bool _depthScale = true;

  double _outerSecs = 12;
  double _innerSecs = 8;
  bool _autoOrbitContrast = true;
  double _stroke = 2.0;

  Color _parrot = const Color(0xFF5AB115);
  Color _turtle = const Color(0xFFFFB53C);
  Color _titi = const Color(0xFF433038);

  // ---------------- Curve selector ----------------
  static const Map<String, Curve> _kCurves = <String, Curve>{
    'linear': Curves.linear,
    'easeInOut': Curves.easeInOut,
    'easeIn': Curves.easeIn,
    'easeOut': Curves.easeOut,
    'decelerate': Curves.decelerate,
    'fastOutSlowIn': Curves.fastOutSlowIn,
  };
  String _curveKey = 'linear';

  // ---------------- HEX editors (controlled) ----------------
  static final List<String> _hexSuggestions = <String>[
    '#5AB115',
    '#FFB53C',
    '#433038',
    '#FFFFFF',
    '#000000',
    '#E0E0E0',
    '#1E1E1E',
  ];

  String _parrotHex = '#FF5AB115';
  String _turtleHex = '#FFFFB53C';
  String _titiHex = '#FF433038';

  String? _parrotErr;
  String? _turtleErr;
  String? _titiErr;

  final GlobalKey _repaintKey = GlobalKey();

  // ---------------- Helpers ----------------
  String? _validateHex(String val) {
    final String v = val.trim();
    final RegExp re = RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$');
    if (!re.hasMatch(v)) {
      return 'Use #RRGGBB or #AARRGGBB';
    }
    return null;
  }

  Color _parseHex(String val) {
    String v = val.trim().replaceFirst('#', '');
    if (v.length == 6) {
      v = 'FF$v';
    }
    return Color(int.parse(v, radix: 16));
  }

  Future<Uint8List?> _capturePng() async {
    final RenderRepaintBoundary? boundary =
        _repaintKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) {
      return null;
    }
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData?.buffer.asUint8List();
  }

  Future<void> _onExport() async {
    final bool prev = _animate;
    setState(() => _animate = false);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final Uint8List? png = await _capturePng();
    if (prev) {
      setState(() => _animate = true);
    }

    if (!mounted) {
      return;
    }
    if (png == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nothing to export')));
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('PNG preview'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.memory(png),
              const SizedBox(height: 12),
              Text('Bytes: ${png.length}'),
              const SizedBox(height: 8),
              const Text(
                'Tip: integrate path_provider to save this PNG to disk.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _reset() {
    setState(() {
      _diameter = 150;
      _animate = true;
      _outerOrbit = true;
      _innerOrbit = true;
      _outerCW = true;
      _innerCW = false;
      _adaptiveBg = true;
      _depthScale = true;
      _outerSecs = 12;
      _innerSecs = 8;
      _autoOrbitContrast = true;
      _stroke = 2.0;
      _curveKey = 'linear';

      _parrot = const Color(0xFF5AB115);
      _turtle = const Color(0xFFFFB53C);
      _titi = const Color(0xFF433038);

      _parrotHex = UtilsForTheme.colorToHex(_parrot);
      _turtleHex = UtilsForTheme.colorToHex(_turtle);
      _titiHex = UtilsForTheme.colorToHex(_titi);
      _parrotErr = _turtleErr = _titiErr = null;
    });
  }

  @override
  void initState() {
    super.initState();
    // Inicializa los hex acorde al color
    _parrotHex = UtilsForTheme.colorToHex(_parrot);
    _turtleHex = UtilsForTheme.colorToHex(_turtle);
    _titiHex = UtilsForTheme.colorToHex(_titi);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle label = theme.textTheme.bodyMedium!;
    final Color orbitColor = _autoOrbitContrast
        ? (theme.brightness == Brightness.light
              ? Colors.black26
              : Colors.white30)
        : const Color(0x33FFFFFF);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LogoDemoPage'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Reset to defaults',
            onPressed: _reset,
            icon: const Icon(Icons.restore),
          ),
          IconButton(
            tooltip: 'Export PNG',
            onPressed: _onExport,
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // ----------- Canvas preview -----------
                    Center(
                      child: RepaintBoundary(
                        key: _repaintKey,
                        child: LogoWidget(
                          diameter: _diameter,
                          parrotColor: _parrot,
                          turtleColor: _turtle,
                          titiColor: _titi,
                          adaptiveBackground: _adaptiveBg,
                          animate: _animate,
                          showOuterOrbit: _outerOrbit,
                          showInnerOrbit: _innerOrbit,
                          outerClockwise: _outerCW,
                          innerClockwise: _innerCW,
                          outerPeriod: Duration(
                            milliseconds: (_outerSecs * 1000).round(),
                          ),
                          innerPeriod: Duration(
                            milliseconds: (_innerSecs * 1000).round(),
                          ),
                          curve: _kCurves[_curveKey]!,
                          orbitColor: orbitColor,
                          stroke: _stroke,
                          depthScaleEnabled: _depthScale,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ----------- Controls -----------
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  'Diameter: ${_diameter.toStringAsFixed(0)}',
                                  style: label,
                                ),
                              ],
                            ),
                            Slider(
                              min: 120,
                              max: 600,
                              value: _diameter,
                              onChanged: (double v) =>
                                  setState(() => _diameter = v),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: <Widget>[
                                FilterChip(
                                  label: const Text('Animate'),
                                  selected: _animate,
                                  onSelected: (bool v) =>
                                      setState(() => _animate = v),
                                ),
                                FilterChip(
                                  label: const Text('Show outer orbit'),
                                  selected: _outerOrbit,
                                  onSelected: (bool v) =>
                                      setState(() => _outerOrbit = v),
                                ),
                                FilterChip(
                                  label: const Text('Show inner orbit'),
                                  selected: _innerOrbit,
                                  onSelected: (bool v) =>
                                      setState(() => _innerOrbit = v),
                                ),
                                FilterChip(
                                  label: const Text('Outer clockwise'),
                                  selected: _outerCW,
                                  onSelected: (bool v) =>
                                      setState(() => _outerCW = v),
                                ),
                                FilterChip(
                                  label: const Text('Inner clockwise'),
                                  selected: _innerCW,
                                  onSelected: (bool v) =>
                                      setState(() => _innerCW = v),
                                ),
                                FilterChip(
                                  label: const Text('Adaptive background'),
                                  selected: _adaptiveBg,
                                  onSelected: (bool v) =>
                                      setState(() => _adaptiveBg = v),
                                ),
                                FilterChip(
                                  label: const Text('Depth scale (0.8–1.2)'),
                                  selected: _depthScale,
                                  onSelected: (bool v) =>
                                      setState(() => _depthScale = v),
                                ),
                              ],
                            ),

                            const Divider(height: 32),

                            // Curva
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Animation curve:', style: label),
                            ),
                            const SizedBox(height: 8),
                            DropdownButton<String>(
                              value: _curveKey,
                              onChanged: (String? v) =>
                                  setState(() => _curveKey = v!),
                              items: _kCurves.keys
                                  .map(
                                    (String k) => DropdownMenuItem<String>(
                                      value: k,
                                      child: Text(k),
                                    ),
                                  )
                                  .toList(),
                            ),

                            const SizedBox(height: 16),

                            // Velocidades
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Speeds (seconds per revolution):',
                                style: label,
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Outer: ${_outerSecs.toStringAsFixed(1)} s',
                                      ),
                                      Slider(
                                        min: 2,
                                        max: 30,
                                        divisions: 56,
                                        value: _outerSecs,
                                        onChanged: (double v) =>
                                            setState(() => _outerSecs = v),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Inner: ${_innerSecs.toStringAsFixed(1)} s',
                                      ),
                                      Slider(
                                        min: 2,
                                        max: 30,
                                        divisions: 56,
                                        value: _innerSecs,
                                        onChanged: (double v) =>
                                            setState(() => _innerSecs = v),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const Divider(height: 32),

                            // Órbitas
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: <Widget>[
                                FilterChip(
                                  label: const Text('Auto-contrast orbits'),
                                  selected: _autoOrbitContrast,
                                  onSelected: (bool v) =>
                                      setState(() => _autoOrbitContrast = v),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Orbit stroke: ${_stroke.toStringAsFixed(1)}',
                                      ),
                                      Slider(
                                        min: 0.5,
                                        max: 6.0,
                                        value: _stroke,
                                        onChanged: (double v) =>
                                            setState(() => _stroke = v),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const Divider(height: 32),

                            // ---------- Color editors (JocaaguraAutocompleteInputWidget) ----------
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Colors (#RRGGBB or #AARRGGBB):',
                                style: label,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Row(
                              children: <Widget>[
                                ColorDotWidget(_parrot),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: JocaaguraAutocompleteInputWidget(
                                    label: 'Parrot',
                                    placeholder: '#5AB115',
                                    icondata: Icons.color_lens,
                                    suggestList: _hexSuggestions,
                                    // controlled:
                                    value: _parrotHex,
                                    errorText: _parrotErr,
                                    onChangedAttempt: (String val) {
                                      setState(() {
                                        _parrotHex = val;
                                        _parrotErr = _validateHex(val);
                                        if (_parrotErr == null) {
                                          _parrot = _parseHex(val);
                                        }
                                      });
                                    },
                                    onSubmittedAttempt: (String val) {
                                      setState(() {
                                        _parrotHex = val;
                                        _parrotErr = _validateHex(val);
                                        if (_parrotErr == null) {
                                          _parrot = _parseHex(val);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: <Widget>[
                                ColorDotWidget(_turtle),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: JocaaguraAutocompleteInputWidget(
                                    label: 'Turtle',
                                    placeholder: '#FFB53C',
                                    icondata: Icons.color_lens,
                                    suggestList: _hexSuggestions,
                                    value: _turtleHex,
                                    errorText: _turtleErr,
                                    onChangedAttempt: (String val) {
                                      setState(() {
                                        _turtleHex = val;
                                        _turtleErr = _validateHex(val);
                                        if (_turtleErr == null) {
                                          _turtle = _parseHex(val);
                                        }
                                      });
                                    },
                                    onSubmittedAttempt: (String val) {
                                      setState(() {
                                        _turtleHex = val;
                                        _turtleErr = _validateHex(val);
                                        if (_turtleErr == null) {
                                          _turtle = _parseHex(val);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: <Widget>[
                                ColorDotWidget(_titi),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: JocaaguraAutocompleteInputWidget(
                                    label: 'Titi',
                                    placeholder: '#433038',
                                    icondata: Icons.color_lens,
                                    suggestList: _hexSuggestions,
                                    value: _titiHex,
                                    errorText: _titiErr,
                                    onChangedAttempt: (String val) {
                                      setState(() {
                                        _titiHex = val;
                                        _titiErr = _validateHex(val);
                                        if (_titiErr == null) {
                                          _titi = _parseHex(val);
                                        }
                                      });
                                    },
                                    onSubmittedAttempt: (String val) {
                                      setState(() {
                                        _titiHex = val;
                                        _titiErr = _validateHex(val);
                                        if (_titiErr == null) {
                                          _titi = _parseHex(val);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: _reset,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reset colors'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
