variable "container_name" {
  type        = string
  description = "Docker container name"
  default     = "weather-exporter"
}

variable "port" {
  type        = number
  description = "Port to expose metrics on (host and container)"
  default     = 8080
}

variable "poll_interval_seconds" {
  type        = number
  description = "How often to poll the Open-Meteo API"
  default     = 10
}

variable "targets" {
  type = list(object({
    name = string
    lat  = number
    lon  = number
  }))

  description = "List of weather targets"

  default = [
    { name = "Tel Aviv", lat = 32.109333, lon = 34.855499 },
    { name = "London",   lat = 51.509865, lon = -0.118092 },
    { name = "New York", lat = 40.7128,   lon = -74.0060 },
    { name = "Bangkok",  lat = 13.736717, lon = 100.523186 },
  ]
}
