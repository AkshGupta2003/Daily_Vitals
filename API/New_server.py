from flask import Flask, request, jsonify
from flask_cors import CORS
import re
from datetime import datetime
import psycopg2

app = Flask(__name__)
CORS(app)

# Store the extracted numbers globally
extracted_numbers = []

# PostgreSQL database connection parameters
DB_HOST = 'dpg-co4g76n79t8c73925an0-a.singapore-postgres.render.com'
DB_PORT = '5432'
DB_NAME = 'nlp_app'
DB_USER = 'nlp_app_user'
DB_PASSWORD = 'mjWEaZb6pJ6HTnBuf7UAJhsrDQWo6jhu'

def connect_to_database():
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD
        )
        return conn
    except psycopg2.Error as e:
        print("Error connecting to the database:", e)

def execute_query(query, params=None):
    conn = connect_to_database()
    cursor = conn.cursor()
    try:
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        conn.commit()
        cursor.close()
        conn.close()
    except psycopg2.Error as e:
        print("Error executing query:", e)
        conn.rollback()
        cursor.close()
        conn.close()

@app.route('/api/blood_sugar', methods=['POST'])
def receive_blood_sugar_data():
    """Endpoint to receive blood sugar data."""
    global extracted_numbers
    try:
        data = request.get_json()
        print("Received blood sugar data:", data)  # Print the received data
        
        # Extract all numbers from the received data
        numbers = re.findall(r'\d+(?:\.\d+)?', str(data))
        print("Extracted numbers:", numbers)
        
        # Store the extracted numbers globally
        extracted_numbers = numbers

        return jsonify({"message": "Data received successfully"}), 200
    except Exception as e:
        print("Error receiving blood sugar data:", e)
        return jsonify({"error": "Failed to process request"}), 500

@app.route('/api/get_data_sugar', methods=['POST'])
def get_data_sugar():
    """Endpoint to handle the request for sending data."""
    global extracted_numbers
    try:
        # Create the response JSON with Q1 as extracted numbers and Q2 as "always"
        response_data = {
            'Q1': extracted_numbers,
            'Q2': 'before'
        }
        print("Data being sent:", response_data)  # Print the data being sent

        # Send the response JSON
        return jsonify(response_data), 200
    except Exception as e:
        print("Error processing request:", e)
        return jsonify({"error": "Failed to process request"}), 500

@app.route('/api/insulin_taken', methods=['POST'])
def receive_insulin_data():
    """Endpoint to receive insulin data."""
    try:
        data = request.get_json()
        print("Received insulin data:", data)  # Print the received data
        
        # Process the received data as needed

        return jsonify({"message": "Data received successfully"}), 200
    except Exception as e:
        print("Error receiving insulin data:", e)
        return jsonify({"error": "Failed to process request"}), 500

@app.route('/api/submit_data_sugar', methods=['POST'])
def submit_data_sugar():
    """Endpoint to receive submitted sugar data."""
    try:
        data = request.get_json()
        print("Received submitted sugar data:", data)  # Print the received data
        
        # Extract data from the request
        blood_sugar = data.get('selected_option')
        meal_type = data.get('meal_timing')

        # Generate current date and time
        current_date = datetime.now().date()
        current_time = datetime.now().time()

        # Fixed phone number
        phone_number = '1234567890'

        # Insert data into the blood_sugar_records table
        query = "INSERT INTO blood_sugar_records (phonenumber, date, time, blood_sugar, meal_type) VALUES (%s, %s, %s, %s, %s)"
        params = (phone_number, current_date, current_time, blood_sugar, meal_type)
        execute_query(query, params)

        return jsonify({"message": "Data received and inserted successfully"}), 200
    except Exception as e:
        print("Error receiving and inserting submitted sugar data:", e)
        return jsonify({"error": "Failed to process request"}), 500


if __name__ == '__main__':
    app.run(debug=True)
