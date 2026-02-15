from prometheus_client import Counter, Gauge, Histogram

# Counter = success / failure
api_polls_total = Counter(
    "weather_api_polls_total",
    "Total API polls",
    ["target", "status"]
)

# Histogram – duration per poll
poll_duration = Histogram(
    "poll_duration_seconds",
    "Weather API poll duration in seconds",
    ["target"]
)

# Counter = api arrors by reasons
errors_total = Counter(
    "weather_api_errors_total",
    "Total API errors by reason",
    ["target", "reason"]
)

temperature_c = Gauge(
    "weather_temperature_c",
    "Current temperature (C)",
    ["target"]
)

wind_speed_ms = Gauge(
    "weather_wind_speed_ms",
    "Current wind speed (m/s)",
    ["target"]
)

humidity_percent = Gauge(
    "weather_relative_humidity_percent",
    "Current relative humidity (%)",
    ["target"]
)
