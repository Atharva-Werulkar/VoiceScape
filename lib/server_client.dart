import 'dart:io';
import 'package:http/http.dart' as http;

class ServerClient {
  static Future<String> sendRequest(File data) async {
    print('Sending request to server...');
    print("This is data to send  $data");
    try {
      final bytes = await data.readAsBytes();

      final response = await http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://server-lsv3.onrender.com'), // Replace with your actual server IP and port
      );

      response.files.add(await http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'audio_file.mp3', // Specify filename
        // Specify content type
      ));

      var res = await response.send();

      print('this is Response from the server: ${res.toString()}');
      print('This is the status code: ${res.statusCode}');

      if (res.statusCode == 200) {
        return 'Success';
      } else {
        throw Exception('Failed to send file to server');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  static Future<String> getPrediction(File data) async {
    print("This is Get Prediction Function: $data");

    var response = await http.MultipartRequest(
        'POST', Uri.parse('https://server-lsv3.onrender.com'));

    response.files.add(
      await http.MultipartFile.fromPath('file', data.path),
    );

    var res = await response.send();

    print(
        'this is Response from the server by Get Prediction Function: ${res.toString()}');
    print(
        'This is the status code by Get Prediction Function: ${res.statusCode}');

    if (res.statusCode == 200) {
      // If the server returns a 200 OK response, retrieve the prediction from the server
      var prediction = await res.stream.bytesToString();

      print("This is Response/Output Get Prediction Function: $prediction");

      // Convert the prediction to a string if necessary
      return prediction;
    } else {
      // If the server returns an error response, throw an exception.
      throw Exception('Failed to get prediction from server');
    }
  }

// static Future<String> getPrediction(File data) async {
  //   var response = await http.MultipartRequest(
  //       'POST', Uri.parse('https://server-lsv3.onrender.com'));
  //
  //   response.files.add(
  //     await http.MultipartFile.fromPath('file', data.path),
  //   );
  //
  //   var res = await response.send();
  //
  //   print(res.toString());
  //   print(res.statusCode);
  //
  //   if (res.statusCode == 200) {
  //     // If the server returns a 200 OK response, retrieve the prediction from the server
  //     var prediction = await res.stream.bytesToString();
  //
  //     print("THis is Get Prediction Function:${prediction.toString()}");
  //
  //     // Convert the list to a string if necessary
  //     return prediction.toString();
  //   } else {
  //     // If the server returns an error response, throw an exception.
  //     throw Exception('Failed to get prediction from server');
  //   }
  // }
}
