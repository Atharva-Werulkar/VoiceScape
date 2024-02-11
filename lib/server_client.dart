import 'dart:convert';
import 'package:http/http.dart' as http;

class ServerClient {
  static Future<String> sendRequest(List<List<double>> data) async {
    print('Sending request to server...');
    print(data);
    try {
      final jsonData = {'data': data};

      final response = await http.post(
        Uri.parse(
            'https://server-lsv3.onrender.com'), // Replace with your actual server IP and port
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(jsonData),
      );

      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['prediction'].toString();
      } else {
        throw Exception('Failed to get prediction from server');
      }
      // return jsonDecode(response.body)['prediction'].toString();
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  static Future<String> getPrediction(List<List<double>> data) async {
    var response = await http.post(
      Uri.parse('https://server-lsv3.onrender.com'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'data': data,
      }),
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      List<dynamic> prediction = jsonDecode(response.body)['prediction'];

      print("THis is Get Predition Funtion  ${prediction.toString()}");

      // Convert the list to a string if necessary
      return prediction.toString();
    } else {
      // If the server returns an error response, throw an exception.
      throw Exception('Failed to get prediction from server');
    }
  }
}
