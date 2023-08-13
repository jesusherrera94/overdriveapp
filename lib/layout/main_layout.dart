import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:overdriveapp/layout/knobs/pedal_knob.dart';
import 'package:overdriveapp/layout/buttons/metal_button.dart';
import 'package:flutter/services.dart' show rootBundle;

class OverdrivePage extends StatefulWidget {
  @override
  _OverdrivePageState createState() => _OverdrivePageState();
}

class _OverdrivePageState extends State<OverdrivePage> {
  double _gainValue = 0.5;
  double _levelValue = 0.7;
  bool _isOn = false;

// Audio settings

  static const int _tSampleRate = 44100;
  static const int _tNumChannels = 1;
  static const _audioRawPath = 'assets/cleanGuitar.wav';

  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  late bool _mPlayerIsInited;
  Uint8List? audioArrayData;
  bool busy = false;

  Future<Uint8List> process(String path) async {
    var asset = await rootBundle.load(path);
    List<int> assetBuffer = asset.buffer.asUint8List();
    List<int> assetBufferCopy = List.from(assetBuffer);
    for (int i = 0; i < assetBuffer.length; i++) {
      // Normalize amplitude between 0,1
      double value = (assetBuffer[i].toDouble() / 128.0 - 1.0);
      // validation to avoid crash
      if (_gainValue > 0) {
        // applies distortion or add gain.
        value = (value.abs() * value.abs() * _gainValue * 2.0).toDouble();
      }
      // transform to 255 byte value
      assetBufferCopy[i] = (value * 128.0 + 128.0).toInt();
    }
    return Uint8List.fromList(assetBufferCopy);
  }

  Future<void> init() async {
    await _mPlayer!.openPlayer();
    audioArrayData = FlutterSoundHelper().waveToPCMBuffer(
      inputBuffer: await process(_audioRawPath),
    );
    await _mPlayer!.startPlayerFromStream(
      codec: Codec.pcm16,
      numChannels: _tNumChannels,
      sampleRate: _tSampleRate,
    );
  }

  @override
  void initState() {
    super.initState();
    // here we load the buffer that we will play.
    init().then((value) => setState(() {
          _mPlayerIsInited = true;
        }));
  }

  @override
  void dispose() {
    _mPlayer!.stopPlayer();
    _mPlayer!.closePlayer();
    _mPlayer = null;

    super.dispose();
  }

  void play(Uint8List? data) async {
    if (!busy && _mPlayerIsInited) {
      busy = true;
      await _mPlayer!.feedFromStream(data!).then((value) => busy = false);
    }
  }

  void stop() {
    busy = false;
    _mPlayer!.stopPlayer();
  }

  void initAndPlay() async {
    await init(); // we reload the init with the new gain value.
    play(audioArrayData);
  }

  void _onGainChanged(double value) {
    setState(() {
      _gainValue = value;
    });
    // Apply gain changes to audio processing
    // Your implementation goes here
  }

  void _onLevelChanged(double value) async {
    setState(() {
      _levelValue = value;
    });

    //method to control volume natively

    await _mPlayer?.setVolume(value);

    // Apply level changes to audio processing
    // Your implementation goes here
  }

  void _togglePower() {
    setState(() {
      _isOn = !_isOn;
    });
  }

  // widgets

  Widget _indicatorLed() {
    return Container(
      width: 50.0,
      height: 50.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _isOn ? Colors.red : Colors.red.shade900,
      ),
      child: Center(
        child: Text(
          _isOn ? 'ON' : 'OFF',
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('P-Drive'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
                color: const Color(0xFF0A8A3D),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(30))),
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                  const SizedBox(height: 30.0),
                  _indicatorLed(),
                  const SizedBox(height: 30.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      const Spacer(),
                      //gain knob

                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Gain',
                            style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 20.0),
                          Knob(
                            value: _gainValue,
                            min: 0.0,
                            max: 1.0,
                            color: Colors.grey.shade700,
                            onChanged: _onGainChanged,
                          ),
                        ],
                      ),

                      const Spacer(),

                      // level knob
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Level',
                            style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 20.0),
                          Knob(
                            value: _levelValue,
                            min: 0.0,
                            max: 1.0,
                            color: Colors.grey.shade700,
                            onChanged: _onLevelChanged,
                          ),
                        ],
                      ),
                      const Spacer()
                    ],
                  ),
                  const SizedBox(height: 100.0),
                  MetallicButton(
                    onPressed: () {
                      if (!_isOn) {
                        initAndPlay();
                      } else {
                        stop();
                      }
                      _togglePower();
                    },
                    child: const Text(
                      'Bypass',
                      style: TextStyle(
                          fontSize: 20.0,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey),
                    ),
                  )
                ])),
          ),
        ));
  }
}
