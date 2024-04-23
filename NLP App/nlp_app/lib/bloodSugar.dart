import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nlp_app/sugarValidation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class BloodSugarEntryBottomSheet extends StatefulWidget {
  const BloodSugarEntryBottomSheet({super.key});

  @override
  State<BloodSugarEntryBottomSheet> createState() =>
      _BloodSugarEntryBottomSheetState();
}

class _BloodSugarEntryBottomSheetState
    extends State<BloodSugarEntryBottomSheet> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String mealType = 'Before Meal'; // Assuming 'Before' is the default value
  TextEditingController bloodSugarController = TextEditingController();

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  List<String> _bloodSugarQuestions = [
    "What is your current blood sugar level?",
    "Was the reading taken before the meal or after the meal?"
  ];

  Map<String, String> _bloodSugarFormData = {};

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _onMealSelected(String type) {
    setState(() {
      mealType = type;
    });
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final format =
        DateFormat.jm(); // You can customize the time format here if needed.
    return format.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Center(
                  child: Text(
                    'Blood Sugar Entry',
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 16),
              ..._buildQuestions(_bloodSugarQuestions, _bloodSugarFormData),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      // onPressed: () async {},
                      onPressed: () {
                        _submitBloodSugarData();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SugarValidation()));
                      },

                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(100, 40)),
                      child: Text('Submit'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(100, 40)),
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildQuestions(
      List<String> questions, Map<String, String> formData) {
    return questions.map((question) {
      return Column(
        children: [
          ListTile(
            title: Text(question),
            trailing: IconButton(
              icon: _isListening ? Icon(Icons.mic_off) : Icon(Icons.mic),
              // icon: Icon(Icons.mic_off),
              onPressed: () {
                _isListening
                    ? _stopListening()
                    : _startListening(formData, question);
              },
            ),
          ),
          if (formData.containsKey(question))
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("Your response: ${formData[question]}"),
            ),
          SizedBox(height: 10),
        ],
      );
    }).toList();
  }

  void _startListening(Map<String, String> formData, String question) async {
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
              formData[question] = _recognizedText;
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

  void _submitBloodSugarData() async {
    await _submitData(
        _bloodSugarFormData, 'http://localhost:5000/api/blood_sugar');
  }

  Future<void> _submitData(Map<String, String> formData, String apiUrl) async {
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(formData);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        print('Data Sent Successfully');
        formData.clear();
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
