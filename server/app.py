from flask import Flask, jsonify
import requests
from bs4 import BeautifulSoup
from apscheduler.schedulers.background import BackgroundScheduler


# Function to get prayer times
def get_prayer_times():
    iframe_url = 'https://www.swindonmasjid.com/wp-content/uploads/st.php?source=homepage'

    try:
        response = requests.get(iframe_url)
        response.raise_for_status()
    except requests.RequestException as e:
        print(f"Error fetching the iframe content: {e}")
        return {'begin_times': [], 'jammah_times': []}

    webpage_content = response.content
    soup = BeautifulSoup(webpage_content, 'html.parser')
    table = soup.find('table', id='mytable')

    if table is None:
        print("Table with id 'mytable' not found.")
        return {'begin_times': [], 'jammah_times': []}

    begin_times = []
    jammah_times = []
    tbody = table.find('tbody')
    rows = tbody.find_all('tr') if tbody else table.find_all('tr')

    for row in rows:
        cells = row.find_all(['th', 'td'])
        if len(cells) >= 3:
            prayer_name = cells[0].get_text(strip=True)
            start_time = cells[1].get_text(strip=True)
            jamaat_time = cells[2].get_text(strip=True)
            begin_times.append({'prayer': prayer_name, 'time': start_time})
            jammah_times.append({'prayer': prayer_name, 'time': jamaat_time})

    return {'begin_times': begin_times, 'jammah_times': jammah_times}


# Function to update prayer times periodically
def update_prayer_times():
    global prayer_times
    prayer_times = get_prayer_times()


# Flask application setup
def create_app():
    app = Flask(__name__)

    @app.route('/api/begin_times', methods=['GET'])
    def begin_times():
        return jsonify(prayer_times['begin_times'])

    @app.route('/api/jammah_times', methods=['GET'])
    def jammah_times():
        return jsonify(prayer_times['jammah_times'])

    return app


if __name__ == '__main__':
    prayer_times = get_prayer_times()
    app = create_app()
    scheduler = BackgroundScheduler()
    scheduler.add_job(func=update_prayer_times, trigger="interval", minutes=60)
    scheduler.start()

    try:
        app.run(debug=True)
    except (KeyboardInterrupt, SystemExit):
        scheduler.shutdown()