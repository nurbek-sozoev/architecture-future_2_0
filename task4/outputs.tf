output "network_name" {
  description = "Имя платформенной Docker-сети"
  value       = docker_network.platform.name
}

output "network_id" {
  description = "ID платформенной Docker-сети"
  value       = docker_network.platform.id
}

output "lakehouse_endpoint" {
  description = "Строка подключения к Data Lakehouse"
  value       = "postgresql://${var.lakehouse_db_user}@localhost:${var.lakehouse_port}/${var.lakehouse_db_name}"
}

output "lakehouse_container_name" {
  description = "Имя контейнера Data Lakehouse"
  value       = docker_container.lakehouse.name
}

output "medical_db_endpoint" {
  description = "Строка подключения к Medical Domain DB"
  value       = "postgresql://${var.domain_db_user}@localhost:${var.medical_db_port}/medical"
}

output "fintech_db_endpoint" {
  description = "Строка подключения к Fintech Domain DB"
  value       = "postgresql://${var.domain_db_user}@localhost:${var.fintech_db_port}/fintech"
}

output "kafka_bootstrap_servers" {
  description = "Kafka bootstrap-серверы для подключения клиентов"
  value       = "localhost:${var.kafka_port}"
}

output "zookeeper_connect" {
  description = "Строка подключения к Zookeeper"
  value       = "localhost:${var.zookeeper_port}"
}

output "api_gateway_url" {
  description = "URL API Gateway (HTTP)"
  value       = "http://localhost:${var.api_gateway_port}"
}

output "api_gateway_ssl_url" {
  description = "URL API Gateway (HTTPS)"
  value       = "https://localhost:${var.api_gateway_ssl_port}"
}

output "grafana_url" {
  description = "URL Grafana Dashboard"
  value       = "http://localhost:${var.grafana_port}"
}

output "infrastructure_summary" {
  description = "Сводка по развёрнутой инфраструктуре"
  value = {
    network          = docker_network.platform.name
    lakehouse        = "localhost:${var.lakehouse_port}"
    medical_db       = "localhost:${var.medical_db_port}"
    fintech_db       = "localhost:${var.fintech_db_port}"
    kafka            = "localhost:${var.kafka_port}"
    zookeeper        = "localhost:${var.zookeeper_port}"
    api_gateway      = "localhost:${var.api_gateway_port}"
    grafana          = "localhost:${var.grafana_port}"
    total_containers = 7
    total_volumes    = 5
  }
}
