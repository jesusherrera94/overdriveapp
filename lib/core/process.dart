import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/services.dart' show rootBundle;

class Process {
  int tSampleRate;
  int tNumChannels;
  String audioRawPath;
  FlutterSoundPlayer? _mPlayer;
  Uint8List? audioArrayData;

  late double _gainValue;

  Process(
      {required this.audioRawPath,
      required this.tSampleRate,
      required this.tNumChannels}) {
    _mPlayer = FlutterSoundPlayer();
  }

  void dispose() {
    _mPlayer!.stopPlayer();
    _mPlayer!.closePlayer();
    _mPlayer = null;
  }

  Future<Uint8List> _process(String path) async {
    var asset = await rootBundle.load(path);
    List<int> assetBuffer = asset.buffer.asUint8List();
    List<int> assetBufferCopy = List.from(assetBuffer);
    printValues(assetBuffer);
    for (int i = 0; i < assetBuffer.length; i++) {
      // Normalize amplitude between 0,1
      double value = ((assetBuffer[i].toDouble() / 128.0) - 1.0);
      // validation to avoid crash
      if (_gainValue > 0) {
        // applies distortion or add gain.
        value = (value.abs() * value.abs() * _gainValue * 2.0).toDouble();
      }
      // transform to 256 byte value
      assetBufferCopy[i] = (value * 128.0 + 128.0).toInt();
    }
    return Uint8List.fromList(assetBufferCopy);
  }

  void printValues(buffer) {
    for (int i = 0; i < 100; i++) {
      print(buffer[i]);
    }
  }

  Future<void> init() async {
    await _mPlayer!.openPlayer();
    audioArrayData = FlutterSoundHelper().waveToPCMBuffer(
      inputBuffer: await _process(audioRawPath),
    );
    await _mPlayer!.startPlayerFromStream(
      codec: Codec.pcm16,
      numChannels: tNumChannels,
      sampleRate: tSampleRate,
    );
  }

  Future<void> play() async {
    await _mPlayer!.feedFromStream(audioArrayData!);
  }

  void stop() {
    _mPlayer!.stopPlayer();
  }

  void updateVolume(value) async {
    await _mPlayer?.setVolume(value);
  }

  void updateGain(newGain) {
    _gainValue = newGain;
  }

  // update volume ///
}
