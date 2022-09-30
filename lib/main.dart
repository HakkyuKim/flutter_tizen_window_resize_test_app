import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

extension RandomExtension on Random {
  /// Returns a random number x in range min <= x <= max.
  int nextIntRange(int min, int max) {
    if (min > max) {
      throw ArgumentError("min cannot be larger than max.");
    }
    return min + nextInt(max - min + 1);
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class Geometry {
  const Geometry({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final int x;
  final int y;
  final int width;
  final int height;
}

enum GeometryType {
  screen,
  window,
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Window Resize',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Window Resize Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MethodChannel _kChannel = const MethodChannel('tizen/internal/window');

  Geometry? _screen;
  Geometry? _window;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    getGeometry(GeometryType.screen).then((value) => setState(
          () => _screen = value,
        ));
    getGeometry(GeometryType.window).then((value) => setState(
          () => _window = value,
        ));
  }

  Future<void> randomResize() async {
    final int x = _random.nextIntRange(0, 200);
    final int y = _random.nextIntRange(0, 200);
    final int width = _random.nextIntRange(200, _screen!.width);
    final int height = _random.nextIntRange(200, _screen!.height);
    await resize(x, y, width, height);
  }

  Future<void> resize(int x, int y, int width, int height) async {
    await _kChannel.invokeMethod(
      'setWindowGeometry',
      {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      },
    );
    getGeometry(GeometryType.window).then((value) => setState(
          () => _window = value,
        ));
  }

  Future<Geometry> getGeometry(GeometryType type) async {
    final Map<dynamic, dynamic> map =
        await _kChannel.invokeMethod('get${type.name.capitalize()}Geometry');
    return Geometry(
      x: map['x'] as int? ?? 0,
      y: map['y'] as int? ?? 0,
      width: map['width'] as int,
      height: map['height'] as int,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            if (_screen != null)
              Text(
                  'Screen Geometry: (${_screen!.x}, ${_screen!.y}) (${_screen!.width}, ${_screen!.height})'),
            if (_window != null)
              Text(
                  'Window Geometry: (${_window!.x}, ${_window!.y}) (${_window!.width}, ${_window!.height})'),
            ElevatedButton(
                onPressed: () async => await randomResize(),
                child: const Text('Random Resize')),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () async => await resize(
                    _screen!.x, _screen!.y, _screen!.width, _screen!.height),
                child: const Text('To Full Screen')),
          ],
        ),
      ),
    );
  }
}
