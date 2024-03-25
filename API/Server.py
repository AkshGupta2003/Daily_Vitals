from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/api/receive', methods=['POST'])
def receive_data():
  data = request.json
  text_received = data.get('text')
  print("Data Received:", text_received)
  # Process the received text here (e.g., store it in a database, send it to another service)
  return jsonify({'message': 'Data Received Successfully'})

if __name__ == '__main__':
  app.run(host='0.0.0.0', port=5000)