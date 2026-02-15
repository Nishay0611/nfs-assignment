terraform {
  required_version = ">= 1.3.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# Image build (Dockerfile -> Docker image)
resource "docker_image" "weather_exporter" {
  name = "weather_exporter:local"

  build {
    context    = "${path.module}/.."
    dockerfile = "${path.module}/../Dockerfile"
  }
}

# Container run (Docker image -> running conatiner)
resource "docker_container" "weather_exporter" {
  name  = var.container_name
  image = docker_image.weather_exporter.image_id

# Restart Policy 
  restart = "unless-stopped"

# Port mapping
  ports {
    internal = var.port
    external = var.port
  }

# Environment variables
  env = [
    "PORT=${var.port}",
    "POLL_INTERVAL_SECONDS=${var.poll_interval_seconds}",
    "TARGETS=${jsonencode(var.targets)}",
  ]
}
