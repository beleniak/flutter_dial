// Flutter "Counter" template code converted to demonstrate a Dial Widget.

import 'package:flutter/material.dart';
import 'package:flutter_dial/dial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Dial Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Flutter Dial Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _position = 0;
  final double _value = 30.0;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = _value.toStringAsFixed(1);
    _position = 5;
  }

  void _setPosition(int stopNumber) {
    if (_position != stopNumber) {
      setState(() => _position = stopNumber);
    }
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
            const Text('Dial setting:'),
            Text('$_position',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 40),
            Dial(
              key: ValueKey(_value),
              value: _value,
              image: Image.asset('assets/images/256_knob.png'),
              size: 200,
              ringWidth: 200 / 4,
              stopCount: 10,
              color: Colors.teal,
              indicatorWidth: 2,
              indicatorLength: 200 / 4,
              indicatorColor: Colors.black,
              opacity: 0.5,
              onDialed: (degrees, percent, stopNumber) =>
                  _setPosition(stopNumber),
            ),
          ],
        ),
      ),
    );
  }
}
