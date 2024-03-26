from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/api/receive', methods=['POST'])
def receive_data():
    data = request.json
    print("Request Data:", data)
    if data is None:
        return jsonify({'error': 'Invalid request. Data not found.'}), 400
    
    responses = {}  # Create an empty dictionary to store responses
    for question, response in data.items():
        if isinstance(response, str) and response.strip():  # Ensure response is a non-empty string
            responses[question] = response  # Store the response in the dictionary
    
    print("Responses Received:", responses)
    # Process the received responses here (e.g., store them in a database, send them to another service)
    return jsonify({'message': 'Data Received Successfully'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
