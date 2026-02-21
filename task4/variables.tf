variable "project_prefix" {
  description = "Префикс для именования всех ресурсов"
  type        = string
  default     = "datamesh"
}

variable "network_subnet" {
  description = "CIDR-подсеть для платформенной сети"
  type        = string
  default     = "172.28.0.0/16"
}

variable "confluent_version" {
  description = "Версия Confluent Platform (Kafka, Zookeeper)"
  type        = string
  default     = "7.5.0"
}

variable "lakehouse_db_user" {
  description = "Пользователь БД Data Lakehouse"
  type        = string
  default     = "lakehouse_admin"
}

variable "lakehouse_db_password" {
  description = "Пароль БД Data Lakehouse"
  type        = string
  sensitive   = true
}

variable "lakehouse_db_name" {
  description = "Имя БД Data Lakehouse"
  type        = string
  default     = "lakehouse"
}

variable "lakehouse_port" {
  description = "Внешний порт Data Lakehouse"
  type        = number
  default     = 5432
}

variable "lakehouse_memory" {
  description = "Лимит памяти для Data Lakehouse (байты)"
  type        = number
  default     = 536870912
}

variable "domain_db_user" {
  description = "Пользователь доменных БД"
  type        = string
  default     = "domain_admin"
}

variable "domain_db_password" {
  description = "Пароль доменных БД"
  type        = string
  sensitive   = true
}

variable "domain_db_memory" {
  description = "Лимит памяти для доменных БД (байты)"
  type        = number
  default     = 268435456
}

variable "medical_db_port" {
  description = "Внешний порт Medical Domain DB"
  type        = number
  default     = 5433
}

variable "fintech_db_port" {
  description = "Внешний порт Fintech Domain DB"
  type        = number
  default     = 5434
}

variable "zookeeper_port" {
  description = "Внешний порт Zookeeper"
  type        = number
  default     = 2181
}

variable "zookeeper_memory" {
  description = "Лимит памяти для Zookeeper (байты)"
  type        = number
  default     = 268435456
}

variable "kafka_port" {
  description = "Внешний порт Kafka"
  type        = number
  default     = 9092
}

variable "kafka_memory" {
  description = "Лимит памяти для Kafka (байты)"
  type        = number
  default     = 536870912
}

variable "kafka_retention_hours" {
  description = "Время хранения сообщений в Kafka (часы)"
  type        = number
  default     = 168
}

variable "api_gateway_port" {
  description = "Внешний HTTP-порт API Gateway"
  type        = number
  default     = 8080
}

variable "api_gateway_ssl_port" {
  description = "Внешний HTTPS-порт API Gateway"
  type        = number
  default     = 8443
}

variable "api_gateway_memory" {
  description = "Лимит памяти для API Gateway (байты)"
  type        = number
  default     = 134217728
}

variable "grafana_version" {
  description = "Версия Grafana"
  type        = string
  default     = "10.2.0"
}

variable "grafana_port" {
  description = "Внешний порт Grafana"
  type        = number
  default     = 3000
}

variable "grafana_admin_user" {
  description = "Администратор Grafana"
  type        = string
  default     = "admin"
}

variable "grafana_admin_password" {
  description = "Пароль администратора Grafana"
  type        = string
  sensitive   = true
}

variable "grafana_memory" {
  description = "Лимит памяти для Grafana (байты)"
  type        = number
  default     = 268435456
}
