import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dial/dial.dart';
import 'package:flutter_test/flutter_test.dart';

// Remove some boilerplate
extension FinderExtensions on Finder {
  String? getString() {
    Text text = evaluate().single.widget as Text;
    return text.data;
  }
}

// Keys for finding Widgets
const Key kPercentKey = Key('percentKey');
const Key kStopKey = Key('stopKey');
const Key kDialKey = Key('dialKey');
const Key kFocusedKey = Key('focusedKey');

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  Image testImage = await getTestImage();

  testWidgets('Dial tap and turn', (tester) async {
    await tester.pumpWidget(
      TestDial(
        dialKey: kDialKey,
        initialValue: 50.0,
        image: testImage,
      ),
    );
    await tester.pumpAndSettle();

    // Find the Widgets of interest
    Finder percentFinder = find.byKey(kPercentKey);
    Finder stopFinder = find.byKey(kStopKey);
    Finder focusedFinder = find.byKey(kFocusedKey);
    Finder dialFinder = find.byKey(kDialKey);

    expect(percentFinder, findsOneWidget);
    expect(stopFinder, findsOneWidget);
    expect(focusedFinder, findsOneWidget);
    expect(dialFinder, findsOneWidget);

    // test Widget data after first build
    expect(percentFinder.getString(), '50.0');
    expect(stopFinder.getString(), '4');
    expect(focusedFinder.getString(), 'Unfocused');

    // test tap to focus
    await tester.tap(dialFinder);
    await tester.pumpAndSettle();
    expect(focusedFinder.getString(), 'Focused');

    // test dialing
    Offset dialCenter = tester.getCenter(dialFinder);
    Offset startDrag = dialCenter + const Offset(-50.0, 0.0);
    Offset endDrag = dialCenter + const Offset(0.0, 50.0);

    await tester.dragFrom(startDrag, endDrag);
    await tester.pumpAndSettle();
    String? dialedPercent = percentFinder.getString();
    String? dialedStop = stopFinder.getString();
    expect(true, dialedPercent != '50.0');
    expect(true, dialedStop != '4');

    // test tap to unfocus
    await tester.tap(dialFinder);
    await tester.pumpAndSettle();
    expect(focusedFinder.getString(), 'Unfocused');

    // test dialing was disabled when not focused
    await tester.dragFrom(startDrag, endDrag);
    await tester.pumpAndSettle();
    expect(dialedPercent, percentFinder.getString());
    expect(dialedStop, stopFinder.getString());
  });
}

// Create a test Image without requiring any package assets
Future<Image> getTestImage() async {
  final bytes = Uint8List.fromList([
    137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0,
    1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 10, 73, 68, 65,
    84, 120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73,
    69, 78, 68, 174, 66, 96, 130 // prevent dart formatting
  ]);

  // copy from decodeImageFromList of package:flutter/painting.dart
  final codec = await instantiateImageCodec(bytes);
  final frameInfo = await codec.getNextFrame();
  final pngBytes =
      await frameInfo.image.toByteData(format: ImageByteFormat.png);
  return Image.memory(Uint8List.view(pngBytes!.buffer));
}

// Test App, wrapper for Dial Widget and Dial state visualization Widgets
class TestDial extends StatefulWidget {
  const TestDial(
      {super.key,
      this.dialKey,
      required this.initialValue,
      required this.image});

  final Key? dialKey;
  final double initialValue;
  final Image image;
  final double size = 120;
  final int numStops = 8;
  final Color color = Colors.white;
  final double opacity = 0.5;

  @override
  State<TestDial> createState() => _TestDialState();
}

class _TestDialState extends State<TestDial> {
  // State
  int _currentStop = 0;
  double _currentPercent = 0.0;
  String _focused = 'Unfocused';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Column(
        children: [
          Text('$_currentPercent', key: kPercentKey),
          Text('$_currentStop', key: kStopKey),
          Text(_focused, key: kFocusedKey),
          Dial(
            key: widget.dialKey,
            size: widget.size,
            ringWidth: widget.size / 3,
            value: widget.initialValue,
            stopCount: widget.numStops,
            clip: false,
            color: widget.color,
            opacity: widget.opacity,
            image: widget.image,
            indicatorColor: Colors.black,
            indicatorWidth: 3,
            indicatorLength: widget.size / 3,
            onDialed: (degrees, percent, stopNumber) {
              setState(
                () {
                  _currentPercent = percent;
                  _currentStop = stopNumber;
                },
              );
            },
            onFocusChange: (focused) {
              setState(() => _focused = focused ? 'Focused' : 'Unfocused');
            },
          ),
        ],
      ),
    );
  }
}
