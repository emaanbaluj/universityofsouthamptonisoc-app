from flask import Flask, jsonify
import requests
from bs4 import BeautifulSoup

def get_prayer_times():
    # URL of the iframe content (based on the src attribute in the provided HTML)
    iframe_url = 'https://www.swindonmasjid.com/wp-content/uploads/st.php?source=homepage'

    # Fetch the iframe content
    try:
        response = requests.get(iframe_url)
        response.raise_for_status()  # Check if the request was successful
    except requests.RequestException as e:
        print(f"Error fetching the iframe content: {e}")
        return {'begin_times': [], 'jammah_times': []}

    webpage_content = response.content

    # Parse the HTML content
    soup = BeautifulSoup(webpage_content, 'html.parser')

    # Find the table with the prayer times
    table = soup.find('table', id='mytable')

    # Check if the table was found
    if table is None:
        print("Table with id 'mytable' not found.")
        return {'begin_times': [], 'jammah_times': []}

    # Extract prayer times
    begin_times = []
    jammah_times = []

    # Find the table body (if present)
    tbody = table.find('tbody')

    # If tbody is not present, use the table directly
    rows = tbody.find_all('tr') if tbody else table.find_all('tr')

    # Iterate over each row in the table
    for row in rows:
        # Get all cells in the row
        cells = row.find_all(['th', 'td'])

        # If the row has prayer time information, extract it
        if len(cells) >= 3:
            prayer_name = cells[0].get_text(strip=True)
            start_time = cells[1].get_text(strip=True)
            jamaat_time = cells[2].get_text(strip=True)
            begin_times.append({'prayer': prayer_name, 'time': start_time})
            jammah_times.append({'prayer': prayer_name, 'time': jamaat_time})

    return {'begin_times': begin_times, 'jammah_times': jammah_times}

def create_app():
    app = Flask(__name__)

    @app.route('/api/begin_times', methods=['GET'])
    def begin_times():
        times = get_prayer_times()
        return jsonify(times['begin_times'])

    @app.route('/api/jammah_times', methods=['GET'])
    def jammah_times():
        times = get_prayer_times()
        return jsonify(times['jammah_times'])

    return app

if __name__ == '__main__':
    app = create_app()
    app.run(debug=True)