import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = ''; // Store complete recognized text

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech Input'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isListening
                    ? IconButton(
                        icon: Icon(Icons.stop),
                        iconSize: 48.0,
                        onPressed: _stopListening,
                      )
                    : IconButton(
                        icon: Icon(Icons.mic),
                        iconSize: 48.0,
                        onPressed: _startListening,
                      ),
              ],
            ),
            Text(_recognizedText), // Display the accumulated text
          ],
        ),
      ),
    );
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('status: $status'),
        onError: (error) => print('error: $error'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords
                  .trim(); // Capture full result, trim spaces
            });
          },
        );
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
        _sendDataToServer(_recognizedText); // Send data after complete input
      });
    }
  }

  void _sendDataToServer(String text) async {
    final url =
        'http://localhost:5000/api/receive'; // Replace with your server address
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'text': text});

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        print('Data Sent Successfully');
        _recognizedText = ''; // Clear for next input
      } else {
        print('Failed to send data. Error: ${response.statusCode}');
        // You can add a mechanism to show an error message to the user here.
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
