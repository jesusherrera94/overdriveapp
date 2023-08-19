# Flutter Overdrive app

This is an app that takes an audio file and applies an overdrive to it!

## Installation

1. run ```flutter pub get``` to install all dependencies.
2. run ```flutter run``` to run the app with your cellphone connected.
3. Enjoy!

## Documentation

Helpful documentation is in the following links:
1. Audio theory: [link to docs](https://docs.google.com/document/d/17dNskDEHrdbJIFIjJdz14ALD88HLGdBqRjMoFj4HiQo/edit?usp=sharing).
2. Audio Presentation: [link ppt](https://docs.google.com/presentation/d/1sQCD6c2s1w3r5DLzBASFZG1P3eZXjJXIGei7ty56MCc/edit?usp=sharing)
3. Algorithm behavior: [link to calc](https://docs.google.com/spreadsheets/d/1ag9R1tYSgIRal5PO61icxDJS8EUvx6td9cEMrhQkPxc/edit?usp=sharing)

## Integration

```dart
//Integrate a function called process apart from main_layout.
Future<Uint8List> _process(String path) async {
    var asset = await rootBundle.load(path);
    List<int> assetBuffer = asset.buffer.asUint8List();
    List<int> assetBufferCopy = List.from(assetBuffer);
    printValues(assetBuffer);
    for (int i = 0; i < assetBuffer.length; i++) {
      // Normalize amplitude between 0,1
      double value = ((assetBuffer[i].toDouble() / 128.0) - 1.0);
      // validation to avoid a crash
      if (_gainValue > 0) {
        // applies distortion or adds gain.
        value = (value.abs() * value.abs() * _gainValue * 2.0).toDouble();
      }
      // transform to 256 byte value
      assetBufferCopy[i] = (value * 128.0 + 128.0).toInt();
    }
    return Uint8List.fromList(assetBufferCopy);
  }
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.
