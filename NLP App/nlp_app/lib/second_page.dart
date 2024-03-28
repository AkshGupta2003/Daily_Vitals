import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  Map<String, dynamic> processedData = {};
  Map<String, String> unitSelections = {};

  Future<void> _getData() async {
    final url = 'http://localhost:5000/api/get_processed_data';
    try {
      final response = await http.get(Uri.parse(url));
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          processedData = data;
          unitSelections = {
            for (var entry in data.entries)
              if (entry.value is Map && entry.value.containsKey('Values'))
                entry.key: (double.tryParse(
                                entry.value['Values']['Numerical'] ?? '0') ??
                            0) >
                        50
                    ? 'mg/dL'
                    : 'mmol/L'
          };
        });
      } else {
        print('Failed to get processed data. Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Form'),
          backgroundColor: Colors.deepPurple,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Processed Data:',
                style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _getData,
                child: Text('Get Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 20.0),
              if (processedData.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (processedData.containsKey('Haemoglobin A1C level'))
                      Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Haemoglobin A1C:',
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Numerical: ${processedData['Haemoglobin A1C level']['Values']['Numerical']} (mmol/mol: ${processedData['Haemoglobin A1C level']['Values']['mmol_per_mol']})',
                                style: TextStyle(fontSize: 16.0),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                'Percentage: ${processedData['Haemoglobin A1C level']['Values']['Percentage']}%',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 16.0),
                    if (processedData.containsKey('Cholesterol level'))
                      Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cholesterol:',
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8.0),
                              ...processedData['Cholesterol level']
                                  .map((value) => Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${value[0]}',
                                            style: TextStyle(fontSize: 16.0),
                                          ),
                                          DropdownButton<String>(
                                            value: unitSelections[
                                                    'Cholesterol level'] ??
                                                'mmol/L',
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                unitSelections[
                                                        'Cholesterol level'] =
                                                    newValue!;
                                              });
                                            },
                                            items: <String>['mg/dL', 'mmol/L']
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ))
                                  .toList(),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 16.0),
                    if (processedData.containsKey('LDL'))
                      Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LDL:',
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8.0),
                              ...processedData['LDL']
                                  .map((value) => Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${value[0]}',
                                            style: TextStyle(fontSize: 16.0),
                                          ),
                                          DropdownButton<String>(
                                            value: unitSelections['LDL'] ??
                                                'mmol/L',
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                unitSelections['LDL'] =
                                                    newValue!;
                                              });
                                            },
                                            items: <String>['mg/dL', 'mmol/L']
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ))
                                  .toList(),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
