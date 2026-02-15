import time
import requests
import os
from prometheus_client import start_http_server
from metrics import (api_polls_total, poll_duration, errors_total, emperature_c, wind_speed_ms)

TARGETS = [
    {"name": "TelAviv", "lat": 32.109333, "lon": 34.855499},
    {"name": "London", "lat": 51.509865, "lon": -0.118092},
    {"name": "NewYork", "lat": 43.000000, "lon": 75.000000},
    {"name": "Bangkok", "lat": 13.736717, "lon": 100.523186}
]

POLL_INTERVAL_SECONDS = int(os.getenv("POLL_INTERVAL_SECONDS", "30"))
PORT = int(os.getenv("PORT", "8000"))

def build_url(lat, lon):
    return (
        "https://api.open-meteo.com/v1/forecast"
        f"?latitude={lat}&longitude={lon}"
        "&current=temperature_2m,wind_speed_10m"
    )

def poll_target(target):
    url = build_url(target["lat"], target["lon"])
    response = requests.get(url, timeout=5)

    if response.status_code != 200:
        print(f"Failed to fetch data for {target['name']}")
        return

    data = response.json()
    current_weather = data.get("current", {})

    temperature = current_weather.get("temperature_2m")
    wind_speed = current_weather.get("wind_speed_10m")

    print(f"{target['name']} | Temp: {temperature}°C | Wind: {wind_speed} m/s")

def main():
    start_http_server(PORT)
    while True:
        for target in TARGETS:
            poll_target(target)

        print("Sleeping...\n")
        time.sleep(POLL_INTERVAL_SECONDS)

if __name__ == "__main__":
    main()