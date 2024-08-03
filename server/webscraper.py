import requests
from bs4 import BeautifulSoup

import requests
from bs4 import BeautifulSoup


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
        return islamic_date
    else:
        print("Date not found.")
        return None


# Call the function to get the Islamic date
get_islamic_date()

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
            begin_times.append((prayer_name, start_time))
            jammah_times.append((prayer_name, jamaat_time))

    return {'begin_times': begin_times, 'jammah_times': jammah_times}

# Call the function and get the prayer times
prayer_times = get_prayer_times()

# Print the prayer times

for prayer in prayer_times['begin_times']:
    print(f"{prayer[0]}: {prayer[1]}")
    print("\n")

for prayer in prayer_times['jammah_times']:
    print(f"{prayer[0]}: {prayer[1]}")