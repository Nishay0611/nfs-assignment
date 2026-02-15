import time, requests, os, json
from prometheus_client import start_http_server
from metrics import (api_polls_total, poll_duration, errors_total, temperature_c, wind_speed_ms, humidity_percent)

default_targets = [
    {"name": "Tel Aviv", "lat": 32.109333, "lon": 34.855499},
    {"name": "London", "lat": 51.509865, "lon": -0.118092},
    {"name": "New York", "lat": 43.000000, "lon": -75.000000},
    {"name": "Bangkok", "lat": 13.736717, "lon": 100.523186}
]
targets_environment = os.getenv("TARGETS")

POLL_INTERVAL_SECONDS = int(os.getenv("POLL_INTERVAL_SECONDS", "30"))
PORT = int(os.getenv("PORT", "8000"))
TARGETS = json.loads(targets_environment) if targets_environment else default_targets

def build_url(lat, lon):
    return (
        "https://api.open-meteo.com/v1/forecast"
        f"?latitude={lat}&longitude={lon}"
        "&current=temperature_2m,wind_speed_10m,relative_humidity_2m"
    )

def poll_target(target):
    name = target["name"]
    start= time.perf_counter()

    try:
        response = requests.get(build_url(target["lat"], target["lon"]), timeout=5)
        poll_duration.labels(target=name).observe(time.perf_counter()- start)

        if response.status_code != 200:
            api_polls_total.labels(target=name, status= "failure").inc()
            errors_total.labels(target=name, reason="http_error").inc()
            return

        data = response.json()
        current_weather = data.get("current", {})
        if not isinstance(current_weather,dict):
            api_polls_total.labels(target=name, status="failure").inc()
            errors_total.labels(target=name, reason="missing_current").inc()
            return

        temperature = current_weather.get("temperature_2m")
        wind_speed = current_weather.get("wind_speed_10m")
        humidity = current_weather.get("relative_humidity_2m")

        if temperature is not None:
            temperature_c.labels(target=name).set(float(temperature))
        if wind_speed is not None:
            wind_speed_ms.labels(target=name).set(float(wind_speed))
        if humidity is not None:
            humidity_percent.labels(target=name).set(float(humidity))
        api_polls_total.labels(target=name, status="success").inc()

    except requests.exceptions.Timeout:
        poll_duration.labels(target=name).observe(time.perf_counter() - start)
        api_polls_total.labels(target=name, status="failure").inc()
        errors_total.labels(target=name, reason="timeout").inc()

    except ValueError:
        poll_duration.labels(target=name).observe(time.perf_counter() - start)
        api_polls_total.labels(target=name, status="failure").inc()
        errors_total.labels(target=name, reason="bad_json").inc()

    except Exception:
        poll_duration.labels(target=name).observe(time.perf_counter() - start)
        api_polls_total.labels(target=name, status="failure").inc()
        errors_total.labels(target=name, reason="exception").inc()

# Metrics exposed on http://localhost:{PORT}/metrics
def main():
    start_http_server(PORT)
    while True:
        for target in TARGETS:
            poll_target(target)
        time.sleep(POLL_INTERVAL_SECONDS)

if __name__ == "__main__":
    main()