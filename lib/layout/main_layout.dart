import 'package:flutter/material.dart';
import 'package:overdriveapp/layout/knobs/pedal_knob.dart';
import 'package:overdriveapp/layout/buttons/metal_button.dart';

class OverdrivePage extends StatefulWidget {
  @override
  _OverdrivePageState createState() => _OverdrivePageState();
}

class _OverdrivePageState extends State<OverdrivePage> {
  double _gainValue = 0.5;
  double _levelValue = 0.7;
  bool _isOn = false;

// Audio settings
  bool _mPlayerIsInited = false;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    // Here we initiate the audio processing.
  }

  @override
  void dispose() {
    // Here we execute dispose of the audio.
    super.dispose();
  }

  void play() async {
    if (!busy && _mPlayerIsInited) {
      busy = true;
      print("===================================> paying!!!");
    }
  }

  void stop() {
    busy = false;
    print("===================================> stopped!!!");
    // stop here!
  }

  void _onGainChanged(double value) {
    setState(() {
      _gainValue = value;
    });
    // send gain update here!
  }

  void _onLevelChanged(double value) async {
    setState(() {
      _levelValue = value;
    });
    // send update volume here!
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
                        play();
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
