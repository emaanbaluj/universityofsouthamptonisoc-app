from flask import Flask, jsonify
import requests
from bs4 import BeautifulSoup
from apscheduler.schedulers.background import BackgroundScheduler
import datetime

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

    # Skip the first row
    for row in rows[1:]:
        cells = row.find_all(['th', 'td'])
        if len(cells) >= 3:
            prayer_name = cells[0].get_text(strip=True)
            start_time = cells[1].get_text(strip=True)
            jamaat_time = cells[2].get_text(strip=True)
            begin_times.append({'prayer': prayer_name, 'time': start_time})
            jammah_times.append({'prayer': prayer_name, 'time': jamaat_time})

    return {'begin_times': begin_times, 'jammah_times': jammah_times}

def get_islamic_date():
    # URL of the website to scrape
    url = 'https://www.southamptonisoc.org/'

    # Send a GET request to the URL
    response = requests.get(url)

    # Raise an exception if the request was unsuccessful
    response.raise_for_status()

    # Get the content of the webpage
    webpage_content = response.content

    # Parse the HTML content using BeautifulSoup
    soup = BeautifulSoup(webpage_content, 'html.parser')

    # Navigate through the nested span elements to find the date
    date_span = soup.find('h4', class_='font_4 wixui-rich-text__text', style="font-size:18px; text-align:center;")

    # Extract the text from the span element if found
    if date_span:
        islamic_date = date_span.get_text(strip=True)
        print(islamic_date)
        return {'islamic_date': islamic_date}
    else:
        print("Date not found.")
        return {'islamic_date': 'Not found'}

def get_current_date():
    # Function to get the current Gregorian date in the desired format
    today = datetime.date.today()
    formatted_date = today.strftime('%A %d %B, %Y')
    return {'current_date': formatted_date}

# Example usage
current_date_info = get_current_date()
print(current_date_info)  # Output: {'current_date': 'Tuesday 30 July, 2024'}

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

    @app.route('/api/islamic_date', methods=['GET'])
    def islamic_date():
        return jsonify(get_islamic_date())

    @app.route('/api/current_date', methods=['GET'])
    def current_date():
        return jsonify(get_current_date())

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