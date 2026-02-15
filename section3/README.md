# Weather Prometheus Exporter

A service that polls the Open-Meteo API and exposes weather metrics for Prometheus at /metrics.

# Build

```bash
docker build -t weather_exporter .
```
‪#‬ Run
```bash
docker run -d --name weather-test \
  -p 8080:8080 \
  -e PORT=8080 \
  -e POLL_INTERVAL_SECONDS=10 \
  -e TARGETS='[{"name":"Paris","lat":48.85,"lon":2.35},{"name":"Berlin","lat":52.52,"lon":13.40}]' \
  weather_exporter
```
# Access Metrics 
http://localhost:8080/metrics

# Environment Variables
PORT - metrics server port (default: 8000)
POLL_INTERVAL_SECONDS - polling interval (default: 30)
TARGETS - JSON array of locations (default: Tel Aviv, London, New York, Bangkok)

‪#‬ Example TARGETS format:
```json
[
  {"name":"City","lat":0.0,"lon":0.0}
]
```
```
