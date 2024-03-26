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
      title: 'Blood Test Results',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
  String _recognizedText = '';
  List<String> _questions = [
    "What is the Haemoglobin A1C level shown in your report?",
    "What is the Cholesterol level shown in your report?",
    "What is the LDL shown in your report?"
  ];
  Map<String, String> _formData = {};

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Test Results'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      title: Text(_questions[index]),
                      trailing: IconButton(
                        icon: _isListening
                            ? Icon(Icons.mic_off)
                            : Icon(Icons.mic),
                        onPressed: () {
                          _isListening
                              ? _stopListening()
                              : _startListening(index);
                        },
                      ),
                    ),
                    if (_formData.containsKey(_questions[index]))
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                            "Your response: ${_formData[_questions[index]]}"),
                      ),
                    SizedBox(height: 10),
                  ],
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _submitData,
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _startListening(int index) async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == stt.SpeechToText.listeningStatus) {
            setState(() {
              _isListening = true;
            });
          }
        },
        onError: (error) => print('error: $error'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords.trim();
              _formData[_questions[index]] = _recognizedText;
            });
          },
        );
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  void _submitData() async {
    final url = 'http://localhost:5000/api/receive';
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(_formData);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        print('Data Sent Successfully');
        _formData.clear();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Data sent successfully'),
          backgroundColor: Colors.green,
        ));
      } else {
        print('Failed to send data. Error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to send data. Error: ${response.statusCode}'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }
}
