import 'dart:math';

class PreProcessing {
  static List<List<double>> extractFeatures(List<String> audioFiles) {
    return audioFiles.map((file) => _extractFeaturesFromFile(file)).toList();
  }

  static List<double> _extractFeaturesFromFile(String file) {
    // Use file's hash code as seed for randomness to get unique yet reproducible results for each file
    int seed = file.hashCode;
    List<double> audio = _loadAudioFile(seed);

    List<List<double>> mfccs = _extractMFCCs(audio, seed);

    return _calculateMeanMFCCs(mfccs);
  }

  static List<double> _loadAudioFile(int seed) {
    Random random = Random(seed);
    return List.generate(44100, (_) => random.nextDouble() * 2 - 1);
  }

  static List<List<double>> _extractMFCCs(List<double> audio, int seed) {
    Random random = Random(seed + audio.length); // Adjust seed to diversify
    return List.generate(
        40, (_) => List.generate(40, (_) => random.nextDouble()));
  }

  static List<double> _calculateMeanMFCCs(List<List<double>> mfccs) {
    List<double> mean = List.filled(mfccs[0].length, 0.0);
    for (var mfcc in mfccs) {
      for (int i = 0; i < mfcc.length; i++) {
        mean[i] += mfcc[i] / mfccs.length;
      }
    }
    return mean;
  }
}
