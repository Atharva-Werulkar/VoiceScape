import 'dart:io';
import 'package:ai_voice_detector/server_client.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';

enum ConnectionState {
  Idle,
  Loading,
  Success,
  Error,
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  String _detectedText = 'Result will be shown here...';
  late AnimationController _controller;
  File? _audioFile;
  ConnectionState _connectionState = ConnectionState.Idle;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _processAudioFile() async {
    setState(() {
      _connectionState = ConnectionState.Loading;
    });

    try {
      setState(() {
        // Reset connection state
        _connectionState = ConnectionState.Idle;
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _audioFile = File(result.files.single.path!);
        });
        print('Picked audio file: $_audioFile');

        //List<String> audioFiles = [_audioFile!.path];
        // List<List<double>> features = PreProcessing.extractFeatures(audioFiles);

        try {
          final response = await ServerClient.sendRequest(_audioFile!);
          print('Response from server: $response');

          if (response.isNotEmpty) {
            final prediction = await ServerClient.getPrediction(_audioFile!);
            print('Prediction from server: $prediction');
            setState(() {
              _detectedText =
                  prediction.replaceAll('[', '').replaceAll(']', '');
              _connectionState = ConnectionState.Success;
            });
          }
        } catch (e) {
          print('Error getting prediction from server: $e');
          setState(() {
            _connectionState = ConnectionState.Error;
          });
        }
      }
    } catch (e) {
      print('Error picking audio file: $e');
      setState(() {
        _connectionState = ConnectionState.Error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E022A),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF150833),
        title: const Text(
          'AI Voice Detector',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0E022A), Color(0xFF09012F), Color(0xFF04071C)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Detect if an audio is fake or original',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              Lottie.asset(
                'assets/loader.json',
                controller: _controller,
                onLoaded: (composition) {
                  _controller
                    ..duration = composition.duration
                    ..repeat();
                },
              ),
              const SizedBox(
                  height: 20), // Add spacing between loader and message
              if (_connectionState == ConnectionState.Loading)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              if (_connectionState == ConnectionState.Success ||
                  _connectionState == ConnectionState.Error)
                Text(
                  _detectedText == '0'
                      ? 'Audio is Original'
                      : _detectedText == '1'
                          ? 'Audio is Fake'
                          : _detectedText,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF0E022A),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0E022A),
          ),
          onPressed: _connectionState == ConnectionState.Success ||
                  _connectionState == ConnectionState.Idle
              ? () => _processAudioFile()
              : null,
          child: const Text(
            'Pick an audio file',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
