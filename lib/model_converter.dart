import 'dart:math';

class ModelConverter {
  static List<List<double>> extractFeatures(List<String> audioFiles) {
    List<List<double>> features = [];
    print('Audio Files: $audioFiles');

    for (String file in audioFiles) {
      features.clear();
      // Load audio file
      List<double> audio = loadAudioFile(file);
      print('Audio: $audio');

      // Extract audio features (example: MFCCs)
      List<List<double>> mfccs = extractMFCCs(audio);
      print('MFCCs: $mfccs');

      // Calculate mean of MFCCs across time
      List<double> mfccsMean = calculateMeanMFCCs(mfccs);
      print('MFCCs mean: $mfccsMean');

      features.add(mfccsMean);
    }

    return features;
  }

  static List<double> loadAudioFile(String file) {
    // Simulate loading audio file (replace with actual code)
    // This function should load the audio file and return a list of audio data
    // For simplicity, we'll generate random audio data here
    Random random = Random();
    List<double> audio =
        List.generate(44100, (index) => random.nextDouble() * 2 - 1);
    return audio;
  }

  static List<List<double>> extractMFCCs(List<double> audio) {
    // Simulate extracting MFCCs (replace with actual code)
    // This function should extract MFCCs from the audio data and return them as a 2D list
    // For simplicity, we'll return a 2D list of random numbers here
    Random random = Random();
    List<List<double>> mfccs =
        List.generate(40, (i) => List.generate(40, (j) => random.nextDouble()));
    return mfccs;
  }

  static List<double> calculateMeanMFCCs(List<List<double>> mfccs) {
    List<double> mean = List.filled(mfccs[0].length, 0.0);
    for (List<double> mfcc in mfccs) {
      for (int i = 0; i < mfcc.length; i++) {
        mean[i] += mfcc[i] / mfccs.length;
      }
    }
    return mean;
  }
}

// void main() {
//   List<String> audioFiles = ["audio1.mp3", "audio2.mp3"];
//   List<List<double>> features = extractFeatures(audioFiles);
//   print(features);
// }
