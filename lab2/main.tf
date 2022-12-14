terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.13.0"
    }
  }
}

variable "conf_path" {
  type = string
  default = "C:\\Users\\ledia\\Desktop\\uni\\cours\\devops\\lab2\\conf"
}

provider "docker" {
  host    = "npipe:////.//pipe//docker_engine"
}

# resource "docker_image" "nginx" {
#   name         = "nginx:latest"
#   keep_locally = false
# }

# resource "docker_container" "nginx" {
#   image = docker_image.nginx.name
#   name  = "tutorial"
#   ports {
#     internal = 80
#     external = 8000
#   }
# }

resource "docker_network" "private_network" {
  name = "my_network"
}
resource "docker_image" "prometheus" {
    name         = "prom/prometheus:latest"
    keep_locally = false  
}

resource "docker_container" "prometheus" {
  image = docker_image.prometheus.name
    name  = "prometheus"
    ports {
        internal = 9090
        external = 9090
    }
    volumes {
        container_path = "/etc/prometheus/prometheus.yml"
        host_path      = "${var.conf_path}/prometheus.yml"
        read_only      = false
    }
    
    volumes {
        container_path = "/etc/prometheus/alert_rules.yml"
        host_path      = "${var.conf_path}/alert_rules.yml"
        read_only      = false
    }

    command = ["--config.file=/etc/prometheus/prometheus.yml"]

    network_mode = "bridge"
    networks = [ "${docker_network.private_network.name}" ]
}

resource "docker_image" "grafana" {
    name = "grafana/grafana"
    keep_locally = false
}

resource "docker_container" "grafana" {
   image = docker_image.grafana.name
    name  = "grafana"
    ports {
        internal = 3000
        external = 3000
    }

    volumes {
        host_path      = "${var.conf_path}/grafana_config.ini"
        container_path = "/etc/grafana/config.ini"
    }

    volumes {
        host_path      = "${var.conf_path}/grafana_datasources.yml"
        container_path = "/etc/grafana/provisioning/datasources/all.yaml"
    }

    network_mode = "bridge"
    networks = [ "${docker_network.private_network.name}" ]
}

resource "docker_image" "alert_manager" {
    name = "prom/alertmanager"
    keep_locally = false
}

resource "docker_container" "alert_manager" {
   image = docker_image.alert_manager.name
    name  = "alert_manager"
    ports {
        internal = 9093
        external = 9093
    } 

    volumes {
        host_path      = "${var.conf_path}/alertmanager.conf"
        container_path = "/etc/alertmanager/alertmanager.conf"
    }
    
    command = [
        "--config.file=/etc/alertmanager/alertmanager.conf"
    ]

    network_mode = "bridge"
    networks = [ "${docker_network.private_network.name}" ]
}

resource "docker_image" "blackbox" {
  name = "prom/blackbox-exporter"
  keep_locally = false
}

resource "docker_container" "blackbox" {
    image = docker_image.blackbox.name
    name  = "blackbox"
    ports {
        internal = 9115
        external = 9115
    } 

    volumes {
        host_path      = "${var.conf_path}/blackbox.yml"
        container_path = "/config/blackbox.yml"
    }
    
    command = [
        "--config.file=/config/blackbox.yml"
    ]

    network_mode = "bridge"
    networks = [ "${docker_network.private_network.name}" ]
}
