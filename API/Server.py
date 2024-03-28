from flask import Flask, request, jsonify
from flask_cors import CORS
import spacy

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
    # Preprocess the response to extract the numerical value and percentage
    numerical_value = None
    percentage = None
    for token in response.split():
        if token.isdigit():
            numerical_value = float(token)
        elif token.endswith('%'):
            percentage = float(token[:-1])
    if numerical_value is None and percentage is None:
        print(f"Error: No numerical value found in response for {question}")
        return
    # Convert percentage to mmol/mol using the given formula
    mmol_per_mol = (10.93 * percentage) - 23.5 if percentage is not None else None
    # Prepare data to be sent
    processed_values = {}
    if numerical_value is not None:
        processed_values["Numerical"] = str(numerical_value)  # Convert numerical_value to string
    if percentage is not None:
        processed_values["Percentage"] = percentage
    if mmol_per_mol is not None:
        processed_values["mmol_per_mol"] = mmol_per_mol
    # Perform NER tagging on the response
    doc = nlp(response)
    tagged_entities = []
    for ent in doc.ents:
        if ent.label_ in ["PERCENT", "CARDINAL", "QUANTITY"]:
            if ent.label_ != "PERCENT":
                tagged_entities.append((ent.text, ent.label_))
    print(f"Tagged Entities for {question}:", tagged_entities)
    # Store processed data
    processed_data[question] = {"Values": processed_values, "Entities": tagged_entities}

def process_cholesterol(response, question):
    # Perform NER tagging on the response
    doc = nlp(response)
    tagged_entities = []
    for ent in doc.ents:
        if ent.label_ in ["PERCENT", "CARDINAL", "QUANTITY"]:
            tagged_entities.append((ent.text, ent.label_))
    print(f"Tagged Entities for {question}:", tagged_entities)
    processed_data[question] = tagged_entities  # Store processed data

def process_ldl(response, question):
    # Perform NER tagging on the response
    doc = nlp(response)
    tagged_entities = []
    for ent in doc.ents:
        if ent.label_ in ["PERCENT", "CARDINAL", "QUANTITY"]:
            tagged_entities.append((ent.text, ent.label_))
    print(f"Tagged Entities for {question}:", tagged_entities)
    processed_data[question] = tagged_entities  # Store processed data

@app.route('/api/get_processed_data', methods=['GET'])
def get_processed_data():
    return jsonify(processed_data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)