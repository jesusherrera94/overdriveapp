AudioManager audioManager;

@override
void initState() {
  super.initState();
  audioManager = AudioManager.instance;
  audioManager.init();
}




class OverdriveEffect extends AudioEffect {
  double gain;
  double drive;

  OverdriveEffect({required this.gain, required this.drive});

  @override
  List<AudioSample> process(List<AudioSample> samples) {
    final processedSamples = <AudioSample>[];

    for (var sample in samples) {
      final amplitude = sample.left.abs() + sample.right.abs();
      final input = sample.left + sample.right;
      final output = input * gain;
      
      if (output > drive) {
        final softClippedOutput = drive + ((output - drive) / (1 + (output - drive).abs()));
        sample.left = softClippedOutput * (sample.left / amplitude);
        sample.right = softClippedOutput * (sample.right / amplitude);
      } else if (output < -drive) {
        final softClippedOutput = -drive + ((output + drive) / (1 + (output + drive).abs()));
        sample.left = softClippedOutput * (sample.left / amplitude);
        sample.right = softClippedOutput * (sample.right / amplitude);
      } else {
        sample.left = output * (sample.left / amplitude);
        sample.right = output * (sample.right / amplitude);
      }
      
      processedSamples.add(sample);
    }
    
    return processedSamples;
  }
}



Audio(
  audio: AudioSource.file(
    File('path_to_your_audio_file.mp3'),
  ),
  effects: [
    OverdriveEffect(gain: 1.0, drive: 0.5), // Adjust the gain and drive values as desired
  ],
),



// From here =======================================================================================================================



import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

void main() {
  runApp(OverdriveApp());
}

class OverdriveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Overdrive Effect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Overdrive Effect'),
        ),
        body: Center(
          child: OverdrivePlayer(),
        ),
      ),
    );
  }
}

class OverdrivePlayer extends StatefulWidget {
  @override
  _OverdrivePlayerState createState() => _OverdrivePlayerState();
}

class _OverdrivePlayerState extends State<OverdrivePlayer> {
  FlutterSound flutterSound = FlutterSound();
  String audioPath = 'assets/audio.wav'; // Replace with your audio file path
  double gain = 1.0;

  bool isPlaying = false;
  Stream<Fooder>? audioStream;
  int bufferSize = 4096;

  @override
  void dispose() {
    flutterSound.stopPlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Gain'),
            Slider(
              min: 0.5,
              max: 2.0,
              value: gain,
              onChanged: (value) {
                setState(() {
                  gain = value;
                });
              },
            ),
          ],
        ),
        SizedBox(height: 16),
        FlatButton(
          onPressed: isPlaying ? null : _playAudioWithOverdrive,
          child: Text('Play Audio with Overdrive'),
        ),
        SizedBox(height: 16),
        StreamBuilder<Fooder>(
          stream: audioStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              double level = _calculateAudioLevel(snapshot.data!.buffer);
              return LinearProgressIndicator(value: level);
            } else {
              return Container();
            }
          },
        ),
      ],
    );
  }

  void _playAudioWithOverdrive() async {
    setState(() {
      isPlaying = true;
    });

    await flutterSound.startPlayer(audioPath);

    audioStream = flutterSound.audioStream(bufferSize: bufferSize);

    audioStream?.listen((Fooder? audio) async {
      if (audio != null) {
        List<int> audioData = audio.buffer;

        for (int i = 0; i < audioData.length; i++) {
          double value = (audioData[i].toDouble() / 128.0 - 1.0) * gain;
          value = (value.abs() * value.abs() * value.abs()).toDouble();
          audioData[i] = (value * 128.0 + 128.0).toInt();
        }

        await flutterSound.writeChunk(audioData);

        setState(() {});
      }
    }, onDone: () {
      setState(() {
        isPlaying = false;
      });
    });
  }

  double _calculateAudioLevel(List<int> audioData) {
    double sum = 0.0;
    for (int sample in audioData) {
      sum += sample.abs();
    }
    double average = sum / audioData.length;
    return average / 128.0; // Normalize to the range of 0.0 to 1.0
  }
}
