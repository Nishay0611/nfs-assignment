# Weather Prometheus Exporter

A service that polls the Open-Meteo API and exposes weather metrics for Prometheus at /metrics.

# Run With Docker
### Build
```bash
docker build -t weather_exporter .
```
### Run
```bash
docker run -d --name weather-test \
  -p 8080:8080 \
  -e PORT=8080 \
  -e POLL_INTERVAL_SECONDS=10 \
  -e TARGETS='[{"name":"Paris","lat":48.85,"lon":2.35},{"name":"Berlin","lat":52.52,"lon":13.40}]' \
  weather_exporter
```
### Access Metrics
http://localhost:8080/metrics

# Run With Terraform
### Terraform directory
```bash
cd section3/terraform
```
### Initialize Terraform:
```bash
terraform init
```
### Apply configuration (using defaults):
```bash
terraform apply
```
### Override Defaults:
```bash
# Override targets
terraform apply \
  -var='targets=[
    {name="Paris", lat=48.85, lon=2.35},
    {name="Amsterdam", lat=52.37, lon=4.90}
  ]'

# Override polling interval
terraform apply -var="poll_interval_seconds=5"

# Override port
terraform apply -var="port=9090"
```
### Access metrics
http://localhost:8080/metrics (this is default- change to PORT)

# Environment Variables
PORT - metrics server port (default: 8000)
POLL_INTERVAL_SECONDS - polling interval (default: 30)
TARGETS - JSON array of locations (default: Tel Aviv, London, New York, Bangkok)

# Example TARGETS format:
```json
[
  {"name":"City","lat":0.0,"lon":0.0}
]
```
# Metrics and Labels
### weather_api_polls_total (counter)
Labels:
- target
- status (success | failure)

### weather_api_errors_total (counter)
Labels:
- target
- reason

### poll_duration_seconds (histogram) 
Labels: 
- target

### weather_temperature_c (gauge)
Labels: 
- target

### weather_wind_speed_ms (gauge)
Labels: 
- target

### weather_relative_humidity_percent (gauge)
Labels: 
- target

# PromQL queries
```promql
# Total successful polls
weather_api_polls_total{status="success"}

# Poll success rate in last 5 minutes
rate(weather_api_polls_total[5m])

# Errors by reason in last 5 minutes
rate(weather_api_errors_total{reason="timeout"}[5m])
```