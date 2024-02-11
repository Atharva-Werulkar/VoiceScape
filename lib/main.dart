import 'dart:io';
import 'package:ai_voice_detector/preprocessing.dart';
import 'package:ai_voice_detector/server_client.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';

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
  // bool _isListening = false;
  String _detectedText = ' Result will be shown here...';
  late AnimationController _controller;
  File? _audioFile;
  bool _loading = false;

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
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _audioFile = File(result.files.single.path!);
        });
        print('Picked audio file: ${_audioFile}');

        //name of audio file
        print(
            'Picked audio file nsme: ${_audioFile!.path.split('/').last.split('.').first.replaceAll('_', ' ')}');

        // store the audio file in the for processing

        List<String> audioFiles = [_audioFile!.path];
        List<List<double>> features = PreProcessing.extractFeatures(audioFiles);

        print(features);

        //final prediction = await ServerClient.sendRequest(features);
        try {
          // Send request to server
          final response = await ServerClient.sendRequest(features);

          if (response.isNotEmpty) {
            //get the prediction from the server
            final prediction = await ServerClient.getPrediction(features);

            // Update UI with prediction
            setState(() {
              //clean the data and display the result
              //IF 0 it is original audio
              //IF 1 it is a fake audio
              _detectedText =
                  prediction.replaceAll('[', '').replaceAll(']', '');
            });
          }
        } catch (e) {
          print('Error getting prediction from server: $e');
        }
      }
    } catch (e) {
      print('Error picking audio file: $e');
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
              Text(
                //if the result is 0 it is original audio
                //if the result is 1 it is a fake audio
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
              const SizedBox(
                height: 20,
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
          onPressed: () => _processAudioFile(),
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
