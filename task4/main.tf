terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "platform" {
  name   = "${var.project_prefix}-network"
  driver = "bridge"

  ipam_config {
    subnet = var.network_subnet
  }

  labels {
    label = "project"
    value = var.project_prefix
  }
}

resource "docker_volume" "lakehouse_data" {
  name = "${var.project_prefix}-lakehouse-data"

  labels {
    label = "project"
    value = var.project_prefix
  }
}

resource "docker_volume" "medical_db_data" {
  name = "${var.project_prefix}-medical-db-data"

  labels {
    label = "project"
    value = var.project_prefix
  }
}

resource "docker_volume" "fintech_db_data" {
  name = "${var.project_prefix}-fintech-db-data"

  labels {
    label = "project"
    value = var.project_prefix
  }
}

resource "docker_volume" "grafana_data" {
  name = "${var.project_prefix}-grafana-data"

  labels {
    label = "project"
    value = var.project_prefix
  }
}

resource "docker_volume" "kafka_data" {
  name = "${var.project_prefix}-kafka-data"

  labels {
    label = "project"
    value = var.project_prefix
  }
}

resource "docker_image" "postgres" {
  name         = "postgres:16-alpine"
  keep_locally = true
}

resource "docker_image" "zookeeper" {
  name         = "confluentinc/cp-zookeeper:${var.confluent_version}"
  keep_locally = true
}

resource "docker_image" "kafka" {
  name         = "confluentinc/cp-kafka:${var.confluent_version}"
  keep_locally = true
}

resource "docker_image" "nginx" {
  name         = "nginx:1.25-alpine"
  keep_locally = true
}

resource "docker_image" "grafana" {
  name         = "grafana/grafana:${var.grafana_version}"
  keep_locally = true
}

resource "docker_container" "lakehouse" {
  name  = "${var.project_prefix}-lakehouse"
  image = docker_image.postgres.image_id

  env = [
    "POSTGRES_USER=${var.lakehouse_db_user}",
    "POSTGRES_PASSWORD=${var.lakehouse_db_password}",
    "POSTGRES_DB=${var.lakehouse_db_name}",
  ]

  ports {
    internal = 5432
    external = var.lakehouse_port
  }

  networks_advanced {
    name    = docker_network.platform.id
    aliases = ["lakehouse"]
  }

  volumes {
    volume_name    = docker_volume.lakehouse_data.name
    container_path = "/var/lib/postgresql/data"
  }

  memory = var.lakehouse_memory

  labels {
    label = "project"
    value = var.project_prefix
  }

  labels {
    label = "component"
    value = "data-lakehouse"
  }

  restart = "unless-stopped"
}

resource "docker_container" "medical_db" {
  name  = "${var.project_prefix}-medical-db"
  image = docker_image.postgres.image_id

  env = [
    "POSTGRES_USER=${var.domain_db_user}",
    "POSTGRES_PASSWORD=${var.domain_db_password}",
    "POSTGRES_DB=medical",
  ]

  ports {
    internal = 5432
    external = var.medical_db_port
  }

  networks_advanced {
    name    = docker_network.platform.id
    aliases = ["medical-db"]
  }

  volumes {
    volume_name    = docker_volume.medical_db_data.name
    container_path = "/var/lib/postgresql/data"
  }

  memory = var.domain_db_memory

  labels {
    label = "project"
    value = var.project_prefix
  }

  labels {
    label = "component"
    value = "medical-domain"
  }

  restart = "unless-stopped"
}

resource "docker_container" "fintech_db" {
  name  = "${var.project_prefix}-fintech-db"
  image = docker_image.postgres.image_id

  env = [
    "POSTGRES_USER=${var.domain_db_user}",
    "POSTGRES_PASSWORD=${var.domain_db_password}",
    "POSTGRES_DB=fintech",
  ]

  ports {
    internal = 5432
    external = var.fintech_db_port
  }

  networks_advanced {
    name    = docker_network.platform.id
    aliases = ["fintech-db"]
  }

  volumes {
    volume_name    = docker_volume.fintech_db_data.name
    container_path = "/var/lib/postgresql/data"
  }

  memory = var.domain_db_memory

  labels {
    label = "project"
    value = var.project_prefix
  }

  labels {
    label = "component"
    value = "fintech-domain"
  }

  restart = "unless-stopped"
}

resource "docker_container" "zookeeper" {
  name  = "${var.project_prefix}-zookeeper"
  image = docker_image.zookeeper.image_id

  env = [
    "ZOOKEEPER_CLIENT_PORT=2181",
    "ZOOKEEPER_TICK_TIME=2000",
  ]

  ports {
    internal = 2181
    external = var.zookeeper_port
  }

  networks_advanced {
    name    = docker_network.platform.id
    aliases = ["zookeeper"]
  }

  memory = var.zookeeper_memory

  labels {
    label = "project"
    value = var.project_prefix
  }

  labels {
    label = "component"
    value = "event-streaming"
  }

  restart = "unless-stopped"
}

resource "docker_container" "kafka" {
  name  = "${var.project_prefix}-kafka"
  image = docker_image.kafka.image_id

  env = [
    "KAFKA_BROKER_ID=1",
    "KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181",
    "KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafka:29092,PLAINTEXT_HOST://localhost:${var.kafka_port}",
    "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT",
    "KAFKA_INTER_BROKER_LISTENER_NAME=PLAINTEXT",
    "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1",
    "KAFKA_LOG_RETENTION_HOURS=${var.kafka_retention_hours}",
  ]

  ports {
    internal = 9092
    external = var.kafka_port
  }

  networks_advanced {
    name    = docker_network.platform.id
    aliases = ["kafka"]
  }

  volumes {
    volume_name    = docker_volume.kafka_data.name
    container_path = "/var/lib/kafka/data"
  }

  memory = var.kafka_memory

  labels {
    label = "project"
    value = var.project_prefix
  }

  labels {
    label = "component"
    value = "event-streaming"
  }

  restart   = "unless-stopped"
  depends_on = [docker_container.zookeeper]
}

resource "docker_container" "api_gateway" {
  name  = "${var.project_prefix}-api-gateway"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = var.api_gateway_port
  }

  ports {
    internal = 443
    external = var.api_gateway_ssl_port
  }

  networks_advanced {
    name    = docker_network.platform.id
    aliases = ["api-gateway"]
  }

  memory = var.api_gateway_memory

  labels {
    label = "project"
    value = var.project_prefix
  }

  labels {
    label = "component"
    value = "api-gateway"
  }

  restart = "unless-stopped"
}

resource "docker_container" "grafana" {
  name  = "${var.project_prefix}-grafana"
  image = docker_image.grafana.image_id

  env = [
    "GF_SECURITY_ADMIN_USER=${var.grafana_admin_user}",
    "GF_SECURITY_ADMIN_PASSWORD=${var.grafana_admin_password}",
    "GF_SERVER_ROOT_URL=http://localhost:${var.grafana_port}",
  ]

  ports {
    internal = 3000
    external = var.grafana_port
  }

  networks_advanced {
    name    = docker_network.platform.id
    aliases = ["grafana"]
  }

  volumes {
    volume_name    = docker_volume.grafana_data.name
    container_path = "/var/lib/grafana"
  }

  memory = var.grafana_memory

  labels {
    label = "project"
    value = var.project_prefix
  }

  labels {
    label = "component"
    value = "monitoring"
  }

  restart = "unless-stopped"
}
