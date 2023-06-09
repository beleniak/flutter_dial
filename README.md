<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

A Flutter package implementing a Dial for input and visual display.

## Features

A Dial begins as an image with a transparent background (png, gif, tiff).

In order to maintain any image skeuomorphism, the image is not rotated.
A visual rotation indicator provides feedback on dial position.

When a Dial is selected via tap, a translucent control ring becomes visible
and can be manipulated via rotation.  The color(s), width, and opacity of the
control ring are programmable.  A Dial cannot be manipulated if not selected.

The control ring may have a single color, or be colored with a cold/hot
color gradient.

A Dial is deselected with a second tap.  In addition, Dials are focusable
widgets.  When other focusable widgets (including Dials) are selected,
the previous Dial will deselect to avoid input errors.

A Dial can have infinite range on [0.0, 360] degrees, or it can
be programmed to have a fixed number of evenly placed radial stops.

A callback closure function ```onDialed()``` exposes the current rotational value
of the Dial in the form of current ```(degrees, percent, stop number)``` of rotation.

Persistence is available via ```Dial.value``` as initial state, and the ```percent```
value from the ```Dial.onDialed()``` callback for current state.

When a Dial receives or loses focus, ```Dial.onFocusChange()``` will be called.  This
allows programming of effects external to the Dial (eg, highlighting, bolding) on
associated Widgets.



### A dial controlling a meter:
![Metered Dial](https://raw.githubusercontent.com/beleniak/flutter_dial/assets/Metered_Dial.gif)

This demonstrates:
1. tap to focus/defocus
2. dialing
3. responsive output on the meter

When the Dial has focus, the meter will "light up" when indicating the dials position.



### Several dials with outputs monitored on simulated LED displays:
![Industrial_Dials](https://raw.githubusercontent.com/beleniak/flutter_dial/assets/Industrial_Dials.gif)

This demonstrates:
1. Automatic focus change between the Dials
2. LED panels indicating the active Dial by brightness
3. Different colored Dial control rings
4. Two Dials with radial stops
5. One Dial infinitely adjustable between 0 and 100 percent
6. A "washing machine" style cold/hot control ring indicating increasing percentage

## Getting started

1. Add a dependency in pubspec.yaml:  
```flutter_dial: ^any```

2. Import into your appropriate implementation dart files:  
```import 'package:flutter_dial/flutter_dial.dart'```

3. Use ```Dial(size, ringWidth, color, image, ...)``` widget(s) as required.

## Usage

The Flutter "Counter" example Stateful Widget rewritten to use a Dial.
Assumption: a suitable image is in the ```/assets/images``` folder.

```dart
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _position = 0;

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
            Text('$_position', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 40),
            Dial(
              value: 0.0,
              image: Image.asset('assets/images/my_dial.png'),
              size: 200,
              ringWidth: 50,
              stopCount: 10,
              color: Colors.teal,
              indicatorColor: Colors.black,
              opacity: 0.5,
              onDial: (degrees, percent, stopNumber) => setState(() => _position = stopNumber),
            ),
          ],
        ),
      ),
    );
  }
}

```

## Additional information

Source repository:
https://github.com/beleniak/flutter_dial

The example in the repository contains a free-to-use sample dial image.
