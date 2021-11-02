import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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

  String _windowWidth = 'Unknown';
  String _windowHeight = 'Unknown';
  String _screenWidth = 'Unknown';
  String _screenHeight = 'Unknown';

  Future<void> resize() async {
    await _kChannel.invokeMethod(
        'setWindowGeometry', {'x': 50, 'y': 100, 'width': 700, 'height': 700});
  }

  Future<void> getGeometry() async {
    final dynamic map = await _kChannel.invokeMethod('getWindowGeometry');
    setState(() {
      _windowWidth = (map['width'] as int).toString();
      _windowHeight = (map['height'] as int).toString();
    });
  }

  Future<void> getScreenSize() async {
    final dynamic map = await _kChannel.invokeMethod('getScreenGeometry');
    setState(() {
      _screenWidth = (map['width'] as int).toString();
      _screenHeight = (map['height'] as int).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Screen Size: $_screenWidth $_screenHeight'),
            Text('Window Size: $_windowWidth $_windowHeight'),
            TextButton(
                onPressed: () async => getScreenSize(),
                child: const Text('getWindowScreenSize')),
            TextButton(
                onPressed: () async => await getGeometry(),
                child: const Text('getWindowGeometry')),
            TextButton(
                onPressed: () async => await resize(),
                child: const Text('Resize')),
          ],
        ),
      ),
    );
  }
}
