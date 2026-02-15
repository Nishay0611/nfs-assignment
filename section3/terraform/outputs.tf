output "metrics_url" {
  description = "Prometheus metrics endpoint"
  value       = "http://localhost:${var.port}/metrics"
}

output "container_name" {
  description = "Container name"
  value       = docker_container.weather_exporter.name
}
