import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  Map<String, dynamic> processedData = {};
  String haemoglobinUnit = 'mmol/mol';
  String cholesterolUnit = 'mg/dL';
  String ldlUnit = 'mg/dL';

  // Store selected options
  Map<String, dynamic> selectedOptions = {};

  Future<void> _getData() async {
    final url = 'http://localhost:5000/api/get_processed_data';
    try {
      final response = await http.get(Uri.parse(url));
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);
          setState(() {
            processedData = data ?? {};
          });
        } else {
          print('Empty response body');
        }
      } else {
        print('Failed to get processed data. Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // New method to handle option selection
  void _handleOptionSelection(String label, dynamic value) {
    setState(() {
      selectedOptions[label] = value;
    });
  }

  // New method to send data to the server
  Future<void> _sendDataToServer() async {
    final url = 'http://localhost:5000/api/send_data';
    try {
      // Create a copy of selectedOptions to include the units
      Map<String, dynamic> dataToSend = Map.from(selectedOptions);

      // Add the selected units to the data
      dataToSend['haemoglobinUnit'] = haemoglobinUnit;
      dataToSend['cholesterolUnit'] = cholesterolUnit;
      dataToSend['ldlUnit'] = ldlUnit;

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dataToSend),
      );
      print('Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Data sent successfully');
        // Show a success message or perform any other actions
      } else {
        print('Failed to send data. Error: ${response.statusCode}');
        // Show an error message or perform error handling
      }
    } catch (e) {
      print('Error: $e');
      // Show an error message or perform error handling
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Data'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Haemoglobin A1C Level:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              _buildHaemoglobinOptions(),
              SizedBox(height: 16.0),
              Text(
                'Cholesterol:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              _buildCholesterolOptions(),
              SizedBox(height: 16.0),
              Text(
                'LDL:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              _buildLDLOptions(),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _sendDataToServer,
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getData,
        child: Icon(Icons.get_app),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Widget _buildHaemoglobinOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (processedData.containsKey('Haemoglobin A1C level') &&
            processedData['Haemoglobin A1C level'].containsKey('Percentage'))
          ...processedData['Haemoglobin A1C level']['Percentage']!
              .map((value) => _buildOptionWithRadioAndDropdown(
                  value, 'Haemoglobin A1C Percentage', ['mmol/mol', '%']))
              .toList(),
        if (processedData.containsKey('Haemoglobin A1C level') &&
            processedData['Haemoglobin A1C level'].containsKey('Numerical'))
          ...processedData['Haemoglobin A1C level']['Numerical']!
              .map((value) => _buildOptionWithRadioAndDropdown(
                  value, 'Haemoglobin A1C Numerical', ['mmol/mol', '%']))
              .toList(),
        SizedBox(height: 8.0),
        _buildOptionWithRadioAndInput(
            'Other', 'Haemoglobin A1C', ['mmol/mol', '%']),
      ],
    );
  }

  Widget _buildCholesterolOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (processedData.containsKey('Cholesterol level') &&
            processedData['Cholesterol level'].containsKey('Numerical'))
          ...processedData['Cholesterol level']['Numerical']!
              .map((value) => _buildOptionWithRadioAndDropdown(
                  value, 'Cholesterol', ['mg/dL', 'mmol/L']))
              .toList(),
        SizedBox(height: 8.0),
        _buildOptionWithRadioAndInput(
            'Other', 'Cholesterol', ['mg/dL', 'mmol/L']),
      ],
    );
  }

  Widget _buildLDLOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (processedData.containsKey('LDL') &&
            processedData['LDL'].containsKey('Numerical'))
          ...processedData['LDL']['Numerical']!
              .map((value) => _buildOptionWithRadioAndDropdown(
                  value, 'LDL', ['mg/dL', 'mmol/L']))
              .toList(),
        SizedBox(height: 8.0),
        _buildOptionWithRadioAndInput('Other', 'LDL', ['mg/dL', 'mmol/L']),
      ],
    );
  }

  Widget _buildOptionWithRadioAndDropdown(
      String option, String label, List<String> units) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(option),
        DropdownButton<String>(
          value: (label == 'Haemoglobin A1C Percentage' ||
                  label == 'Haemoglobin A1C Numerical')
              ? haemoglobinUnit
              : label == 'Cholesterol'
                  ? cholesterolUnit
                  : ldlUnit,
          onChanged: (String? newValue) {
            setState(() {
              if (label == 'Haemoglobin A1C Percentage' ||
                  label == 'Haemoglobin A1C Numerical') {
                haemoglobinUnit = newValue!;
              } else if (label == 'Cholesterol') {
                cholesterolUnit = newValue!;
              } else if (label == 'LDL') {
                ldlUnit = newValue!;
              }
            });
          },
          items: units.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        SizedBox(width: 16.0),
        Radio(
          value: option,
          groupValue: selectedOptions[label],
          onChanged: (value) {
            _handleOptionSelection(label, value);
          },
        ),
      ],
    );
  }

  Widget _buildOptionWithRadioAndInput(
      String optionText, String label, List<String> units) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Enter $label value',
            ),
            onChanged: (value) {
              _handleOptionSelection(label, value);
            },
          ),
        ),
        SizedBox(width: 16.0),
        DropdownButton<String>(
          value: (label == 'Haemoglobin A1C')
              ? haemoglobinUnit
              : label == 'Cholesterol'
                  ? cholesterolUnit
                  : ldlUnit,
          onChanged: (String? newValue) {
            setState(() {
              if (label == 'Haemoglobin A1C') {
                haemoglobinUnit = newValue!;
              } else if (label == 'Cholesterol') {
                cholesterolUnit = newValue!;
              } else if (label == 'LDL') {
                ldlUnit = newValue!;
              }
            });
          },
          items: units.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        SizedBox(width: 16.0),
        Radio(
          value: optionText,
          groupValue: selectedOptions[label],
          onChanged: (value) {
            _handleOptionSelection(label, value);
          },
        ),
      ],
    );
  }
}
