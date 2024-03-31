from flask import Flask, request, jsonify
from flask_cors import CORS
import spacy
import re

app = Flask(__name__)
CORS(app)

# Load the spaCy English model
nlp = spacy.load("en_core_web_sm")

processed_data = {}  # Dictionary to store processed data

@app.route('/api/receive', methods=['POST'])
def receive_data():
    data = request.json
    print("Request Data:", data)

    if data is None:
        return jsonify({'error': 'Invalid request. Data not found.'}), 400

    responses = {}  # Create an empty dictionary to store responses

    for question, response in data.items():
        if isinstance(response, str) and response.strip():
            responses[question] = response  # Store the response in the dictionary

        # Perform NER tagging and preprocessing based on question
        if "Haemoglobin A1C level" in question:
            process_haemoglobin(response, "Haemoglobin A1C level")
        elif "Cholesterol level" in question:
            process_cholesterol(response, "Cholesterol level")
        elif "LDL" in question:
            process_ldl(response, "LDL")

    print("Responses Received:", responses)

    # Process the received responses here (e.g., store them in a database, send them to another service)
    return jsonify({'message': 'Data Received Successfully'})

def process_haemoglobin(response, question):
    # Extract numerical values and percentages from the response
    numerical_values = []
    percentages = []
    pattern = r'\d+\.?\d*'
    tokens = re.findall(pattern, response)
    for token in tokens:
        if token.endswith('%'):
            percentages.append(float(token[:-1]))
        else:
            numerical_values.append(float(token))

    # Convert percentages to mmol/mol
    mmol_per_mol = []
    for percentage in percentages:
        mmol_per_mol.append((10.93 * percentage) - 23.5)

    # Prepare data to be sent
    processed_values = {
        "Numerical": [str(value) for value in numerical_values],
        "Percentage": percentages,
        "mmol_per_mol": mmol_per_mol
    }

    # Store processed data
    processed_data[question] = processed_values

def process_cholesterol(response, question):
    # Extract numerical values and percentages from the response
    numerical_values = []
    percentages = []
    pattern = r'\d+\.?\d*'
    tokens = re.findall(pattern, response)
    for token in tokens:
        if token.endswith('%'):
            percentages.append(float(token[:-1]))
        else:
            numerical_values.append(float(token))

    # Prepare data to be sent
    processed_values = {
        "Numerical": [str(value) for value in numerical_values],
        "Percentage": percentages
    }

    # Store processed data
    processed_data[question] = processed_values

def process_ldl(response, question):
    # Extract numerical values and percentages from the response
    numerical_values = []
    percentages = []
    pattern = r'\d+\.?\d*'
    tokens = re.findall(pattern, response)
    for token in tokens:
        if token.endswith('%'):
            percentages.append(float(token[:-1]))
        else:
            numerical_values.append(float(token))

    # Prepare data to be sent
    processed_values = {
        "Numerical": [str(value) for value in numerical_values],
        "Percentage": percentages
    }

    # Store processed data
    processed_data[question] = processed_values

@app.route('/api/get_processed_data', methods=['GET'])
def get_processed_data():
    return jsonify(processed_data)

@app.route('/api/send_data', methods=['POST'])
def send_data():
    data = request.json
    print("Received Data:", data)

    # Process the received data or store it in a database

    return jsonify({'message': 'Data Received Successfully'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)