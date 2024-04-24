import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class MealIntakeValidation extends StatefulWidget {
  @override
  _MealIntakeValidationState createState() => _MealIntakeValidationState();
}

class _MealIntakeValidationState extends State<MealIntakeValidation> {
  List<dynamic> _receivedQ1 = [];
  String _receivedQ2 = '';
  String _selectedOption = '';
  TextEditingController _otherController = TextEditingController();
  String _selectedDropdownValue = ''; // Initialize with an empty string

  List<String> _mealType = ['Light', 'Moderate', 'Heavy'];

  @override
  void initState() {
    super.initState();
    _fetchDataFromServer();
  }

  Future<void> _fetchDataFromServer() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/get_meal_intake_data'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'example_key': 'example_value'}), // Example data
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final receivedQ1 =
            jsonData['Q1']; // Assuming 'Q1' is the key for received data
        final receivedQ2 =
            jsonData['Q2']; // Assuming 'Q2' is the key for received data

        if (receivedQ1 != null && receivedQ2 != null) {
          setState(() {
            _receivedQ1 = receivedQ1;
            _receivedQ2 = receivedQ2;

            // Update the dropdown options based on the received data
            if (receivedQ2 == 'light') {
              _mealType = ['Light', 'Moderate', 'Heavy'];
            } else if (receivedQ2 == 'moderate') {
              _mealType = ['Moderate', 'Heavy', 'Light'];
            } else if (receivedQ2 == 'heavy') {
              _mealType = ['Heavy', 'Light', 'Moderate'];
            }else{
              _mealType = ['Light', 'Moderate', 'Heavy'];
            }

            // If _receivedQ2 is not present in _mealType, set it to a default value
            if (!_mealType.contains(_receivedQ2)) {
              _receivedQ2 = _mealType.first;
            }
          });
        } else {
          throw Exception('Received data is null');
        }
      } else {
        final errorMessage = json.decode(response.body)['error'];
        throw Exception('Failed to fetch data from server: $errorMessage');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _receivedQ1 = [];
        _receivedQ2 = 'Error: $e';
      });
    }
  }

  Future<void> _submitData() async {
    try {
      String mealTypeOption = _selectedDropdownValue.isNotEmpty
          ? _selectedDropdownValue
          : _mealType.first;

      final data = {
        'selected_option': _selectedOption,
        'mealType': mealTypeOption,
      };

      final response = await http.post(
        Uri.parse('http://localhost:5000/api/submit_meal_data'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // Handle successful submission
        print('Data submitted successfully');
      } else {
        final errorMessage = json.decode(response.body)['error'];
        throw Exception('Failed to submit data: $errorMessage');
      }
    } catch (e) {
      print('Error submitting data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Validate the Data',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white, // Use color code from secondary color
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF1C1C1C), // Use primary color code
      ),
      body: Container(
        color: Color(0xFFF3F3F3), // Use scaffoldBackgroundColor code
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What is the amount of carbohydrate you have taken?',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1C1C), // Use primary color code
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _buildOptions(),
              ),
              SizedBox(height: 25),
              Text(
                'Was it light, medium or heavy meal?',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1C1C), // Use primary color code
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: 10,),
              DropdownButtonFormField<String>(
                value: _mealType.contains(_selectedDropdownValue)
                    ? _selectedDropdownValue
                    : _mealType.first,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDropdownValue = newValue!;
                  });
                },
                items: _mealType.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: Color(0xFF1C1C1C), // Use primary color code
                      ),
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Meal Type',
                  labelStyle: TextStyle(
                    color: Color(0xFF1C1C1C), // Use primary color code
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Color(0xFF0067FF), // Use outline color code
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _submitData,
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color:
                          Colors.white, // Use color code from secondary color
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color(0xFF1C1C1C), // Use primary color code
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOptions() {
    List<Widget> options = [];

    for (var option in _receivedQ1) {
      options.add(
        ListTile(
          title: Text('$option'),
          leading: Radio<String>(
            value: '$option',
            groupValue: _selectedOption,
            onChanged: (value) {
              setState(() {
                _selectedOption = value!;
                _otherController
                    .clear(); // Clear the text field if a new option is selected
              });
            },
          ),
        ),
      );
    }

    // Add the entered value as a new option
    if (_otherController.text.isNotEmpty) {
      options.add(
        ListTile(
          title: Text(_otherController.text),
          leading: Radio<String>(
            value: _otherController.text,
            groupValue: _selectedOption,
            onChanged: (value) {
              setState(() {
                _selectedOption = value!;
              });
            },
          ),
        ),
      );
    }

    options.add(
      ListTile(
        title: _selectedOption == 'Other'
            ? Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _otherController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText:
                            'Enter the carbohydrate amount you have taken.',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // No need to update _selectedOption here
                      });
                    },
                    child: Text('Done'),
                  ),
                ],
              )
            : Text('Other'),
        leading: Radio<String>(
          value: 'Other',
          groupValue: _selectedOption,
          onChanged: (value) {
            setState(() {
              _selectedOption = value!;
              if (_selectedOption == 'Other') {
                // Restore previously entered number if any
                _otherController.text = _selectedOption;
              }
            });
          },
        ),
      ),
    );

    return options;
  }
}
